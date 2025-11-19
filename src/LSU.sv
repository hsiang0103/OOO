module LSU (
    input   logic           clk,
    input   logic           rst,
    // Dispatch 
    input   logic [2:0]     DC_fu_sel,  
    input   logic [6:0]     DC_rd, 
    input   logic [2:0]     DC_rob_idx,
    input   logic           decode_valid, 
    // EX stage
    input   logic           ld_i_valid,
    input   logic           st_i_valid,
    input   logic [2:0]     lsu_i_rob_idx,
    input   logic [31:0]    lsu_i_rs1_data,
    input   logic [31:0]    lsu_i_rs2_data,
    input   logic [31:0]    lsu_i_imm,
    input   logic           RR_valid,
    input   logic [1:0]     EX_ld_idx,
    input   logic [1:0]     EX_st_idx,
    input   logic           ld_i_ready,
    output  logic           ld_o_valid,
    output  logic [2:0]     ld_o_rob_idx,
    output  logic [6:0]     ld_o_rd,
    output  logic [31:0]    ld_o_data,
    // Commit
    input   logic           ld_commit, // commit LQ head
    input   logic           st_commit, // commit SQ head
    // mispredict
    input   logic           mispredict,
    input   logic [7:0]     flush_mask,
    input   logic [1:0]     mis_ld_idx,
    input   logic [1:0]     mis_st_idx,
    // DM
    input   logic [31:0]    DM_rd_data,
    output  logic           DM_c_en,
    output  logic           DM_r_en,
    output  logic [31:0]    DM_w_en,
    output  logic [31:0]    DM_addr,
    output  logic [31:0]    DM_w_data,
    // ROB
    output  logic [1:0]     LQ_tail,
    output  logic [1:0]     SQ_tail,
    // DC - LSU handshake
    output  logic           ld_ready,
    output  logic           st_ready
);
    typedef struct packed {
        logic [31:0]    addr;
        logic [31:0]    data;
        logic [2:0]     rob_idx;
        logic           valid;
        logic           issued;
    } SQ_entry;

    typedef struct packed {
        logic [31:0]    addr;
        logic [1:0]     SQ_t;
        logic [6:0]     rd;
        logic [2:0]     rob_idx;
        logic           valid;
        logic           issued;
        logic           done;
    } LQ_entry;

    SQ_entry SQ [0:3];
    LQ_entry LQ [0:3];
    logic [1:0] SQ_h, SQ_t;
    logic [1:0] LQ_h, LQ_t;
    logic DC_ld, DC_st;
    logic EX_ld, EX_st;
     
    assign ld_ready         = !(LQ_t == LQ_h && LQ[LQ_h].valid); 
    assign st_ready         = !(SQ_t == SQ_h && SQ[SQ_h].valid); 
    assign DC_ld            = DC_fu_sel == 6 && decode_valid; 
    assign DC_st            = DC_fu_sel == 7 && decode_valid; 
    assign EX_ld            = ld_i_valid && RR_valid;
    assign EX_st            = st_i_valid && RR_valid;
    assign LQ_tail          = LQ_t;
    assign SQ_tail          = SQ_t;

    // Load handle
    logic [3:0] can_request;
    logic [3:0] age_mask [0:3];
    logic [3:0] sq_addr_cmp [0:3];
    logic [1:0] LQ_order [0:3];

    logic [1:0] load_request_idx;
    logic       load_request_valid;

    always_comb begin
        for(int i = 0; i < 4; i = i + 1) begin
            for(int j = 0; j < 4; j = j + 1) begin
                if(LQ[i].valid) begin
                    if(LQ[i].SQ_t >= SQ_h) begin
                        age_mask[i][j] = (j < LQ[i].SQ_t) && (j >= SQ_h);
                    end
                    else begin
                        age_mask[i][j] = (j < LQ[i].SQ_t) || (j >= SQ_h);
                    end
                end
                else begin
                    age_mask[i][j] = 0;
                end
                sq_addr_cmp[i][j] = SQ[j].valid && (!SQ[j].issued || SQ[j].addr == LQ[i].addr);
            end
        end

        for(int i = 0; i < 4; i = i + 1) begin
            can_request[i] = ((sq_addr_cmp[i] & age_mask[i]) == 4'b0000) && LQ[i].issued && !LQ[i].done;
        end

        for(int i = 0; i < 4; i = i + 1) begin
            LQ_order[i] = (LQ_h + i) & 2'b11; // max
        end

        priority case(1'b1)
            can_request[LQ_order[0]]: load_request_idx = LQ_order[0];
            can_request[LQ_order[1]]: load_request_idx = LQ_order[1];
            can_request[LQ_order[2]]: load_request_idx = LQ_order[2];
            can_request[LQ_order[3]]: load_request_idx = LQ_order[3];
            default: load_request_idx = 2'b00;
        endcase
        load_request_valid = |can_request;
    end

    // DM interface
    assign DM_r_en          = !st_commit;               // read when not commit
    assign DM_w_en          = {32{!st_commit}};         // bit write enable
    assign DM_addr          = DM_r_en ? LQ[load_request_idx].addr : SQ[SQ_h].addr;
    assign DM_w_data        = SQ[SQ_h].data;
    assign DM_c_en          = 1'b0;                     // always enable 

    logic load_done;
    logic [1:0] load_request_idx_reg;
    // LSU output to EXE stage
    always_ff @(posedge clk) begin
        load_done               <= load_request_valid && !st_commit;
        load_request_idx_reg    <= load_request_idx;
    end
    assign ld_o_data        = DM_rd_data;
    assign ld_o_rob_idx     = LQ[load_request_idx_reg].rob_idx;
    assign ld_o_rd          = LQ[load_request_idx_reg].rd;
    assign ld_o_valid       = load_done;

    // LQ and SQ management
    always_ff @(posedge clk) begin
        if(rst) begin
            for(int i = 0; i < 4; i = i + 1) begin
                SQ[i] <= 0;
                LQ[i] <= 0;
            end
            SQ_h <= 2'b0;
            SQ_t <= 2'b0;
            LQ_h <= 2'b0;
            LQ_t <= 2'b0;
        end
        else begin
            // =============
            // LQ management
            // =============
            for(int i = 0; i < 4; i = i + 1) begin : LQ_operation
                // Dispatch
                if(DC_ld && ld_ready && i == LQ_t) begin
                    LQ[i].SQ_t      <= SQ_t;
                    LQ[i].valid     <= 1'b1;
                    LQ[i].rd        <= DC_rd;
                    LQ[i].rob_idx   <= DC_rob_idx;
                end
                // Issue
                if(EX_ld && i == EX_ld_idx) begin
                    LQ[i].issued    <= 1'b1;
                    LQ[i].addr      <= lsu_i_rs1_data[31:0] + lsu_i_imm[31:0];
                end
                // Execute 
                if(load_request_valid && i == load_request_idx && !st_commit) begin
                    LQ[i].done  <= 1'b1;
                end
                // Commit
                if(ld_commit && i == LQ_h) begin
                    LQ[i]       <= '0;
                end 
                // Mispredict
                if(mispredict && flush_mask[LQ[i].rob_idx]) begin
                    LQ[i]       <= '0;
                end
            end

            if(mispredict) begin
                LQ_t <= mis_ld_idx;
            end
            else if(DC_ld && ld_ready) begin
                LQ_t <= LQ_t + 1;
            end

            if(ld_commit) begin
                LQ_h <= LQ_h + 1;
            end

            // =============
            // SQ management
            // =============
            for(int i = 0; i < 4; i = i + 1) begin : SQ_operation
                // Dispatch
                if(DC_st && st_ready && i == SQ_t) begin
                    SQ[i].valid  <= 1'b1;
                    SQ[i].rob_idx   <= DC_rob_idx;
                end
                // Issue
                if(EX_st && i == EX_st_idx) begin
                    SQ[i].issued    <= 1'b1;
                    SQ[i].addr      <= lsu_i_rs1_data[31:0] + lsu_i_imm[31:0];
                    SQ[i].data      <= lsu_i_rs2_data;
                end
                // Commit
                if(st_commit && i == SQ_h) begin
                    SQ[i]       <= '0;
                end 
                // Mispredict
                if(mispredict && flush_mask[SQ[i].rob_idx]) begin
                    SQ[i]       <= '0;
                end
            end

            if(mispredict) begin
                SQ_t <= mis_st_idx;
            end
            else if(DC_st && st_ready) begin
                SQ_t <= SQ_t + 1;
            end

            if(st_commit) begin 
                SQ_h <= SQ_h + 1;
            end
        end
    end
endmodule