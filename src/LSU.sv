module LSU (
    input   logic           clk,
    input   logic           rst,
    // dispatch 
    input   logic [2:0]     DC_fu_sel,  
    input   logic [6:0]     DC_rd, 
    input   logic [$clog2(`ROB_LEN)-1:0]     DC_rob_idx,
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
    input   logic [$clog2(`ROB_LEN)-1:0]     lsu_i_rob_idx,
    input   logic [$clog2(`LQ_LEN):0] EX_ld_idx,
    input   logic [$clog2(`SQ_LEN):0] EX_st_idx,
    output  logic           ld_o_valid,
    output  logic [$clog2(`ROB_LEN)-1:0]     ld_o_rob_idx,
    output  logic [6:0]     ld_o_rd,
    output  logic [31:0]    ld_o_data,
    // commit
    input   logic           ld_commit,
    input   logic           st_commit,
    output  logic [31:0]    st_addr,
    output  logic [31:0]    st_data,
    // mispredict
    input   logic           mispredict,
    input   logic [`ROB_LEN-1:0]     flush_mask,
    input   logic [$clog2(`LQ_LEN):0] mis_ld_idx,
    input   logic [$clog2(`SQ_LEN):0] mis_st_idx,
    // DM interface
    output  logic [31:0]    ld_st_req_addr,
    input   logic           store_data_valid,
    output  logic [3:0]     store_strb,
    output  logic [31:0]    store_data,
    output  logic           store_req_valid,
    input   logic           store_req_ready,
    input   logic           load_data_valid,
    input   logic [31:0]    load_data,
    output  logic           load_req_valid,
    input   logic           load_req_ready,
    // ROB
    output  logic [$clog2(`LQ_LEN):0] LQ_tail,
    output  logic [$clog2(`SQ_LEN):0] SQ_tail
);
    typedef struct packed {
        logic [31:0]    addr;
        logic [31:0]    data;
        logic [$clog2(`ROB_LEN)-1:0]     rob_idx;
        logic [2:0]     f3;
        logic           valid;
        logic           issued;
        logic           committed;
    } SQ_entry;

    typedef struct packed {
        logic [31:0]    addr;
        logic [$clog2(`SQ_LEN):0] SQ_t;
        logic [6:0]     rd;
        logic [$clog2(`ROB_LEN)-1:0]     rob_idx;
        logic [2:0]     f3;
        logic           valid;
        logic           issued;
        logic           done;
    } LQ_entry;

    SQ_entry SQ [0:`SQ_LEN-1];
    LQ_entry LQ [0:`LQ_LEN-1];
    logic [$clog2(`SQ_LEN):0] SQ_h, SQ_t, SQ_ptr;
    logic [$clog2(`LQ_LEN):0] LQ_h, LQ_t;
    logic DC_ld, DC_st;

    logic [$clog2(`SQ_LEN):0] commit_cnt;
    logic store_handshake;
    logic load_handshake;
    logic [$clog2(`SQ_LEN):0] st_commit_idx;

    logic ld_inflight;           
    logic [$clog2(`LQ_LEN)-1:0] ld_inflight_idx;
    
    assign ld_ready         = !(LQ_t[$clog2(`LQ_LEN)-1:0] == LQ_h[$clog2(`LQ_LEN)-1:0] && LQ_t[$clog2(`LQ_LEN)] != LQ_h[$clog2(`LQ_LEN)]); // LQ not full
    assign st_ready         = !(SQ_t[$clog2(`SQ_LEN)-1:0] == SQ_h[$clog2(`SQ_LEN)-1:0] && SQ_t[$clog2(`SQ_LEN)] != SQ_h[$clog2(`SQ_LEN)]); // SQ not full
    assign DC_ld            = DC_fu_sel == 6 && decode_valid; 
    assign DC_st            = DC_fu_sel == 7 && decode_valid; 
    assign LQ_tail          = LQ_t;
    assign SQ_tail          = SQ_t;

    assign st_commit_idx    = (SQ_h[$clog2(`SQ_LEN)-1:0] + commit_cnt) & (`SQ_LEN-1);
    assign st_addr          = SQ[st_commit_idx].addr;
    // assign st_data          = SQ[st_commit_idx].data;

    // ================
    // load select
    // ================
    logic [`LQ_LEN-1:0] can_request;
    logic [`SQ_LEN-1:0] age_mask    [0:`LQ_LEN-1];
    logic [`SQ_LEN-1:0] sq_addr_cmp [0:`LQ_LEN-1];
    logic [$clog2(`LQ_LEN)-1:0] LQ_order    [0:`LQ_LEN-1];
    logic [$clog2(`LQ_LEN)-1:0] load_request_idx;
    logic       load_request_valid;
    logic       same_phase;

    always_comb begin
        // check younger store in SQ
        for(int i = 0; i < `LQ_LEN; i = i + 1) begin
            same_phase = (SQ_h[$clog2(`SQ_LEN)] == LQ[i].SQ_t[$clog2(`SQ_LEN)]);
            for(int j = 0; j < `SQ_LEN; j = j + 1) begin
                if(LQ[i].valid) begin
                    if (same_phase) begin
                        age_mask[i][j] = (j >= SQ_h[$clog2(`SQ_LEN)-1:0]) && (j < LQ[i].SQ_t[$clog2(`SQ_LEN)-1:0]);
                    end
                    else begin
                        age_mask[i][j] = (j >= SQ_h[$clog2(`SQ_LEN)-1:0]) || (j < LQ[i].SQ_t[$clog2(`SQ_LEN)-1:0]);
                    end
                end
                else begin
                    age_mask[i][j] = 0;
                end
                sq_addr_cmp[i][j] = SQ[j].valid && (!SQ[j].issued || SQ[j].addr[31:2] == LQ[i].addr[31:2]);
            end
            LQ_order[i]     = (LQ_h + i) & {($clog2(`LQ_LEN)){1'b1}};
            // can request if no younger store with different address
            can_request[i]  = ((sq_addr_cmp[i] & age_mask[i]) == '0) && LQ[i].issued && !LQ[i].done;
        end

        load_request_idx = '0;
        for (int i = 0; i < `LQ_LEN; i++) begin
            if (can_request[LQ_order[i]]) begin
                load_request_idx = LQ_order[i];
                break;
            end
        end
        load_request_valid = |can_request;
        // TODO : forwarding logic
    end

    logic [1:0]  addr_offset;
    logic [7:0]  target_byte;
    logic [15:0] target_half;

    assign addr_offset   = LQ[ld_inflight_idx].addr[1:0];

    assign ld_o_rob_idx  = LQ[ld_inflight_idx].rob_idx;
    assign ld_o_rd       = LQ[ld_inflight_idx].rd;

    always_comb begin
        case (addr_offset)
            2'b00: target_byte = load_data[7:0];
            2'b01: target_byte = load_data[15:8];
            2'b10: target_byte = load_data[23:16];
            2'b11: target_byte = load_data[31:24];
        endcase

        case (addr_offset[1])
            1'b0: target_half = load_data[15:0];
            1'b1: target_half = load_data[31:16];
        endcase

        case (LQ[ld_inflight_idx].f3)
            `LB:     ld_o_data = {{24{target_byte[7]}}, target_byte}; 
            `LBU:    ld_o_data = {24'b0, target_byte};                
            `LH:     ld_o_data = {{16{target_half[15]}}, target_half};
            `LHU:    ld_o_data = {16'b0, target_half};                
            default: ld_o_data = load_data;
        endcase
    end

    always_comb begin
        unique case (SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].f3)
            `SB: begin
                case (SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].addr[1:0])
                    2'b00:  store_strb = 4'b1110;
                    2'b01:  store_strb = 4'b1101;
                    2'b10:  store_strb = 4'b1011;
                    2'b11:  store_strb = 4'b0111;
                endcase
            end
            `SH:begin
                case (SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].addr[1:0])
                    2'b00:  store_strb = 4'b1100;
                    2'b10:  store_strb = 4'b0011;
                endcase
            end
            `SW:            store_strb = 4'b0000;
            default:        store_strb = 4'b1111;
        endcase
    end

    always_comb begin
        unique case (SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].f3)
            `SB: begin
                case (SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].addr[1:0])
                    2'b00:  store_data = {24'b0, SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].data[7:0]};
                    2'b01:  store_data = {16'b0, SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].data[7:0], 8'b0};
                    2'b10:  store_data = {8'b0, SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].data[7:0], 16'b0};
                    2'b11:  store_data = {SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].data[7:0], 24'b0};
                endcase
            end
            `SH:begin
                case (SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].addr[1:0])
                    2'b00:  store_data = {16'b0, SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].data[15:0]};
                    2'b10:  store_data = {SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].data[15:0], 16'b0};
                endcase
            end
            default:        store_data = SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].data;
        endcase
    end

    always_comb begin
        unique case (SQ[st_commit_idx].f3)
            `SB: begin
                case (SQ[st_commit_idx].addr[1:0])
                    2'b00:  st_data = {24'b0, SQ[st_commit_idx].data[7:0]};
                    2'b01:  st_data = {16'b0, SQ[st_commit_idx].data[7:0], 8'b0};
                    2'b10:  st_data = {8'b0, SQ[st_commit_idx].data[7:0], 16'b0};
                    2'b11:  st_data = {SQ[st_commit_idx].data[7:0], 24'b0};
                endcase
            end
            `SH:begin
                case (SQ[st_commit_idx].addr[1:0])
                    2'b00:  st_data = {16'b0, SQ[st_commit_idx].data[15:0]};
                    2'b10:  st_data = {SQ[st_commit_idx].data[15:0], 16'b0};
                endcase
            end
            default:        st_data = SQ[st_commit_idx].data;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            commit_cnt <= '0;
        end 
        else begin
            commit_cnt <= commit_cnt + st_commit - store_handshake;
        end
    end

    assign store_req_valid = (commit_cnt > 0);
    assign store_handshake = store_req_valid && store_req_ready;
    assign load_handshake  = load_req_valid && load_req_ready;
    assign load_req_valid = load_request_valid && !store_req_valid && !ld_inflight;

    assign ld_st_req_addr = store_handshake ? SQ[SQ_h[$clog2(`SQ_LEN)-1:0]].addr : LQ[load_request_idx].addr;

    always_ff @(posedge clk) begin
        if (rst) begin
            ld_inflight         <= 1'b0;
            ld_inflight_idx     <= '0;
        end else begin
            if (load_handshake) begin
                ld_inflight     <= 1'b1;
                ld_inflight_idx <= load_request_idx;
            end 
            else if (load_data_valid) begin
                ld_inflight <= 1'b0;
            end
        end
    end

    // ================
    // Load Output Generation
    // ================
    

    
    assign ld_o_valid = load_data_valid;
    // ================
    // LQ management
    // ================

    // LQ pointers
    always_ff @(posedge clk) begin
        if(rst) begin
            LQ_h <= '0;
            LQ_t <= '0;
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
            for(int i = 0; i < `LQ_LEN; i = i + 1) begin
                LQ[i] <= 0;
            end
        end
        else begin
            for(int i = 0; i < `LQ_LEN; i = i + 1) begin : LQ_operation
                // Mispredict
                if(mispredict && flush_mask[LQ[i].rob_idx]) begin
                    LQ[i]       <= '0;
                end
                else begin
                    unique case (1'b1)
                        // dispatch
                        DC_ld && ld_ready && i == LQ_t[$clog2(`LQ_LEN)-1:0]: begin
                            LQ[i].SQ_t      <= SQ_t;
                            LQ[i].valid     <= 1'b1;
                            LQ[i].rd        <= DC_rd;
                            LQ[i].rob_idx   <= DC_rob_idx;
                        end
                        // execute
                        ld_i_valid && i == EX_ld_idx[$clog2(`LQ_LEN)-1:0]: begin
                            LQ[i].issued    <= 1'b1;
                            LQ[i].f3        <= funct3;
                            LQ[i].addr      <= lsu_i_rs1_data[31:0] + lsu_i_imm[31:0];
                        end
                        // issue load request
                        
                        load_handshake && i == load_request_idx && !st_commit: begin
                            LQ[i].done  <= 1'b1;
                        end
                        // commit
                        ld_commit && i == LQ_h[$clog2(`LQ_LEN)-1:0]: begin
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
            SQ_ptr  <= '0;
            SQ_h    <= '0;
            SQ_t    <= '0;
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

            // commit
            SQ_h    <= SQ_h + store_handshake;
            SQ_ptr  <= SQ_ptr + st_commit;
        end
    end

    // SQ
    always_ff @(posedge clk) begin
        if(rst) begin
            for(int i = 0; i < `SQ_LEN; i = i + 1) begin
                SQ[i] <= 0;
            end
        end
        else begin
            for(int i = 0; i < `SQ_LEN; i = i + 1) begin : SQ_operation
                if(mispredict && flush_mask[SQ[i].rob_idx] && !SQ[i].committed) begin
                    SQ[i]       <= '0;
                end
                else begin
                    unique case (1'b1)
                        // dispatch
                        DC_st && st_ready && i == SQ_t[$clog2(`SQ_LEN)-1:0]: begin
                            SQ[i].valid     <= 1'b1;
                            SQ[i].rob_idx   <= DC_rob_idx;
                        end
                        // issue
                        st_i_valid && i == EX_st_idx[$clog2(`SQ_LEN)-1:0]: begin
                            SQ[i].issued    <= 1'b1;
                            SQ[i].addr      <= lsu_i_rs1_data[31:0] + lsu_i_imm[31:0];
                            SQ[i].data      <= lsu_i_rs2_data;
                            SQ[i].f3        <= funct3;
                        end
                        // commit
                        st_commit && i == (SQ_ptr[$clog2(`SQ_LEN)-1:0]): begin
                            SQ[i].committed <= 1'b1;
                        end
                        store_handshake && i == SQ_h[$clog2(`SQ_LEN)-1:0]: begin
                            SQ[i]       <= '0;
                        end 
                        default: SQ[i]  <= SQ[i];
                    endcase
                end
            end
        end
    end
endmodule