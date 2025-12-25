`include "../include/AXI_define.svh"

module DRAM_wrapper (
    input  logic                      clk,
    input  logic                      rstn,

    // --------------------------------------------
    //                Memory ports                 
    // --------------------------------------------
    input  logic [31:0]               DRAM_Q,
    input  logic                      DRAM_valid,
    output logic                      DRAM_CSn,
    output logic [3:0]                DRAM_WEn,
    output logic                      DRAM_RASn,
    output logic                      DRAM_CASn,
    output logic [10:0]               DRAM_A,
    output logic [31:0]               DRAM_D,

    // --------------------------------------------
    //              AXI Slave Interface            
    // --------------------------------------------
    // AR channel
    input  logic [`AXI_IDS_BITS -1:0] ARID_S,
    input  logic [`AXI_DATA_BITS-1:0] ARADDR_S,
    input  logic [`AXI_LEN_BITS -1:0] ARLEN_S,
    input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_S,
    input  logic [1:0]                ARBURST_S,
    input  logic                      ARVALID_S,
    output logic                      ARREADY_S,
    // R channel
    output logic [`AXI_IDS_BITS -1:0] RID_S,
    output logic [`AXI_DATA_BITS-1:0] RDATA_S,
    output logic [1:0]                RRESP_S,
    output logic                      RLAST_S,
    output logic                      RVALID_S,
    input  logic                      RREADY_S,
    // AW channel
    input  logic [`AXI_IDS_BITS -1:0] AWID_S,
    input  logic [`AXI_ADDR_BITS-1:0] AWADDR_S,
    input  logic [`AXI_LEN_BITS -1:0] AWLEN_S,
    input  logic [`AXI_SIZE_BITS-1:0] AWSIZE_S,
    input  logic [1:0]                AWBURST_S,
    input  logic                      AWVALID_S,
    output logic                      AWREADY_S,
    // W channel
    input  logic [`AXI_DATA_BITS-1:0] WDATA_S,
    input  logic [`AXI_STRB_BITS-1:0] WSTRB_S,
    input  logic                      WLAST_S,
    input  logic                      WVALID_S,
    output logic                      WREADY_S,
    // B channel
    output logic [`AXI_IDS_BITS -1:0] BID_S,
    output logic [1:0]                BRESP_S,
    output logic                      BVALID_S,
    input  logic                      BREADY_S
);

    logic [3:0]     counter;
    logic [10:0]    row_reg;
    logic [10:0]    row_addr;
    logic [9:0]     col_addr;
    logic           request;
    logic           r_request;
    logic           w_request;
    logic [3:0]     counter_ad_1;
    logic           counter_eq_4;
    logic           counter_eq_0;
    logic           row_hit;

    assign counter_eq_4     = counter == 4'd4;
    assign counter_eq_0     = counter == 4'd0;
    assign counter_ad_1     = counter + 4'd1;

    typedef enum logic [2:0] {
        ACT,
        READ,
        WRITE,
        PRE
    } state_t;

    state_t cs, ns;

    // ============================================
    //                 AXI Controller
    // ============================================

    logic [20:0]    A;

    typedef enum logic [2:0] {
        IDLE,
        R_MID,
        R_END,
        W_MID,
        W_LAST,
        W_END
    } AXI_state_t;

    AXI_state_t AXI_cs, AXI_ns;

    logic AW_handshake;
    logic W_handshake;
    logic B_handshake;
    logic AR_handshake;
    logic R_handshake;
    logic WLAST_handshake;

    assign AW_handshake = AWVALID_S & AWREADY_S;
    assign W_handshake  = WVALID_S  & WREADY_S;
    assign B_handshake  = BVALID_S  & BREADY_S;
    assign AR_handshake = ARVALID_S & ARREADY_S;
    assign R_handshake  = RVALID_S  & RREADY_S;
    assign WLAST_handshake = W_handshake && WLAST_S;

    // Write FIFO decouples AXI write channel from DRAM command timing
    logic        write_buf_push;
    logic        dram_write_pop;
    logic [9:0]  dram_col_addr;
    logic [3:0]  dram_wstrb;
    logic [10:0] axi_row_addr;
    logic [10:0] write_row_addr;
    localparam int STRB_WIDTH = `AXI_STRB_BITS;
    localparam int COL_WIDTH  = 10;
    localparam int ROW_WIDTH  = 9;
    localparam int STRB_LSB   = 0;
    localparam int STRB_MSB   = STRB_LSB + STRB_WIDTH - 1;
    localparam int COL_LSB    = STRB_MSB + 1;
    localparam int COL_MSB    = COL_LSB + COL_WIDTH - 1;
    localparam int ROW_LSB    = COL_MSB + 1;
    localparam int ROW_MSB    = ROW_LSB + ROW_WIDTH - 1;
    logic [ROW_WIDTH-1:0] axi_row_addr_short;
    logic [COL_WIDTH-1:0] axi_col_addr_short;
    logic [ROW_WIDTH-1:0] write_row_head;
    logic [COL_WIDTH-1:0] write_col_head;
    logic [`AXI_STRB_BITS-1:0] write_strb_head;
    logic [31:0]          write_data_head;
    logic                  write_cmd_pending;
    localparam int         WRITE_FIFO_DEPTH =2;
    localparam int         WRITE_FIFO_PTR_W = (WRITE_FIFO_DEPTH <= 1) ? 1 : $clog2(WRITE_FIFO_DEPTH);
    typedef struct packed {
        logic [ROW_WIDTH-1:0]       row;
        logic [COL_WIDTH-1:0]       col;
        logic [`AXI_STRB_BITS-1:0]  strb;
        logic [31:0]                data;
    } write_entry_t;
    write_entry_t                  write_fifo   [WRITE_FIFO_DEPTH];
    logic [WRITE_FIFO_PTR_W-1:0]   write_wr_ptr;
    logic [WRITE_FIFO_PTR_W-1:0]   write_rd_ptr;
    localparam int         CAS_WAIT_CYCLES = 3'd4;
    localparam int         RAS_WAIT_CYCLES = 3'd4;
    logic [2:0]            cas_cooldown;
    logic [2:0]            ras_cooldown;
    logic                  act_ready;
    logic                  cas_ready;
    logic                  issue_read_cmd;
    logic                  cas_issue;
    logic [31:0]           dram_data_hold;
    logic [11:0]           write_commit_count;
    logic [11:0]           write_resp_pending;

    logic [`AXI_LEN_BITS:0]     burst_len;
    logic [`AXI_ADDR_BITS-1:0]  burst_addr;
    logic [`AXI_IDS_BITS-1:0]   burst_id;
    logic [`AXI_LEN_BITS:0]     burst_count;

    logic [31:0]                AXI_addr;

    assign axi_row_addr_short = A[20:12];
    assign axi_col_addr_short = A[11:2];
    assign axi_row_addr       = { {(11-ROW_WIDTH){1'b0}}, axi_row_addr_short };
    assign write_row_head    = write_fifo[write_rd_ptr].row;
    assign write_col_head    = write_fifo[write_rd_ptr].col;
    assign write_strb_head   = write_fifo[write_rd_ptr].strb;
    assign write_data_head   = write_fifo[write_rd_ptr].data;
    assign dram_wstrb        = write_strb_head;
    assign dram_col_addr     = write_col_head;
    assign write_row_addr    = { {(11-ROW_WIDTH){1'b0}}, write_row_head };

    logic write_fifo_full;

    assign write_fifo_full   = (write_commit_count == WRITE_FIFO_DEPTH);
    assign write_cmd_pending = (write_commit_count != 12'd0);

    assign WREADY_S      = !write_fifo_full;
    assign write_buf_push = WVALID_S & WREADY_S;

/*`ifdef DRAM_WRAPPER_DEBUG
    integer dbg_write_push_cnt;
    integer dbg_write_pop_cnt;
    integer dbg_aw_hs_cnt;
    integer dbg_w_hs_cnt;
    integer dbg_b_hs_cnt;
    always_ff @(posedge clk) begin
        if (!rstn) begin
            dbg_write_push_cnt <= 0;
            dbg_write_pop_cnt  <= 0;
            dbg_aw_hs_cnt      <= 0;
            dbg_w_hs_cnt       <= 0;
            dbg_b_hs_cnt       <= 0;
        end else begin
            if (write_buf_push) begin
                dbg_write_push_cnt <= dbg_write_push_cnt + 1;
                $display("[DRAM_WRAPPER] push @%0t data=%h row=%h col=%h", $time, WDATA_S, axi_row_addr_short, axi_col_addr_short);
            end
            if (dram_write_pop) begin
                dbg_write_pop_cnt  <= dbg_write_pop_cnt + 1;
                $display("[DRAM_WRAPPER] pop  @%0t data=%h row=%h col=%h", $time, write_data_head, write_row_head, write_col_head);
            end
            if (AW_handshake) begin
                dbg_aw_hs_cnt <= dbg_aw_hs_cnt + 1;
                $display("[DRAM_WRAPPER] AW handshake @%0t AXI_cs=%0d", $time, AXI_cs);
            end
            if (W_handshake) begin
                dbg_w_hs_cnt <= dbg_w_hs_cnt + 1;
                $display("[DRAM_WRAPPER] W handshake @%0t AXI_cs=%0d", $time, AXI_cs);
            end
            if (B_handshake) begin
                dbg_b_hs_cnt <= dbg_b_hs_cnt + 1;
                $display("[DRAM_WRAPPER] B handshake @%0t AXI_cs=%0d", $time, AXI_cs);
            end
            if (BVALID_S && !BREADY_S) begin
                $display("[DRAM_WRAPPER] BVALID asserted without BREADY at %0t", $time);
            end
            if (AXI_cs != AXI_ns) begin
                $display("[DRAM_WRAPPER] AXI state %0d -> %0d at %0t", AXI_cs, AXI_ns, $time);
            end
        end
    end

    final begin
        $display("[DRAM_WRAPPER] push=%0d pop=%0d pending_end=%0b aw_hs=%0d w_hs=%0d b_hs=%0d", dbg_write_push_cnt, dbg_write_pop_cnt, write_cmd_pending, dbg_aw_hs_cnt, dbg_w_hs_cnt, dbg_b_hs_cnt);
    end
`endif*/

    always_ff @(posedge clk) begin
        if (!rstn) begin
            AXI_cs <= IDLE;
        end 
        else begin
            AXI_cs <= AXI_ns;
        end
    end

    always_comb begin
        unique case (AXI_cs)
            IDLE  : begin
                priority if(AR_handshake) begin
                    AXI_ns = (ARLEN_S == 4'b0)? R_END : R_MID;
                end
                else if(AW_handshake) begin
                    if (AWLEN_S == 4'b0) begin
                        AXI_ns = (W_handshake) ? W_END : W_LAST;
                    end else begin
                        AXI_ns = W_MID;
                    end
                end
                else begin
                    AXI_ns = IDLE;
                end
            end
            R_MID   : AXI_ns = (R_handshake && burst_count == burst_len)? R_END : R_MID;
            R_END   : AXI_ns = (R_handshake)? IDLE : R_END;
            W_MID   : AXI_ns = (W_handshake && burst_count == burst_len)? W_LAST : W_MID;
            W_LAST  : AXI_ns = (W_handshake)? W_END : W_LAST;
            W_END   : AXI_ns = (B_handshake)? IDLE : W_END;
            default : AXI_ns = IDLE;
        endcase
    end
    
    always_comb begin
        AWREADY_S = 1'b0;
        BVALID_S  = 1'b0;
        BRESP_S   = `AXI_RESP_OKAY;
        BID_S     = burst_id;
        ARREADY_S = 1'b0;
        RVALID_S  = 1'b0;
        RID_S     = burst_id;
        RDATA_S   = DRAM_Q;
        RRESP_S   = `AXI_RESP_OKAY;
        RLAST_S   = 1'b0;
        unique case (AXI_cs)
            IDLE  : begin
                AWREADY_S = 1'b1;
                ARREADY_S = 1'b1;
            end
            R_MID : begin
                RVALID_S  = DRAM_valid;
            end
            R_END : begin
                RVALID_S  = DRAM_valid;
                RLAST_S   = 1'b1;
            end
            W_END : begin
                BVALID_S  = (write_resp_pending != 12'd0);
            end
            default : begin
                // do nothing
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if(!rstn) begin
            burst_count <= 4'b0;
            burst_len   <= 4'b0;
            burst_addr  <= 32'b0;
            burst_id    <= 8'b0;
        end
        else begin
            unique case (AXI_cs)
                IDLE  : begin
                    burst_len   <= (AR_handshake)? ARLEN_S - 4'b1 : AWLEN_S - 4'b1;
                    burst_addr  <= (AR_handshake)? ARADDR_S       : AWADDR_S;
                    burst_id    <= (AR_handshake)? ARID_S         : AWID_S;
                    burst_count <= 4'b0;
                end
                R_MID : begin
                    burst_len   <= burst_len;
                    burst_addr  <= burst_addr;
                    burst_id    <= burst_id;
                    burst_count <= burst_count + {3'b0, R_handshake};
                end
                W_MID : begin
                    burst_len   <= burst_len;
                    burst_addr  <= burst_addr;
                    burst_id    <= burst_id;
                    burst_count <= burst_count + {3'b0, W_handshake};
                end
                default: begin
                    burst_len   <= burst_len;
                    burst_addr  <= burst_addr;
                    burst_id    <= burst_id;   
                    burst_count <= burst_count;  
                end
            endcase
        end
    end

    always_comb begin
		AXI_addr   = burst_addr + {burst_count + {3'b0, R_handshake}, 2'b0};
        if(AXI_cs == IDLE) begin
            A = (AR_handshake)? ARADDR_S[20:0] : AWADDR_S[20:0];
        end
        else begin
            A = AXI_addr[20:0];
        end
    end

    // ============================================
    //               DRAM Controller                
    // ============================================

    assign r_request        = AR_handshake || AXI_ns == R_MID || AXI_ns == R_END;
    assign w_request        = AW_handshake || AXI_ns == W_MID || AXI_ns == W_LAST || write_cmd_pending;
    assign act_ready        = (ras_cooldown == 3'd0);
    assign cas_ready        = (cas_cooldown == 3'd0);
    assign request          = r_request || w_request || (cas_cooldown != 3'd0) || (ras_cooldown != 3'd0);
    assign row_hit          = row_addr == row_reg;
    assign issue_read_cmd   = (cs == READ)  && counter_eq_0 && row_hit && r_request && cas_ready && !write_cmd_pending;
    assign dram_write_pop   = (cs == WRITE) && counter_eq_0 && row_hit && write_cmd_pending && cas_ready;
    assign cas_issue        = issue_read_cmd || dram_write_pop;

    always_ff @(posedge clk) begin
        if (!rstn) begin
            cs <= ACT;
        end 
        else begin
            cs <= ns;
        end
    end

    always_comb begin
        unique case (cs)
            ACT     : begin
                if(counter_eq_4) begin
                    ns = (write_cmd_pending)? WRITE : READ;
                end
                else begin
                    ns = ACT;
                end
            end
            READ    : begin
                if(counter_eq_0) begin
                    if (write_cmd_pending) begin
                        ns = (row_hit) ? WRITE : PRE;
                    end else if (request && !row_hit) begin
                        ns = PRE;
                    end else begin
                        ns = READ;
                    end
                end
                else begin
                    ns = READ;
                end
            end
            WRITE   : begin
                if(counter_eq_0) begin
                    if (write_cmd_pending) begin
                        ns = (row_hit) ? WRITE : PRE;
                    end else if (r_request) begin
                        ns = (row_hit) ? READ : PRE;
                    end else begin
                        ns = WRITE;
                    end
                end
                else begin
                    ns = WRITE;
                end
            end
            PRE     : ns = (counter_eq_4 && act_ready)? ACT : PRE;
            default : ns = ACT;
        endcase
    end

    assign row_addr = write_cmd_pending ? write_row_addr : axi_row_addr;
    assign col_addr = write_cmd_pending ? write_col_head : axi_col_addr_short;
    
    always_ff @(posedge clk) begin
        if(!rstn) begin
            counter <= 4'd0;
        end
        else begin
            unique case (cs)
                ACT: begin
                    if (!request || counter_eq_4) begin
                        counter <= 4'd0;
                    end else begin
                        counter <= counter_ad_1;
                    end
                end
                PRE: begin
                    if (!request) begin
                        counter <= 4'd0;
                    end else if (counter_eq_4 && !act_ready) begin
                        counter <= 4'd4;
                    end else if (counter_eq_4 && act_ready) begin
                        counter <= 4'd0;
                    end else begin
                        counter <= counter_ad_1;
                    end
                end
                default : begin
                    counter <= 4'd0;
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        row_reg <= (cs == ACT)? row_addr : row_reg;
    end

    always_ff @(posedge clk) begin
        if (!rstn) begin
            cas_cooldown <= 3'd0;
        end else if (cas_issue) begin
            cas_cooldown <= CAS_WAIT_CYCLES;
        end else if (cas_cooldown != 3'd0) begin
            cas_cooldown <= cas_cooldown - 3'd1;
        end
    end

    always_ff @(posedge clk) begin
        if (!rstn) begin
            ras_cooldown <= 3'd0;
        end else if (cs == PRE && counter_eq_0) begin
            ras_cooldown <= RAS_WAIT_CYCLES;
        end else if (ras_cooldown != 3'd0) begin
            ras_cooldown <= ras_cooldown - 3'd1;
        end
    end

    always_ff @(posedge clk) begin
        if (!rstn) begin
            dram_data_hold <= 32'b0;
        end else if (dram_write_pop) begin
            dram_data_hold <= write_data_head;
        end
    end

    always_ff @(posedge clk) begin
        if (!rstn) begin
            write_commit_count <= 12'd0;
        end else begin
            unique case ({write_buf_push, dram_write_pop})
                2'b10: write_commit_count <= write_commit_count + 12'd1;
                2'b01: write_commit_count <= (write_commit_count != 12'd0)? write_commit_count - 12'd1 : 12'd0;
                default: write_commit_count <= write_commit_count;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (!rstn) begin
            write_wr_ptr <= '0;
            write_rd_ptr <= '0;
        end else begin
            if (write_buf_push) begin
                write_fifo[write_wr_ptr].row  <= axi_row_addr_short;
                write_fifo[write_wr_ptr].col  <= axi_col_addr_short;
                write_fifo[write_wr_ptr].strb <= WSTRB_S;
                write_fifo[write_wr_ptr].data <= WDATA_S;
                write_wr_ptr <= write_wr_ptr + 1'b1;
            end
            if (dram_write_pop && write_cmd_pending) begin
                write_rd_ptr <= write_rd_ptr + 1'b1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (!rstn) begin
            write_resp_pending <= 12'd0;
        end else begin
            unique case ({WLAST_handshake, B_handshake})
                2'b10: write_resp_pending <= write_resp_pending + 12'd1;
                2'b01: write_resp_pending <= (write_resp_pending != 12'd0)? write_resp_pending - 12'd1 : 12'd0;
                default: write_resp_pending <= write_resp_pending;
            endcase
        end
    end

    /*always_ff @(posedge clk) begin
        if (write_buf_push && axi_row_addr_short == 9'h100 && axi_col_addr_short >= 10'h00d && axi_col_addr_short <= 10'h023) begin
            $display("[DRAM_WRAPPER][PUSH] t=%0t col=%0h data=%0h strb=%0h", $time, axi_col_addr_short, WDATA_S, WSTRB_S);
        end
        if (dram_write_pop && write_row_head == 9'h100 && write_col_head >= 10'h00d && write_col_head <= 10'h023) begin
            $display("[DRAM_WRAPPER][POP ] t=%0t col=%0h data=%0h strb=%0h", $time, write_col_head, write_data_head, write_strb_head);
        end
    end*/

    always_comb begin : DRAM_control
        DRAM_CSn    = 1'b0;
        DRAM_D      = dram_write_pop ? write_data_head : dram_data_hold;
        unique case (cs)
            ACT     : begin
                DRAM_RASn   = !(counter_eq_0 && request);
                DRAM_CASn   = 1'b1;
                DRAM_WEn    = 4'b1111;
                DRAM_A      = row_addr;
            end 
            PRE     : begin
                DRAM_RASn   = !(counter_eq_0);
                DRAM_CASn   = 1'b1;
                DRAM_WEn    = {4{!(counter_eq_0)}};
                DRAM_A      = row_reg;
            end     
            default: begin
                DRAM_RASn   = 1'b1;
                DRAM_CASn   = 1'b1;
                DRAM_WEn    = 4'b1111;
                DRAM_A      = {1'b0, col_addr};
                if (issue_read_cmd) begin
                    DRAM_CASn = 1'b0;
                    DRAM_WEn  = 4'b1111;
                    DRAM_A    = {1'b0, col_addr};
                end else if (dram_write_pop) begin
                    DRAM_CASn = 1'b0;
                    DRAM_WEn  = ~dram_wstrb;
                    DRAM_A    = {1'b0, dram_col_addr};
                end
            end
        endcase
    end

endmodule