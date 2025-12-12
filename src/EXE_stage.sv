module EXE_stage(
    input   logic           clk,
    input   logic           rst,
    // RR stage
    input   logic [2:0]     EXE_in_fu_sel,
    input   logic [31:0]    EXE_in_inst,
    input   logic [31:0]    EXE_in_rs1_data,
    input   logic [31:0]    EXE_in_rs2_data,
    input   logic [31:0]    EXE_in_imm,
    input   logic [31:0]    EXE_in_pc,
    input   logic [6:0]     EXE_in_rd,   
    input   logic [4:0]     EXE_in_op,    
    input   logic [2:0]     EXE_in_f3,
    input   logic [6:0]     EXE_in_f7,
    input   logic [$clog2(`ROB_LEN)-1:0]     EXE_in_rob_idx,
    input   logic           EXE_in_jump,
    // LSU 
    output  logic           ld_i_valid,
    output  logic           st_i_valid,
    output  logic [$clog2(`ROB_LEN)-1:0]     lsu_i_rob_idx,
    output  logic [31:0]    lsu_i_rs1_data,
    output  logic [31:0]    lsu_i_rs2_data,
    output  logic [31:0]    lsu_i_imm,
    input   logic           ld_o_valid,
    input   logic [$clog2(`ROB_LEN)-1:0]     ld_o_rob_idx,
    input   logic [6:0]     ld_o_rd,
    input   logic [31:0]    ld_o_data,
    // mispredict
    input   logic           DC_in_jump,
    input   logic           IF_valid,
    input   logic           DC_ready,
    output  logic           is_jb,
    output  logic [31:0]    jb_pc,  
    output  logic           mispredict,  
    output  logic [$clog2(`ROB_LEN)-1:0]     mis_rob_idx,
    // forwarding
    output  logic [31:0]    EX_out_data,
    output  logic [$clog2(`ROB_LEN)-1:0]     EX_out_rob_idx, 
    output  logic           EX_out_valid,
    output  logic [6:0]     EX_out_rd,
    // write back
    output  logic [31:0]    WB_out_data,
    output  logic [$clog2(`ROB_LEN)-1:0]     WB_out_rob_idx, 
    output  logic           WB_out_valid,
    output  logic [6:0]     WB_out_rd,
    // Handshake signals
    input  logic            RR_valid,
    output logic [7:0]      EX_ready
);  

    typedef struct packed{
        logic [31:0] data;
        logic [$clog2(`ROB_LEN)-1:0]  rob_idx;
        logic [6:0]  rd;
    } data_t;

    logic [7:0] out_sel; 
    logic [7:0] o_valid;    
    data_t      o_data [7:0];

    // fu selection
    // 0: alu/csr  
    // 1: mul      
    // 2: div/rem  
    // 3: falu     
    // 4: fmul     
    // 5: fdiv     
    // 6: load     
    // 7: store    

    // =======================================================
    //                         ALU/[0]           
    // =======================================================
    data_t alu_o_data;
    data_t alu_data_rg;
    logic alu_o_valid;
    logic alu_bypass;
    logic jump;

    ALU alu(
        .opcode         (EXE_in_op),
        .funct3         (EXE_in_f3),
        .funct7         (EXE_in_f7[5]),
        .rs1_data       (EXE_in_rs1_data),
        .rs2_data       (EXE_in_rs2_data),
        .imm            (EXE_in_imm),
        .pc             (EXE_in_pc),
        // control
        .alu_i_valid    (RR_valid && EXE_in_fu_sel == 3'd0),
        .alu_i_rob_idx  (EXE_in_rob_idx),
        .alu_i_rd       (EXE_in_rd),
        .alu_o_valid    (alu_o_valid),
        .alu_o_rob_idx  (alu_o_data.rob_idx),
        .alu_o_rd       (alu_o_data.rd),
        .alu_o_data     (alu_o_data.data),
        // jump
        .alu_jb_out     (jb_pc),
        .jump           (jump)
    );

    always @(posedge clk) begin
        if (rst) begin      
            alu_data_rg         <= '0;     
            alu_bypass          <= 1'b1;
        end   
        else begin      
            if (alu_bypass) begin         
                if (!out_sel[0] && alu_o_valid) begin
                    alu_data_rg     <= alu_o_data;      
                    alu_bypass      <= 1'b0;      
                end 
            end 
            else begin         
                alu_bypass  <= out_sel[0];        
            end
        end
    end

    assign EX_ready[0]  = alu_bypass;
    assign o_data[0]    = alu_bypass ? alu_o_data : alu_data_rg;
    assign o_valid[0]   = alu_bypass ? alu_o_valid : 1'b1;

    // mispredict logic
    always_comb begin
        is_jb = (EXE_in_op == `B_TYPE || EXE_in_op == `JAL);
    end
    assign mispredict   = EXE_in_jump != jump && RR_valid && EXE_in_fu_sel == 3'd0 && alu_bypass;
    assign mis_rob_idx  = EXE_in_rob_idx;

    // =======================================================
    //                         MUL/[1]           
    // =======================================================
    data_t mul_o_data;
    data_t mul_data_rg;
    logic mul_o_valid;
    logic mul_bypass;
    logic mul_idle;

    MUL mul(
        .clk            (clk),
        .rst            (rst),
        .funct3         (EXE_in_f3),
        .rs1_data       (EXE_in_rs1_data),
        .rs2_data       (EXE_in_rs2_data),

        // control
        .mul_i_valid    (RR_valid && EXE_in_fu_sel == 3'd1),
        .mul_i_rob_idx  (EXE_in_rob_idx),
        .mul_i_rd       (EXE_in_rd),
        .mul_o_valid    (mul_o_valid),
        .mul_o_rob_idx  (mul_o_data.rob_idx),
        .mul_o_rd       (mul_o_data.rd),
        .mul_o_data     (mul_o_data.data),
        .mul_idle       (mul_idle)
    );

    always @(posedge clk) begin
           if (rst) begin      
            mul_data_rg         <= '0;     
            mul_bypass          <= 1'b1;
        end   
        else begin      
            if (mul_bypass) begin         
                if (!out_sel[1] && mul_o_valid) begin
                    mul_data_rg     <= mul_o_data;      
                    mul_bypass      <= 1'b0;      
                end 
            end 
            else begin         
                mul_bypass  <= out_sel[1];        
            end
        end
    end

    assign EX_ready[1]  = mul_bypass && mul_idle;
    assign o_data[1]    = mul_bypass ? mul_o_data : mul_data_rg;
    assign o_valid[1]   = mul_bypass ? mul_o_valid : 1'b1;
    // =======================================================
    //                       DIV/REM/[2]           
    // =======================================================
    assign EX_ready[2]  = 1'b0;
    // TODO: DIV/REM implementation

    // =======================================================
    //                        FALU/[3]           
    // =======================================================
    data_t falu_o_data;
    data_t falu_data_rg;
    logic falu_o_valid;
    logic falu_bypass;
    logic falu_idle;

    FALU falu(
        .clk            (clk),
        .rst            (rst),
        .funct5         (EXE_in_f7[6:2]),
        .operand1       (EXE_in_rs1_data),
        .operand2       (EXE_in_rs2_data),

        // control
        .falu_i_valid    (RR_valid && EXE_in_fu_sel == 3'd3),
        .falu_i_rob_idx  (EXE_in_rob_idx),
        .falu_i_rd       (EXE_in_rd),
        .falu_o_valid    (falu_o_valid),
        .falu_o_rob_idx  (falu_o_data.rob_idx),
        .falu_o_rd       (falu_o_data.rd),
        .falu_o_data     (falu_o_data.data)
    );

    always @(posedge clk) begin
           if (rst) begin      
            falu_data_rg         <= '0;     
            falu_bypass          <= 1'b1;
        end   
        else begin      
            if (falu_bypass) begin         
                if (!out_sel[3] && falu_o_valid) begin
                    falu_data_rg     <= falu_o_data;      
                    falu_bypass      <= 1'b0;      
                end 
            end 
            else begin         
                falu_bypass  <= out_sel[3];        
            end
        end
    end

    assign EX_ready[3]  = falu_bypass;
    assign o_data[3]    = falu_bypass ? falu_o_data : falu_data_rg;
    assign o_valid[3]   = falu_bypass ? falu_o_valid : 1'b1;
    // =======================================================
    //                        FMUL[4]           
    // =======================================================
    assign EX_ready[4]  = 1'b0;
    // TODO: FMUL implementation

    // =======================================================
    //                        FDIV[5]           
    // =======================================================
    assign EX_ready[5]  = 1'b0;
    // TODO: FDIV implementation

    // =======================================================
    //                   LOAD/STORE[6]/[7]           
    // =======================================================
    data_t lsu_o_data;
    data_t lsu_data_rg;
    logic lsu_o_valid;
    logic lsu_bypass;

    assign ld_i_valid           = RR_valid && (EXE_in_fu_sel == 3'd6);
    assign st_i_valid           = RR_valid && (EXE_in_fu_sel == 3'd7);
    assign lsu_i_rob_idx        = EXE_in_rob_idx;
    assign lsu_i_rs1_data       = EXE_in_rs1_data;
    assign lsu_i_rs2_data       = EXE_in_rs2_data;
    assign lsu_i_imm            = EXE_in_imm;

    assign lsu_o_data.data      = ld_o_data;
    assign lsu_o_data.rob_idx   = ld_o_rob_idx;
    assign lsu_o_data.rd        = ld_o_rd;
    assign lsu_o_valid          = ld_o_valid;

    always @(posedge clk) begin
        if (rst) begin      
            lsu_data_rg         <= '0;     
            lsu_bypass          <= 1'b1;
        end   
        else begin      
            if (lsu_bypass) begin         
                if (!out_sel[6] && lsu_o_valid) begin
                    lsu_data_rg     <= lsu_o_data;      
                    lsu_bypass      <= 1'b0;      
                end
            end 
            else begin         
                lsu_bypass  <= out_sel[6];        
            end
        end
    end

    assign EX_ready[6]  = lsu_bypass;
    assign EX_ready[7]  = 1'b1; // store always ready
    assign o_data[6]    = lsu_bypass ? lsu_o_data : lsu_data_rg;
    assign o_valid[6]   = lsu_bypass ? lsu_o_valid : 1'b1;
    // =======================================================
    //                      OUTPUT MUX           
    // =======================================================
    logic [31:0]    EX_o_data;
    logic           EX_o_valid;
    logic [$clog2(`ROB_LEN)-1:0]     EX_o_rob_idx;
    logic [6:0]     EX_o_rd;

    always_comb begin
        priority case(1'b1)
            o_valid[1]: begin
                out_sel         = 8'b0000_0010;
                EX_o_data       = o_data[1].data;
                EX_o_valid      = o_valid[1];
                EX_o_rob_idx    = o_data[1].rob_idx;
                EX_o_rd         = o_data[1].rd;
            end
            o_valid[6]: begin
                out_sel         = 8'b0100_0000;
                EX_o_data       = o_data[6].data;
                EX_o_valid      = o_valid[6];
                EX_o_rob_idx    = o_data[6].rob_idx;
                EX_o_rd         = o_data[6].rd;
            end
            o_valid[0]: begin
                out_sel         = 8'b0000_0001;
                EX_o_data       = o_data[0].data;
                EX_o_valid      = o_valid[0];
                EX_o_rob_idx    = o_data[0].rob_idx;
                EX_o_rd         = o_data[0].rd;
            end
            o_valid[3]: begin
                out_sel         = 8'b0000_1000;
                EX_o_data       = o_data[3].data;
                EX_o_valid      = o_valid[3];
                EX_o_rob_idx    = o_data[3].rob_idx;
                EX_o_rd         = o_data[3].rd;
            end
            default: begin
                out_sel         = 8'b0000_0000;
                EX_o_data       = 32'b0;
                EX_o_valid      = 1'b0;
                EX_o_rob_idx    = 3'b0;
                EX_o_rd         = 7'b0;
            end
        endcase        
    end

    assign EX_out_data     = EX_o_data;
    assign EX_out_rob_idx  = EX_o_rob_idx;
    assign EX_out_valid    = EX_o_valid;
    assign EX_out_rd       = EX_o_rd;

    //======================================================
    //                      WB stage           
    //======================================================

    always_ff @(posedge clk) begin
        if (rst) begin
            WB_out_data    <= 32'b0;
            WB_out_rob_idx <= 3'b0;
            WB_out_valid   <= 1'b0;
            WB_out_rd      <= 7'b0;
        end
        else begin
            WB_out_data    <= EX_o_data;
            WB_out_rob_idx <= EX_o_rob_idx;
            WB_out_valid   <= EX_o_valid ;
            WB_out_rd      <= EX_o_rd;
        end
    end
endmodule