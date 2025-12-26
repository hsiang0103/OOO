module DC_stage(
    input   logic           clk,
    input   logic           rst,
    // IF stage
    input   logic           IF_valid,
    input   logic [31:0]    DC_in_pc,
    input   logic [31:0]    DC_in_inst,
    input   logic           DC_in_jump,
    output  logic           DC_ready,
    // rename 
    input   logic [6:0]     P_rs1,
    input   logic [6:0]     P_rs2,
    input   logic [6:0]     P_rd_new,
    input   logic [6:0]     P_rd_old,
    output  logic [5:0]     A_rs1,
    output  logic [5:0]     A_rs2,
    output  logic [5:0]     A_rd,
    output  logic           allocate_rd,
    // dispatch
    input   logic           rob_ready,
    input   logic           rob_empty,
    input   logic [$clog2(`ROB_LEN)-1:0]     DC_rob_idx,
    output  logic [31:0]    DC_pc,
    output  logic [31:0]    DC_inst,
    output  logic [4:0]     DC_op,
    output  logic [6:0]     DC_P_rd_new,
    output  logic [6:0]     DC_P_rd_old,
    output  logic [2:0]     DC_fu_sel, 
    output  logic           dispatch_valid,
    // IS stage
    input   logic           IS_ready,
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
    output  logic [$clog2(`LQ_LEN):0] DC_out_LQ_tail,
    output  logic [$clog2(`SQ_LEN):0] DC_out_SQ_tail,
    output  logic [$clog2(`ROB_LEN)-1:0]     DC_out_rob_idx, 
    output  logic           DC_out_jump,
    output  logic           DC_valid,
    // mispredict
    input   logic           mispredict,
    input   logic           stall,
    // LSU
    input   logic [$clog2(`LQ_LEN):0] LQ_tail,
    input   logic [$clog2(`SQ_LEN):0] SQ_tail,
    input   logic           ld_ready,
    input   logic           st_ready,
    // wakeup wfi
    output  logic           waiting_wfi,
    input   logic           wakeup_wfi
);

    logic [2:0]     DC_f3;
    logic [6:0]     DC_f7; 
    logic [31:0]    DC_imm; 
    logic           f_rs1, f_rs2, f_rd;
    logic           use_rd;
    logic           st_valid, ld_valid;
    logic           downstream_ready;
    logic           is_csr;     
    logic           csr_stall;  
    logic           is_wfi;

    assign is_csr    = (DC_op == `CSR); 
    assign csr_stall = is_csr && !rob_empty;
    assign is_wfi    = DC_in_inst == 32'h10500073; // wfi

    always @(posedge clk) begin
        if (rst) begin
            waiting_wfi <= 1'b0;
        end
        else begin
            if(mispredict) begin
                waiting_wfi <= 1'b0;
            end
            else if (!waiting_wfi) begin
                waiting_wfi <= IF_valid && is_wfi;
            end
            else begin
                waiting_wfi <= !wakeup_wfi;
            end
        end
    end

    // ================
    // Decode
    // ================
    assign DC_op    = DC_in_inst[6:2];
    assign DC_f3    = DC_in_inst[14:12];
    assign DC_f7    = DC_in_inst[31:25];
    assign f_rs1    = (DC_op == `F_TYPE);
    assign f_rs2    = (DC_op == `F_TYPE) || (DC_op == `FSTORE);
    assign f_rd     = (DC_op == `F_TYPE) || (DC_op == `FLOAD);
    assign A_rs1    = {f_rs1, DC_in_inst[19:15]};
    assign A_rs2    = {f_rs2, DC_in_inst[24:20]};
    assign A_rd     = {f_rd , DC_in_inst[11:7]};

    // FU selection
    // 0: alu 
    // 1: mul     
    // 2: div/rem 
    // 3: falu    
    // 4: fmul    
    // 5: fdiv    
    // 6: load/store    
    // 7: csr   
    always_comb begin
        DC_fu_sel = 3'd0; // alu
        case (DC_op)
            `R_TYPE : begin
                if (DC_f7 == 7'b0000001) begin
                    DC_fu_sel = (DC_f3[2]? 3'd2 : 3'd1); // div/rem or mul
                end 
            end
            `F_TYPE : DC_fu_sel = 3'd3;
            `LOAD   : DC_fu_sel = 3'd6;
            `FLOAD  : DC_fu_sel = 3'd6;
            `S_TYPE : DC_fu_sel = 3'd6;
            `FSTORE : DC_fu_sel = 3'd6;
            `CSR    : DC_fu_sel = 3'd7;
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
            default:    DC_imm = 32'b0;
        endcase
    end

    // rename allocate rd
    assign allocate_rd      = ((DC_op != `S_TYPE) && (DC_op != `FSTORE)) && (DC_op != `B_TYPE) && A_rd != 6'd0;
    
    // load/store valid
    assign st_valid         = ((DC_op != `S_TYPE) && (DC_op != `FSTORE)) || st_ready;
    assign ld_valid         = ((DC_op != `LOAD)   && (DC_op != `FLOAD )) || ld_ready;

    // allocate ROB/LSU
    assign DC_pc            = DC_in_pc;
    assign DC_inst          = DC_in_inst;
    assign DC_P_rd_new      = P_rd_new;
    assign DC_P_rd_old      = P_rd_old;

    // ================
    // Pipeline Register
    // ================
    
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
        logic [$clog2(`ROB_LEN)-1:0]     rob_idx;
        logic [$clog2(`LQ_LEN):0] LQ_tail;
        logic [$clog2(`SQ_LEN):0] SQ_tail;
        logic [2:0]     fu_sel;
        logic           jump;
    } data_t;
    
    data_t  i_data, o_data;      

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
    
    logic valid_r;
    always @(posedge clk) begin
        if (rst) begin      
            o_data  <= '0;
            valid_r <= 1'b0; 
        end
        else begin      
            if (mispredict || stall) begin
                o_data      <= '0;  
            end 
            else if(dispatch_valid)begin
                o_data      <= i_data;
            end

            if(valid_r) begin
                if(mispredict) begin
                    valid_r <= 1'b0;
                end
                else begin
                    valid_r <= (DC_valid)? dispatch_valid : valid_r;
                end
            end
            else begin
                valid_r <= IF_valid && !mispredict && !stall && DC_ready;
            end
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
    // all downstream ready
    
    assign downstream_ready = rob_ready && st_valid && ld_valid && IS_ready && !csr_stall && !waiting_wfi;
    assign DC_ready         =             downstream_ready && !mispredict && !stall; 
    assign DC_valid         = valid_r  && rob_ready && st_valid && ld_valid && IS_ready && !mispredict && !stall;
    assign dispatch_valid   = IF_valid && downstream_ready && !mispredict && !stall && !is_wfi;

endmodule