module DC_stage(
    input   logic           clk,
    input   logic           rst,
    // IF stage
    input   logic [31:0]    DC_in_pc,
    input   logic [31:0]    DC_in_inst,
    input   logic           DC_in_jump,
    // rename 
    input   logic [6:0]     P_rs1,
    input   logic [6:0]     P_rs2,
    input   logic [6:0]     P_rd_new,
    input   logic [6:0]     P_rd_old,
    output  logic [5:0]     A_rs1,
    output  logic [5:0]     A_rs2,
    output  logic [5:0]     A_rd,
    output  logic           allocate_rd,
    // Dispatch/ROB
    input   logic           rob_ready,
    input   logic [2:0]     DC_rob_idx,
    output  logic [31:0]    DC_pc,
    output  logic [31:0]    DC_inst,
    output  logic [6:0]     DC_P_rd_new,
    output  logic [6:0]     DC_P_rd_old,
    output  logic [2:0]     DC_fu_sel, 
    output  logic           decode_valid,
    output  logic           dispatch_ready,
    // IS stage
    output  logic [31:0]    DC_out_pc,
    output  logic [31:0]    DC_out_inst, 
    output  logic [31:0]    DC_out_imm,
    output  logic [4:0]     DC_out_op,
    output  logic [2:0]     DC_out_f3,
    output  logic [6:0]     DC_out_f7,
    output  logic [6:0]     DC_out_P_rs1,
    output  logic [6:0]     DC_out_P_rs2,
    output  logic [6:0]     DC_out_P_rd,
    output  logic [2:0]     DC_out_fu_sel,
    output  logic [1:0]     DC_out_LQ_tail,
    output  logic [1:0]     DC_out_SQ_tail,
    output  logic [2:0]     DC_out_rob_idx, 
    output  logic           DC_out_jump,
    // mispredict
    input   logic           mispredict,
    input   logic           stall,
    // LSU
    input   logic [1:0]     LQ_tail,
    input   logic [1:0]     SQ_tail,
    input   logic           ld_ready,
    input   logic           st_ready,
    // Handshake signals
    input   logic           IF_valid,
    output  logic           DC_ready,
    output  logic           DC_valid,
    input   logic           IS_ready
);

    logic [4:0]     DC_op;
    logic [2:0]     DC_f3;
    logic [6:0]     DC_f7; 
    logic [31:0]    DC_imm; 
    logic           f_rs1, f_rs2, f_rd;
    logic           use_rd;
    logic           st_valid, ld_valid;
    
    // Decode
    assign DC_op            = DC_in_inst[6:2];
    assign DC_f3            = DC_in_inst[14:12];
    assign DC_f7            = DC_in_inst[31:25];

    assign f_rs1            = (DC_op == `F_TYPE);
    assign f_rs2            = (DC_op == `F_TYPE) || (DC_op == `FSTORE);
    assign f_rd             = (DC_op == `F_TYPE) || (DC_op == `FLOAD);

    assign A_rs1            = {f_rs1, DC_in_inst[19:15]};
    assign A_rs2            = {f_rs2, DC_in_inst[24:20]};
    assign A_rd             = {f_rd , DC_in_inst[11:7]};

    assign allocate_rd      = ((DC_op != `S_TYPE) && (DC_op != `FSTORE)) && (DC_op != `B_TYPE) && A_rd != 6'd0;
    assign st_valid         = ((DC_op != `S_TYPE) && (DC_op != `FSTORE)) || st_ready;
    assign ld_valid         = ((DC_op != `LOAD)   && (DC_op != `FLOAD )) || ld_ready;

    assign dispatch_ready   = rob_ready && st_valid && ld_valid && IS_ready && !mispredict && !stall;
    assign decode_valid     = IF_valid && rob_ready && st_valid && ld_valid && !mispredict && !stall;
    assign DC_pc            = DC_in_pc;
    assign DC_inst          = DC_in_inst;
    assign DC_P_rd_new      = P_rd_new;
    assign DC_P_rd_old      = P_rd_old;
    // FU selection
    // 0: alu/csr   0   
    // 1: mul       0   
    // 2: div/rem   0   
    // 3: falu      1
    // 4: fmul      1
    // 5: fdiv      1
    // 6: load      2
    // 7: store     2
    always_comb begin
        case (DC_op)
            `R_TYPE : DC_fu_sel = {2'b0, DC_f7[0]}; // M extension
            `F_TYPE : DC_fu_sel = 3'd3;
            `LOAD   : DC_fu_sel = 3'd6;
            `FLOAD  : DC_fu_sel = 3'd6;
            `S_TYPE : DC_fu_sel = 3'd7;
            `FSTORE : DC_fu_sel = 3'd7;
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
    
    typedef struct packed {
        logic [31:0]    pc;
        logic [31:0]    inst;
        logic [31:0]    imm;
        logic [4:0]     op;
        logic [2:0]     f3;
        logic [6:0]     f7;
        logic [6:0]     P_rs1;
        logic [6:0]     P_rs2;
        logic [6:0]     P_rd;
        logic [2:0]     rob_idx;
        logic [1:0]     LQ_tail;
        logic [1:0]     SQ_tail;
        logic [2:0]     fu_sel;
        logic           jump;
    } data_t;
    
    logic   valid_rg, ready_rg;    
    logic   ready;    
    data_t  i_data, o_data, temp_data;         
    data_t  data_rg;
    data_t  sparebuff_rg;  

    logic   i_ready, i_valid;
    logic   o_ready, o_valid;

    assign i_data.pc        = DC_in_pc         ;
    assign i_data.inst      = DC_in_inst       ;
    assign i_data.imm       = DC_imm           ;
    assign i_data.op        = DC_op            ;
    assign i_data.f3        = DC_f3            ;
    assign i_data.f7        = DC_f7            ;
    assign i_data.P_rs1     = P_rs1            ;
    assign i_data.P_rs2     = P_rs2            ;
    assign i_data.P_rd      = P_rd_new         ;
    assign i_data.rob_idx   = DC_rob_idx       ;
    assign i_data.LQ_tail   = LQ_tail          ;
    assign i_data.SQ_tail   = SQ_tail          ;
    assign i_data.fu_sel    = DC_fu_sel        ;
    assign i_data.jump      = DC_in_jump       ;
    
    logic temp;
    always @(posedge clk) begin
        if (rst) begin      
            o_data   <= '0;
            DC_valid     <= 1'b0; 
        end
        else begin      
            if (mispredict || stall) begin
                o_data      <= '0;  
            end 
            else if(IF_valid && dispatch_ready)begin
                o_data      <= i_data;
            end
            else begin
                o_data      <= o_data;
            end
            DC_valid <= IF_valid && !mispredict && !stall;
        end
    end    

    // Output assignments
    assign DC_out_pc       = o_data.pc     ;
    assign DC_out_inst     = o_data.inst   ;
    assign DC_out_imm      = o_data.imm    ;
    assign DC_out_op       = o_data.op     ;
    assign DC_out_f3       = o_data.f3     ;
    assign DC_out_f7       = o_data.f7     ;
    assign DC_out_P_rs1    = o_data.P_rs1  ;
    assign DC_out_P_rs2    = o_data.P_rs2  ;
    assign DC_out_P_rd     = o_data.P_rd   ;
    assign DC_out_fu_sel   = o_data.fu_sel ;
    assign DC_out_rob_idx  = o_data.rob_idx;
    assign DC_out_LQ_tail  = o_data.LQ_tail;
    assign DC_out_SQ_tail  = o_data.SQ_tail;
    assign DC_out_jump     = o_data.jump   ;
    // assign DC_valid        = temp; 
    assign DC_ready        = dispatch_ready;
endmodule