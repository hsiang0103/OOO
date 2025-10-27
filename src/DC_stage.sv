module DC_stage(
    input logic clk,
    input logic rst,

    // From IF stage
    input logic [15:0]  DC_in_pc,
    input logic [31:0]  DC_in_inst,

    // From IS stage
    input logic [6:0]   commit_P_rd_new,
    input logic [6:0]   commit_P_rd_old,
    input logic [5:0]   commit_A_rd,
    input logic         commit_wb_en,
    input logic         recovery,

    // From EXE stage
    input logic         mispredict,

    // From LSU
    input logic         ld_ready,
    input logic         st_ready,

    // To IS stage
    output logic [15:0] DC_out_pc,
    output logic [31:0] DC_out_inst, 
    output logic [31:0] DC_out_imm,
    output logic [4:0]  DC_out_op,
    output logic [2:0]  DC_out_f3,
    output logic [6:0]  DC_out_f7,
    output logic [6:0]  DC_out_rs1,  
    output logic [6:0]  DC_out_rs2,
    output logic        DC_out_rs1_valid,
    output logic        DC_out_rs2_valid,
    output logic [6:0]  DC_out_P_rd_new,
    output logic [6:0]  DC_out_P_rd_old,
    output logic [5:0]  DC_out_A_rd,
    output logic [2:0]  DC_out_fu_sel,

    // Handshake signals
    // IF --- DC
    input  logic        IF_valid,
    output logic        DC_ready,
    // DC --- IS    
    output logic        DC_valid,
    input logic         IS_ready
);

    logic [4:0]     DC_op;
    logic [2:0]     DC_f3;
    logic [6:0]     DC_f7; 
    logic [2:0]     DC_fu_sel; 
    logic [31:0]    DC_imm; 
    logic [5:0]     A_rs1, A_rs2, A_rd;       // Architectural register index
    logic [6:0]     P_rs1, P_rs2;       // Physical register index
    logic           f_rs1, f_rs2, f_rd;
    logic [6:0]     P_rd_new, P_rd_old; // Physical register index
    logic           P_rs1_valid, P_rs2_valid;
    logic           use_rd;
    
    // Decode
    assign DC_op     = DC_in_inst[6:2];
    assign DC_f3     = DC_in_inst[14:12];
    assign DC_f7     = DC_in_inst[31:25];

    assign f_rs1    = (DC_op == `F_TYPE);
    assign f_rs2    = (DC_op == `F_TYPE) || (DC_op == `FSTORE);
    assign f_rd     = (DC_op == `F_TYPE) || (DC_op == `FLOAD);

    assign A_rs1    = {f_rs1, DC_in_inst[19:15]};
    assign A_rs2    = {f_rs2, DC_in_inst[24:20]};
    assign A_rd     = {f_rd , DC_in_inst[11:7]};

    // FU selection
    // 0: ALU
    // 1: MDR 
    // 2: Load 
    // 3: Store 
    // 4: FPU
    always_comb begin
        case (DC_op)
            `LUI    : DC_fu_sel = 3'd0;
            `AUIPC  : DC_fu_sel = 3'd0;
            `JAL    : DC_fu_sel = 3'd0;
            `JALR   : DC_fu_sel = 3'd0;
            `I_TYPE : DC_fu_sel = 3'd0;
            `CSR    : DC_fu_sel = 3'd0;
            `B_TYPE : DC_fu_sel = 3'd0;
            `R_TYPE : DC_fu_sel = DC_f7[0]; // M extension
            `LOAD   : DC_fu_sel = 3'd2;
            `FLOAD  : DC_fu_sel = 3'd2;
            `S_TYPE : DC_fu_sel = 3'd2;
            `FSTORE : DC_fu_sel = 3'd2;
            `F_TYPE : DC_fu_sel = 3'd3;
            default : DC_fu_sel = 3'd0;
        endcase
    end

    always_comb begin
        case (DC_op)
            `B_TYPE:    DC_imm = {{20{DC_in_inst[31]}}, DC_in_inst[7], DC_in_inst[30:25], DC_in_inst[11:8], 1'b0};
            `JAL:       DC_imm = {{12{DC_in_inst[31]}}, DC_in_inst[19:12], DC_in_inst[20], DC_in_inst[30:21], 1'b0};
            `I_TYPE:    DC_imm = {{20{DC_in_inst[31]}}, DC_in_inst[31:20]}; 
            `LOAD:      DC_imm = {{20{DC_in_inst[31]}}, DC_in_inst[31:20]}; 
            `FLOAD:     DC_imm = {{20{DC_in_inst[31]}}, DC_in_inst[31:20]};
            `JALR:      DC_imm = {{20{DC_in_inst[31]}}, DC_in_inst[31:20]};
            `S_TYPE:    DC_imm = {{20{DC_in_inst[31]}}, DC_in_inst[31:25], DC_in_inst[11:7]};
            `FSTORE:    DC_imm = {{20{DC_in_inst[31]}}, DC_in_inst[31:25], DC_in_inst[11:7]};
            `LUI:       DC_imm = {DC_in_inst[31:12], 12'b0};
            `AUIPC:     DC_imm = {DC_in_inst[31:12], 12'b0};
            `CSR:       DC_imm = {20'b0, DC_in_inst[31:20]};
            `R_TYPE:    DC_imm = 32'b0;
            `F_TYPE:    DC_imm = 32'b0;
            default:    DC_imm = 32'b0;
        endcase
    end

    // Register renaming
    logic [6:0]     rename_map [0:63];  // RMT
    logic [6:0]     commit_map [0:63];  // CMT
    logic [6:0]     freelist   [0:15];
    logic [79:0]    valid_map;         
    logic [3:0]     free_h, free_t;

    
    
    assign P_rs1        = rename_map[A_rs1];
    assign P_rs2        = rename_map[A_rs2];
    assign P_rd_old     = rename_map[A_rd];
    assign P_rd_new     = freelist[free_h];

    always_comb begin
        // P_rs1_valid
        case(DC_op)
            `JAL, `CSR, `LUI, `AUIPC:   P_rs1_valid = 1'b1;
            default: P_rs1_valid = valid_map[P_rs1] || (P_rs1 == commit_P_rd_new && commit_wb_en);
        endcase

        // P_rs2_valid
        case(DC_op)
            `JAL, `CSR, `LUI, `AUIPC,
            `FLOAD, `LOAD,`JALR,`I_TYPE:    P_rs2_valid = 1'b1;
            default: P_rs2_valid = valid_map[P_rs2] || (P_rs2 == commit_P_rd_new && commit_wb_en);
        endcase

        case(DC_op)
            `S_TYPE, `FSTORE, `B_TYPE:  use_rd = 1'b0;
            default:                    use_rd = 1'b1;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            valid_map       <= 80'hFFFFFFFFFFFFFFFFFFFFFFFF;
            free_h          <= 4'd0;
            free_t          <= 4'd0;
            for (int i = 0; i < 16; i = i + 1) begin
                freelist[i]   <= i + 64;
            end
            for (int i = 0; i < 64; i = i + 1) begin
                rename_map[i] <= i;
                commit_map[i] <= i;
            end
        end
        else begin
            if(A_rd != 0 && use_rd && DC_ready) begin
                rename_map[A_rd]        <= P_rd_new;
                valid_map[P_rd_new]     <= 1'b0;
                free_h                  <= free_h + 4'd1;
            end

            if(commit_wb_en && commit_A_rd != 0) begin
                valid_map[commit_P_rd_new]  <= 1'b1;
                freelist[free_t]            <= commit_P_rd_old;
                free_t                      <= free_t + 4'd1;

                commit_map[commit_A_rd] <= commit_P_rd_new;
            end

            if(recovery) begin
                free_h <= free_t;
                for (int i = 0; i < 64; i = i + 1) begin
                    rename_map[i] <= commit_map[i];
                end
                valid_map   <= 80'hFFFFFFFFFFFFFFFFFFFFFFFF;
            end
        end
    end

    logic        LSU_IS_ready;

    always_comb begin
        /*case (DC_op)
            `LOAD, `FLOAD:      LSU_IS_ready = ld_ready && IS_ready;
            `S_TYPE, `FSTORE:   LSU_IS_ready = st_ready && IS_ready;
            default:            LSU_IS_ready = IS_ready;
        endcase*/
        LSU_IS_ready = ld_ready && st_ready && IS_ready;
        DC_ready     = LSU_IS_ready;
    end

    // Main output 
    always_comb begin
        if(mispredict) begin
            DC_out_pc           = 16'b0;
            DC_out_inst         = 32'b0;
            DC_out_imm          = 32'b0;
            DC_out_op           = 5'b0;
            DC_out_f3           = 3'b0;
            DC_out_f7           = 7'b0;
            DC_out_rs1          = 7'b0;
            DC_out_rs2          = 7'b0;
            DC_out_rs1_valid    = 2'b0;
            DC_out_rs2_valid    = 2'b0;
            DC_out_P_rd_new     = 7'b0;
            DC_out_P_rd_old     = 7'b0;
            DC_out_A_rd         = 6'b0;
            DC_out_fu_sel       = 3'b0;
            DC_valid            = 1'b0;
        end
        else begin
            DC_out_pc           = DC_in_pc;
            DC_out_inst         = DC_in_inst;
            DC_out_imm          = DC_imm;
            DC_out_op           = DC_op;
            DC_out_f3           = DC_f3;
            DC_out_f7           = DC_f7;
            DC_out_rs1          = P_rs1;
            DC_out_rs2          = P_rs2;
            DC_out_rs1_valid    = P_rs1_valid;
            DC_out_rs2_valid    = P_rs2_valid;
            DC_out_P_rd_new     = P_rd_new;
            DC_out_P_rd_old     = P_rd_old;
            DC_out_A_rd         = A_rd;
            DC_out_fu_sel       = DC_fu_sel;
            DC_valid            = IF_valid;
        end
    end
endmodule