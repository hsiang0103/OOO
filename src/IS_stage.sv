module IS_stage (
    input clk,
    input rst,
    // DC stage
    input   logic           dispatch_ready,
    input   logic [31:0]    IS_in_pc,
    input   logic [31:0]    IS_in_inst, 
    input   logic [31:0]    IS_in_imm,
    input   logic [4:0]     IS_in_op,
    input   logic [2:0]     IS_in_f3,
    input   logic [6:0]     IS_in_f7,
    input   logic [6:0]     IS_in_rs1,  
    input   logic [6:0]     IS_in_rs2,
    input   logic [6:0]     IS_in_rd,
    input   logic [2:0]     IS_in_fu_sel,
    input   logic [2:0]     IS_in_rob_idx,
    input   logic [1:0]     IS_in_LQ_tail,
    input   logic [1:0]     IS_in_SQ_tail,
    // rename 
    input   logic           IS_in_rs1_valid,
    input   logic           IS_in_rs2_valid,
    // EXE stage
    output  logic [31:0]    RR_out_pc,
    output  logic [31:0]    RR_out_inst, 
    output  logic [31:0]    RR_out_imm,
    output  logic [31:0]    RR_out_rs1_data,
    output  logic [31:0]    RR_out_rs2_data,
    output  logic [4:0]     RR_out_op,
    output  logic [2:0]     RR_out_f3,
    output  logic [6:0]     RR_out_f7,
    output  logic [2:0]     RR_out_fu_sel,
    output  logic [1:0]     RR_out_ld_idx,
    output  logic [1:0]     RR_out_st_idx,
    output  logic [2:0]     RR_out_rob_idx, 
    output  logic [6:0]     RR_out_rd,
    // EX forwarding
    input   logic [31:0]    EX_in_data,
    input   logic [6:0]     EX_in_rd, 
    input   logic           EX_in_valid,
    // write back
    input   logic           WB_valid,
    input   logic [31:0]    WB_data,
    input   logic [6:0]     WB_rd,
    output  logic           writeback_free,
    // mispredict
    input   logic           mispredict,
    input   logic           stall,
    input   logic [7:0]     flush_mask,
    // Handshake signals
    input   logic           DC_valid,
    output  logic           IS_ready,
    output  logic           RR_valid,
    input   logic [7:0]     EX_ready,
    // konata
    output  logic           IS_valid,
    output  logic           RR_ready,
    output  logic [2:0]     IS_out_rob_idx
);
    typedef struct packed {
        logic [31:0]    pc;
        logic [31:0]    inst;
        logic [31:0]    imm;
        logic [4:0]     op;
        logic [2:0]     f3;
        logic [6:0]     f7;
        logic [6:0]     P_rs1;
        logic [6:0]     P_rs2;
        logic           P_rs1_valid;
        logic           P_rs2_valid;
        logic [6:0]     P_rd;
        logic [1:0]     ld_idx;
        logic [1:0]     st_idx;
        logic [2:0]     fu_sel;
        logic [2:0]     rob_idx;
        logic           valid;
    } IS_data_t;

    // fu selection 
    // 0: alu/csr   
    // 1: mul       
    // 2: div/rem   
    // 3: falu      
    // 4: fmul      
    // 5: fdiv      
    // 6: load      
    // 7: store     
    IS_data_t iq [0:3];
    logic [1:0] dispatch_ptr;
    logic [1:0] issue_ptr;
    logic [3:0] rs1_valid, rs2_valid;

    assign IS_ready = !(iq[0].valid && iq[1].valid && iq[2].valid && iq[3].valid) && !mispredict && !stall;

    // Bad issue strategy
    // TODO: use age matric to implement oldest first issue

    always_comb begin
        // find free entry
        priority case(1'b1)
            iq[0].valid == 1'b0: dispatch_ptr = 2'd0;
            iq[1].valid == 1'b0: dispatch_ptr = 2'd1;
            iq[2].valid == 1'b0: dispatch_ptr = 2'd2;
            iq[3].valid == 1'b0: dispatch_ptr = 2'd3;
            default: dispatch_ptr = 2'd0;
        endcase
        // check rs1/rs2 ready
        for(int i = 0; i < 4; i = i + 1) begin : rs_ready_check
            rs1_valid[i] = iq[i].P_rs1_valid || (iq[i].P_rs1 == WB_rd && WB_valid) || (iq[i].P_rs1 == EX_in_rd && EX_in_valid);
            rs2_valid[i] = iq[i].P_rs2_valid || (iq[i].P_rs2 == WB_rd && WB_valid) || (iq[i].P_rs2 == EX_in_rd && EX_in_valid);
        end
        // find ready entry
        priority case(1'b1)
            iq[0].valid && rs1_valid[0] && rs2_valid[0] && EX_ready[iq[0].fu_sel]: begin
                issue_ptr = 2'd0;
                IS_valid  = 1'b1;   
            end
            iq[1].valid && rs1_valid[1] && rs2_valid[1] && EX_ready[iq[1].fu_sel]: begin
                issue_ptr = 2'd1;
                IS_valid  = 1'b1;   
            end
            iq[2].valid && rs1_valid[2] && rs2_valid[2] && EX_ready[iq[2].fu_sel]: begin
                issue_ptr = 2'd2;
                IS_valid  = 1'b1;   
            end
            iq[3].valid && rs1_valid[3] && rs2_valid[3] && EX_ready[iq[3].fu_sel]: begin
                issue_ptr = 2'd3;
                IS_valid  = 1'b1;   
            end 
            default: begin
                issue_ptr = 2'd0;
                IS_valid  = 1'b0;   
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if(rst) begin
            for (int i = 0; i < 4; i = i + 1) begin : initialize_iq
                iq[i]   <= '0;
            end
        end
        else begin
            for(int i = 0; i < 4; i = i + 1) begin : update_iq
                // Dispatch
                if(DC_valid && dispatch_ready && dispatch_ptr == i && (!mispredict || !flush_mask[IS_in_rob_idx])) begin
                    iq[i].pc            <= IS_in_pc;
                    iq[i].inst          <= IS_in_inst;
                    iq[i].imm           <= IS_in_imm;
                    iq[i].op            <= IS_in_op;
                    iq[i].f3            <= IS_in_f3;
                    iq[i].f7            <= IS_in_f7;
                    iq[i].P_rs1         <= IS_in_rs1;
                    iq[i].P_rs2         <= IS_in_rs2;
                    iq[i].P_rs1_valid   <= IS_in_rs1_valid || (IS_in_rs1 == WB_rd && WB_valid) || (IS_in_rs1 == EX_in_rd && EX_in_valid);
                    iq[i].P_rs2_valid   <= IS_in_rs2_valid || (IS_in_rs2 == WB_rd && WB_valid) || (IS_in_rs2 == EX_in_rd && EX_in_valid);
                    iq[i].P_rd          <= IS_in_rd;
                    iq[i].ld_idx        <= IS_in_LQ_tail;
                    iq[i].st_idx        <= IS_in_SQ_tail;
                    iq[i].fu_sel        <= IS_in_fu_sel;
                    iq[i].rob_idx       <= IS_in_rob_idx;
                    iq[i].valid         <= 1'b1;
                end
                
                // EX forwarding
                if(EX_in_valid && EX_in_rd != 7'b0 && iq[i].valid) begin
                    iq[i].P_rs1_valid   <= (iq[i].P_rs1 == EX_in_rd)? 1'b1 : iq[i].P_rs1_valid;
                    iq[i].P_rs2_valid   <= (iq[i].P_rs2 == EX_in_rd)? 1'b1 : iq[i].P_rs2_valid;
                end
                // write back
                else if(WB_valid && WB_rd != 7'b0 && iq[i].valid) begin
                    iq[i].P_rs1_valid   <= (iq[i].P_rs1 == WB_rd)? 1'b1 : iq[i].P_rs1_valid;
                    iq[i].P_rs2_valid   <= (iq[i].P_rs2 == WB_rd)? 1'b1 : iq[i].P_rs2_valid;
                end
                // issue
                if(issue_ptr == i && IS_valid && RR_ready) begin
                    iq[i]   <= '0;
                end
                // mispredict
                if(mispredict && flush_mask[iq[i].rob_idx]) begin
                    iq[i]   <= '0;
                end
            end
        end
    end

    // Register Read
    logic [31:0] RR_rs1_data, RR_rs2_data;
    RegFile R1 (
        .clk            (clk),
        .rst            (rst),
        .rs1_index      (iq[issue_ptr].P_rs1),
        .rs2_index      (iq[issue_ptr].P_rs2),
        .rs1_data_out   (RR_rs1_data),
        .rs2_data_out   (RR_rs2_data),

        .wb_en          (WB_valid),
        .wb_data        (WB_data),
        .rd_index       (WB_rd)
    );
    
    // State encoding
    localparam PIPE  = 1'b0 ;
    localparam SKID  = 1'b1 ;

    typedef struct packed {
        logic [31:0]    pc;     
        logic [31:0]    inst;
        logic [31:0]    imm;
        logic [4:0]     op;
        logic [2:0]     f3;
        logic [6:0]     f7;
        logic [31:0]    rs1_data;
        logic [31:0]    rs2_data;
        logic [6:0]     P_rd;
        logic [2:0]     rob_idx;
        logic [1:0]     ld_idx;
        logic [1:0]     st_idx;
        logic [2:0]     fu_sel;
    } data_t ;
    
    
    logic   state_rg;        
    logic   valid_rg, ready_rg;    
    logic   ready;    
    data_t  i_data, o_data;         
    
    data_t  temp_data;  
    logic   temp_valid;

    logic   i_ready, i_valid;
    logic   o_ready, o_valid;

    assign i_data.pc        = iq[issue_ptr].pc     ;
    assign i_data.inst      = iq[issue_ptr].inst   ;
    assign i_data.imm       = iq[issue_ptr].imm    ;
    assign i_data.op        = iq[issue_ptr].op     ;
    assign i_data.f3        = iq[issue_ptr].f3     ;
    assign i_data.f7        = iq[issue_ptr].f7     ;
    // assign i_data.rs1_data  = (WB_rd == iq[issue_ptr].P_rs1 && WB_valid) ? WB_data : RR_rs1_data;
    // assign i_data.rs2_data  = (WB_rd == iq[issue_ptr].P_rs2 && WB_valid) ? WB_data : RR_rs2_data;
    assign i_data.P_rd      = iq[issue_ptr].P_rd   ;
    assign i_data.rob_idx   = iq[issue_ptr].rob_idx;
    assign i_data.ld_idx    = iq[issue_ptr].ld_idx ;
    assign i_data.st_idx    = iq[issue_ptr].st_idx ;
    assign i_data.fu_sel    = iq[issue_ptr].fu_sel ;

    always_comb begin
        if(EX_in_valid && EX_in_rd != 7'b0 && EX_in_rd == iq[issue_ptr].P_rs1) begin
            i_data.rs1_data = EX_in_data;
        end 
        else if(WB_valid && WB_rd != 7'b0 && WB_rd == iq[issue_ptr].P_rs1) begin
            i_data.rs1_data = WB_data;
        end 
        else begin
            i_data.rs1_data = RR_rs1_data;
        end

        if(EX_in_valid && EX_in_rd != 7'b0 && EX_in_rd == iq[issue_ptr].P_rs2) begin
            i_data.rs2_data = EX_in_data;
        end 
        else if(WB_valid && WB_rd != 7'b0 && WB_rd == iq[issue_ptr].P_rs2) begin
            i_data.rs2_data = WB_data;
        end 
        else begin
            i_data.rs2_data = RR_rs2_data;
        end
    end
    
    always @(posedge clk) begin
        if (rst) begin      
            temp_data   <= '0;
            temp_valid  <= 1'b0;
        end
        else begin 
            if (mispredict && flush_mask[i_data.rob_idx]) begin
                temp_data   <= '0;
                temp_valid  <= 1'b0;      
            end 
            else begin
                temp_data   <= i_data;
                temp_valid  <= IS_valid && RR_ready;
            end
        end
    end

    logic bypass_rg;
    data_t  data_rg;

    logic [2:0] bypass_fu_sel;
    assign bypass_fu_sel = bypass_rg? temp_data.fu_sel : data_rg.fu_sel;

    always @(posedge clk) begin
        if (rst) begin      
            data_rg   <= '0;     
            bypass_rg <= 1'b1;
        end   
        else begin      
            if (bypass_rg) begin         
                if (!EX_ready[bypass_fu_sel] && temp_valid) begin
                    data_rg   <= temp_data;       
                    bypass_rg <= 1'b0;     
                end 
            end 
            else if (EX_ready[bypass_fu_sel]) begin
                bypass_rg <= 1'b1;           
            end
        end
    end

    assign o_data           = bypass_rg ? temp_data  : data_rg ;       
    assign RR_valid         = bypass_rg ? temp_valid : 1'b1    ;       
    assign RR_ready         = bypass_rg && EX_ready[bypass_fu_sel];

    assign RR_out_pc        = o_data.pc        ;
    assign RR_out_inst      = o_data.inst      ;
    assign RR_out_imm       = o_data.imm       ;
    assign RR_out_op        = o_data.op        ;
    assign RR_out_f3        = o_data.f3        ;
    assign RR_out_f7        = o_data.f7        ;
    assign RR_out_rs1_data  = o_data.rs1_data  ;
    assign RR_out_rs2_data  = o_data.rs2_data  ;
    assign RR_out_rd        = o_data.P_rd      ;
    assign RR_out_rob_idx   = o_data.rob_idx   ;
    assign RR_out_ld_idx    = o_data.ld_idx    ;
    assign RR_out_st_idx    = o_data.st_idx    ;
    assign RR_out_fu_sel    = o_data.fu_sel    ;

    assign writeback_free   = o_data.op == `B_TYPE || o_data.op == `S_TYPE || o_data.op == `FSTORE;

    // konata
    assign IS_out_rob_idx = iq[issue_ptr].rob_idx;
endmodule