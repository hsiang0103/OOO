module LSU (
    input   logic           clk,
    input   logic           rst,
    // dispatch 
    input   logic [2:0]     DC_fu_sel,  
    input   logic [6:0]     DC_rd, 
    input   logic [2:0]     DC_rob_idx,
    input   logic           decode_valid, 
    output  logic           ld_ready,
    output  logic           st_ready,
    // data
    input   logic [31:0]    lsu_i_rs1_data,
    input   logic [31:0]    lsu_i_rs2_data,
    input   logic [31:0]    lsu_i_imm,
    input   logic [2:0]     funct3,
    // control
    input   logic           ld_i_valid,
    input   logic           st_i_valid,
    input   logic [2:0]     lsu_i_rob_idx,
    input   logic [1:0]     EX_ld_idx,
    input   logic [1:0]     EX_st_idx,
    output  logic           ld_o_valid,
    output  logic [2:0]     ld_o_rob_idx,
    output  logic [6:0]     ld_o_rd,
    output  logic [31:0]    ld_o_data,
    // commit
    input   logic           ld_commit,
    input   logic           st_commit,
    // mispredict
    input   logic           mispredict,
    input   logic [7:0]     flush_mask,
    input   logic [1:0]     mis_ld_idx,
    input   logic [1:0]     mis_st_idx,
    // DM interface
    input   logic [31:0]    DM_rd_data,
    output  logic           DM_r_en,
    output  logic [31:0]    DM_w_en,
    output  logic [31:0]    DM_addr,
    output  logic [31:0]    DM_w_data,
    // ROB
    output  logic [1:0]     LQ_tail,
    output  logic [1:0]     SQ_tail
);
    typedef struct packed {
        logic [31:0]    addr;
        logic [31:0]    data;
        logic [2:0]     rob_idx;
        logic [2:0]     f3;
        logic           valid;
        logic           issued;
    } SQ_entry;

    typedef struct packed {
        logic [31:0]    addr;
        logic [1:0]     SQ_t;
        logic [6:0]     rd;
        logic [2:0]     rob_idx;
        logic [2:0]     f3;
        logic           valid;
        logic           issued;
        logic           done;
    } LQ_entry;

    SQ_entry SQ [0:3];
    LQ_entry LQ [0:3];
    logic [1:0] SQ_h, SQ_t;
    logic [1:0] LQ_h, LQ_t;
    logic DC_ld, DC_st;
     
    assign ld_ready         = !(LQ_t == LQ_h && LQ[LQ_h].valid); // LQ not full
    assign st_ready         = !(SQ_t == SQ_h && SQ[SQ_h].valid); // SQ not full
    assign DC_ld            = DC_fu_sel == 6 && decode_valid; 
    assign DC_st            = DC_fu_sel == 7 && decode_valid; 
    assign LQ_tail          = LQ_t;
    assign SQ_tail          = SQ_t;

    // ================
    // load select
    // ================
    logic [3:0] can_request;
    logic [3:0] age_mask    [0:3];
    logic [3:0] sq_addr_cmp [0:3];
    logic [1:0] LQ_order    [0:3];
    logic [1:0] load_request_idx;
    logic       load_request_valid;

    always_comb begin
        // check younger store in SQ
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
            LQ_order[i]     = (LQ_h + i) & 2'b11;
            // can request if no younger store with different address
            can_request[i]  = ((sq_addr_cmp[i] & age_mask[i]) == 4'b0000) && LQ[i].issued && !LQ[i].done;
        end

        priority case(1'b1)
            can_request[LQ_order[0]]: load_request_idx = LQ_order[0];
            can_request[LQ_order[1]]: load_request_idx = LQ_order[1];
            can_request[LQ_order[2]]: load_request_idx = LQ_order[2];
            can_request[LQ_order[3]]: load_request_idx = LQ_order[3];
            default:                  load_request_idx = 2'b00;
        endcase
        load_request_valid = |can_request;
        // TODO : forwarding logic
    end

    // ================
    // load output
    // ================
    logic       load_done;
    logic [1:0] load_request_idx_r;
    always_ff @(posedge clk) begin
        if(rst) begin
            load_done           <= 1'b0;
            load_request_idx_r  <= 2'b0;
        end
        else begin
            load_done           <= load_request_valid && !st_commit;
            load_request_idx_r  <= load_request_idx;
        end    
    end

    always_comb begin
        ld_o_rob_idx    = LQ[load_request_idx_r].rob_idx;
        ld_o_rd         = LQ[load_request_idx_r].rd;
        ld_o_valid      = load_done;
        case (LQ[load_request_idx_r].f3)
            `LB:        ld_o_data = {{24{DM_rd_data[7]}}, DM_rd_data[7:0]};
            `LBU:       ld_o_data = {24'b0, DM_rd_data[7:0]};
            `LH:        ld_o_data = {{16{DM_rd_data[15]}}, DM_rd_data[15:0]};
            `LHU:       ld_o_data = {16'b0, DM_rd_data[15:0]};
            `LW:        ld_o_data = DM_rd_data;
            default:    ld_o_data = DM_rd_data;
        endcase
    end

    // ================
    // DM interface
    // ================
    assign DM_r_en          = !st_commit;   // read when store not commit
    assign DM_addr          = !st_commit? LQ[load_request_idx].addr : SQ[SQ_h].addr;

    always_comb begin
        case (SQ[SQ_h].f3)
            `SB: begin
                case (SQ[SQ_h].addr[1:0])
                    2'b00:   DM_w_en = 32'hFFFFFF00;
                    2'b01:   DM_w_en = 32'hFFFF00FF;
                    2'b10:   DM_w_en = 32'hFF00FFFF;
                    2'b11:   DM_w_en = 32'h00FFFFFF;
                endcase
            end
            `SH:begin
                case (SQ[SQ_h].addr[1])
                    1'b0:    DM_w_en = 32'hFFFF0000;
                    1'b1:    DM_w_en = 32'h0000FFFF;
                endcase
            end
            `SW:             DM_w_en = 32'h00000000;
            default:         DM_w_en = 32'hFFFFFFFF;
        endcase
    end

    always_comb begin
        case (SQ[SQ_h].f3)
            `SB: begin
                case (SQ[SQ_h].addr[1:0])
                    2'b00:   DM_w_data = {24'b0, SQ[SQ_h].data[7:0]};
                    2'b01:   DM_w_data = {16'b0, SQ[SQ_h].data[7:0], 8'b0};
                    2'b10:   DM_w_data = {8'b0, SQ[SQ_h].data[7:0], 16'b0};
                    2'b11:   DM_w_data = {SQ[SQ_h].data[7:0], 24'b0};
                endcase
            end
            `SH:begin
                case (SQ[SQ_h].addr[1])
                    1'b0:    DM_w_data = {16'b0, SQ[SQ_h].data[15:0]};
                    1'b1:    DM_w_data = {SQ[SQ_h].data[15:0], 16'b0};
                endcase
            end
            `SW:             DM_w_data = SQ[SQ_h].data;
            default:         DM_w_data = 32'h0;
        endcase
    end

    // ================
    // LQ management
    // ================

    // LQ pointers
    always_ff @(posedge clk) begin
        if(rst) begin
            LQ_h <= 2'b0;
            LQ_t <= 2'b0;
        end
        else begin
            // mispredict
            if(mispredict) begin
                LQ_t <= mis_ld_idx;
            end
            // dispatch
            else if(DC_ld && ld_ready) begin
                LQ_t <= LQ_t + 1;
            end
            else begin
                LQ_t <= LQ_t;
            end

            // commit
            LQ_h <= LQ_h + ld_commit;
        end
    end

    // LQ
    always_ff @(posedge clk) begin
        if(rst) begin
            for(int i = 0; i < 4; i = i + 1) begin
                LQ[i] <= 0;
            end
        end
        else begin
            for(int i = 0; i < 4; i = i + 1) begin : LQ_operation
                // Mispredict
                if(mispredict && flush_mask[LQ[i].rob_idx]) begin
                    LQ[i]       <= '0;
                end
                else begin
                    unique case (1'b1)
                        // dispatch
                        DC_ld && ld_ready && i == LQ_t: begin
                            LQ[i].SQ_t      <= SQ_t;
                            LQ[i].valid     <= 1'b1;
                            LQ[i].rd        <= DC_rd;
                            LQ[i].rob_idx   <= DC_rob_idx;
                        end
                        // execute
                        ld_i_valid && i == EX_ld_idx: begin
                            LQ[i].issued    <= 1'b1;
                            LQ[i].f3        <= funct3;
                            LQ[i].addr      <= lsu_i_rs1_data[31:0] + lsu_i_imm[31:0];
                        end
                        // issue load request
                        load_request_valid && i == load_request_idx && !st_commit: begin
                            LQ[i].done  <= 1'b1;
                        end
                        // commit
                        ld_commit && i == LQ_h: begin
                            LQ[i]       <= '0;
                        end 
                        default: LQ[i]  <= LQ[i];
                    endcase
                end
            end
        end
    end

    // ================
    // SQ management
    // ================

    // SQ pointers  
    always_ff @(posedge clk) begin
        if(rst) begin
            SQ_h <= 2'b0;
            SQ_t <= 2'b0;
        end
        else begin
            // mispredict
            if(mispredict) begin
                SQ_t <= mis_st_idx;
            end
            // dispatch
            else if(DC_st && st_ready) begin
                SQ_t <= SQ_t + 1;
            end
            else begin
                SQ_t <= SQ_t;
            end

            // commit
            SQ_h <= SQ_h + st_commit;
        end
    end

    // SQ
    always_ff @(posedge clk) begin
        if(rst) begin
            for(int i = 0; i < 4; i = i + 1) begin
                SQ[i] <= 0;
            end
        end
        else begin
            for(int i = 0; i < 4; i = i + 1) begin : SQ_operation
                if(mispredict) begin
                    SQ[i]       <= '0;
                end
                else begin
                    unique case (1'b1)
                        // dispatch
                        DC_st && st_ready && i == SQ_t: begin
                            SQ[i].valid     <= 1'b1;
                            SQ[i].rob_idx   <= DC_rob_idx;
                        end
                        // issue
                        st_i_valid && i == EX_st_idx: begin
                            SQ[i].issued    <= 1'b1;
                            SQ[i].addr      <= lsu_i_rs1_data[31:0] + lsu_i_imm[31:0];
                            SQ[i].data      <= lsu_i_rs2_data;
                            SQ[i].f3        <= funct3;
                        end
                        // commit
                        st_commit && i == SQ_h: begin
                            SQ[i]       <= '0;
                        end 
                        default: SQ[i]  <= SQ[i];
                    endcase
                end
            end
        end
    end
endmodule