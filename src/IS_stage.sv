module IS_stage (
    input clk,
    input rst,
    // DC stage
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
    input   logic [$clog2(`ROB_LEN)-1:0]     IS_in_rob_idx,
    input   logic [$clog2(`LQ_LEN):0] IS_in_LQ_tail,
    input   logic [$clog2(`SQ_LEN):0] IS_in_SQ_tail,
    input   logic           IS_in_jump,
    input   logic           DC_valid,
    // rename 
    input   logic           IS_in_rs1_valid,
    input   logic           IS_in_rs2_valid,
    // IS stage
    output  logic           IS_valid,
    output  logic           IS_ready,
    output  logic [$clog2(`ROB_LEN)-1:0]     IS_out_rob_idx,
    // EX stage
    output  logic [31:0]    RR_out_pc,
    output  logic [31:0]    RR_out_inst, 
    output  logic [31:0]    RR_out_imm,
    output  logic [31:0]    RR_out_rs1_data,
    output  logic [31:0]    RR_out_rs2_data,
    output  logic [4:0]     RR_out_op,
    output  logic [2:0]     RR_out_f3,
    output  logic [6:0]     RR_out_f7,
    output  logic [2:0]     RR_out_fu_sel,
    output  logic [$clog2(`LQ_LEN):0] RR_out_ld_idx,
    output  logic [$clog2(`SQ_LEN):0] RR_out_st_idx,
    output  logic [$clog2(`ROB_LEN)-1:0]     RR_out_rob_idx, 
    output  logic [6:0]     RR_out_rd,
    output  logic           RR_out_jump,
    output  logic           RR_ready,
    output  logic           RR_valid,
    input   logic [7:0]     EX_ready,
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
    input   logic [`ROB_LEN-1:0]     flush_mask
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
        logic [$clog2(`LQ_LEN):0] ld_idx;
        logic [$clog2(`SQ_LEN):0] st_idx;
        logic [2:0]     fu_sel;
        logic [$clog2(`ROB_LEN)-1:0]     rob_idx;
        logic           valid;
        logic           jump;
    } IS_data_t;

    IS_data_t iq [0:`IQ_LEN-1];
    logic [$clog2(`IQ_LEN)-1:0] dispatch_ptr;
    logic [$clog2(`IQ_LEN)-1:0] issue_ptr;
    logic [`IQ_LEN-1:0] rs1_valid, rs2_valid;

    logic [`IQ_LEN-1:0] age [0:`IQ_LEN-1];

    logic [`IQ_LEN-1:0] iq_valid;
    always_comb begin
        for (int i = 0; i < `IQ_LEN; i++) iq_valid[i] = iq[i].valid;
    end
    assign IS_ready = !(&iq_valid);

    logic [`IQ_LEN-1:0] req_vec;   
    logic [`IQ_LEN-1:0] grant_vec; 

    always_comb begin
        dispatch_ptr = '0;
        for (int i = 0; i < `IQ_LEN; i++) begin
            if (!iq[i].valid) begin
                dispatch_ptr = i[$clog2(`IQ_LEN)-1:0];
                break;
            end
        end

        for(int i = 0; i < `IQ_LEN; i = i + 1) begin
            rs1_valid[i] = iq[i].P_rs1_valid || (iq[i].P_rs1 == WB_rd && WB_valid) || (iq[i].P_rs1 == EX_in_rd && EX_in_valid);
            rs2_valid[i] = iq[i].P_rs2_valid || (iq[i].P_rs2 == WB_rd && WB_valid) || (iq[i].P_rs2 == EX_in_rd && EX_in_valid);
        end

        for (int i = 0; i < `IQ_LEN; i++) begin
            req_vec[i] = iq[i].valid && rs1_valid[i] && rs2_valid[i] && EX_ready[iq[i].fu_sel];
        end

        grant_vec = req_vec; 
        
        for (int i = 0; i < `IQ_LEN; i++) begin
            for (int j = 0; j < `IQ_LEN; j++) begin
                if (i != j) begin
                    if (req_vec[j] && age[j][i]) begin
                        grant_vec[i] = 1'b0;
                    end
                end
            end
        end

        IS_valid = |grant_vec; 
        
        issue_ptr = '0;
        for (int i = 0; i < `IQ_LEN; i++) begin
            if (grant_vec[i]) begin
                issue_ptr = i[$clog2(`IQ_LEN)-1:0];
                break;
            end
        end
    end

    // =================
    // Age Matrix Update
    // =================
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < `IQ_LEN; i = i + 1) begin
                age[i] <= '0;
            end
        end
        else begin
            if (DC_valid && !iq[dispatch_ptr].valid) begin
                for (int i = 0; i < `IQ_LEN; i++) begin
                    if (iq[i].valid) begin
                        age[i][dispatch_ptr] <= 1'b1;
                    end

                    age[dispatch_ptr][i] <= 1'b0;
                end
            end
        end
    end

    // ======================
    // Issue Queue Management
    // ======================
    always_ff @(posedge clk) begin
        if(rst) begin
            for (int i = 0; i < `IQ_LEN; i = i + 1) begin : initialize_iq
                iq[i]   <= '0;
            end
        end
        else begin
            for(int i = 0; i < `IQ_LEN; i = i + 1) begin : update_iq
                // mispredict
                if(mispredict && flush_mask[iq[i].rob_idx]) begin
                    iq[i]   <= '0;
                end
                // issue
                else if (issue_ptr == i && IS_valid && RR_ready) begin
                    iq[i]   <= '0;
                end
                else if (iq[i].valid) begin
                    if (EX_in_valid && EX_in_rd != 7'b0) begin
                        iq[i].P_rs1_valid   <= (iq[i].P_rs1 == EX_in_rd)? 1'b1 : iq[i].P_rs1_valid;
                        iq[i].P_rs2_valid   <= (iq[i].P_rs2 == EX_in_rd)? 1'b1 : iq[i].P_rs2_valid;
                    end
                    if (WB_valid && WB_rd != 7'b0) begin
                        iq[i].P_rs1_valid   <= (iq[i].P_rs1 == WB_rd)? 1'b1 : iq[i].P_rs1_valid;
                        iq[i].P_rs2_valid   <= (iq[i].P_rs2 == WB_rd)? 1'b1 : iq[i].P_rs2_valid;
                    end
                end
                else if (DC_valid && IS_ready && dispatch_ptr == i) begin
                    iq[i].valid       <= 1'b1;
                    iq[i].pc          <= IS_in_pc;
                    iq[i].inst        <= IS_in_inst;
                    iq[i].imm         <= IS_in_imm;
                    iq[i].op          <= IS_in_op;
                    iq[i].f3          <= IS_in_f3;
                    iq[i].f7          <= IS_in_f7;
                    iq[i].P_rs1       <= IS_in_rs1;
                    iq[i].P_rs2       <= IS_in_rs2;
                    iq[i].P_rd        <= IS_in_rd;
                    iq[i].ld_idx      <= IS_in_LQ_tail;
                    iq[i].st_idx      <= IS_in_SQ_tail;
                    iq[i].fu_sel      <= IS_in_fu_sel;
                    iq[i].rob_idx     <= IS_in_rob_idx;
                    iq[i].jump        <= IS_in_jump;
                    iq[i].P_rs1_valid <= IS_in_rs1_valid || 
                                         (IS_in_rs1 == WB_rd && WB_valid) || 
                                         (IS_in_rs1 == EX_in_rd && EX_in_valid);
                                         
                    iq[i].P_rs2_valid <= IS_in_rs2_valid || 
                                         (IS_in_rs2 == WB_rd && WB_valid) || 
                                         (IS_in_rs2 == EX_in_rd && EX_in_valid);
                end
                else begin
                    iq[i]   <= iq[i];
                end
            end
        end
    end

    // Register Read
    logic [31:0] RR_rs1_data, RR_rs2_data;
    RegFile R1 (
        .clk            (clk),
        .rst            (rst),
        // read
        .rs1_index      (iq[issue_ptr].P_rs1),
        .rs2_index      (iq[issue_ptr].P_rs2),
        .rs1_data_out   (RR_rs1_data),
        .rs2_data_out   (RR_rs2_data),
        // write
        .wb_en          (WB_valid),
        .wb_data        (WB_data),
        .rd_index       (WB_rd)
    );

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
        logic [$clog2(`ROB_LEN)-1:0]     rob_idx;
        logic [$clog2(`LQ_LEN):0] ld_idx;
        logic [$clog2(`SQ_LEN):0] st_idx;
        logic [2:0]     fu_sel;
        logic           jump;
    } data_t ;
    
    data_t  i_data, o_data, temp_data;         
    logic   temp_valid;

    assign i_data.pc        = iq[issue_ptr].pc     ;
    assign i_data.inst      = iq[issue_ptr].inst   ;
    assign i_data.imm       = iq[issue_ptr].imm    ;
    assign i_data.op        = iq[issue_ptr].op     ;
    assign i_data.f3        = iq[issue_ptr].f3     ;
    assign i_data.f7        = iq[issue_ptr].f7     ;
    assign i_data.P_rd      = iq[issue_ptr].P_rd   ;
    assign i_data.rob_idx   = iq[issue_ptr].rob_idx;
    assign i_data.ld_idx    = iq[issue_ptr].ld_idx ;
    assign i_data.st_idx    = iq[issue_ptr].st_idx ;
    assign i_data.fu_sel    = iq[issue_ptr].fu_sel ;
    assign i_data.jump      = iq[issue_ptr].jump   ;
    assign IS_out_rob_idx   = iq[issue_ptr].rob_idx;

    // Forwarding data selection
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
    
    // =================
    // Pipeline register
    // =================
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

    // ===============
    // skid buffer
    // ===============

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
    assign RR_out_jump      = o_data.jump      ;
    assign writeback_free   = o_data.op == `B_TYPE || o_data.op == `S_TYPE || o_data.op == `FSTORE;
endmodule