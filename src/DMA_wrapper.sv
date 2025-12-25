`include "../include/AXI_define.svh"
`include "DMA/DMA.sv"
`include "DMA/PipelineSkidBuf.sv"
module DMA_wrapper (
    input  logic                      clk,
    input  logic                      rstn,

    // ------------------interrupt------------------
    output logic                      interrupt_o,

    // -------------Communicate with AXI------------
    // AR channel
    output logic [`AXI_ID_BITS  -1:0] ARID_M,
    output logic [`AXI_DATA_BITS-1:0] ARADDR_M,
    output logic [`AXI_LEN_BITS -1:0] ARLEN_M,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M,
    output logic [1:0]                ARBURST_M,
    output logic                      ARVALID_M,
    input  logic                      ARREADY_M,
    // R channel
    input  logic [`AXI_ID_BITS  -1:0] RID_M,
    input  logic [`AXI_DATA_BITS-1:0] RDATA_M,
    input  logic [1:0]                RRESP_M,
    input  logic                      RLAST_M,
    input  logic                      RVALID_M,
    output logic                      RREADY_M,
    // AW channel
    output logic [`AXI_ID_BITS  -1:0] AWID_M,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_M,
    output logic [`AXI_LEN_BITS -1:0] AWLEN_M,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M,
    output logic [1:0]                AWBURST_M,
    output logic                      AWVALID_M,
    input  logic                      AWREADY_M,
    // W channel
    output logic [`AXI_DATA_BITS-1:0] WDATA_M,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_M,
    output logic                      WLAST_M,
    output logic                      WVALID_M,
    input  logic                      WREADY_M,
    // B channel
    input  logic [`AXI_ID_BITS  -1:0] BID_M,
    input  logic [1:0]                BRESP_M,
    input  logic                      BVALID_M,
    output logic                      BREADY_M,

    // ---------------- AXI Slave Interface ----------------
    // AR channel (unused)
    input  logic [`AXI_IDS_BITS -1:0] ARID_S,
    input  logic [`AXI_ADDR_BITS-1:0] ARADDR_S,
    input  logic [`AXI_LEN_BITS -1:0] ARLEN_S,
    input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_S,
    input  logic [1:0]                ARBURST_S,
    input  logic                      ARVALID_S,
    output logic                      ARREADY_S,
    // R channel (unused)
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
    //-----------------------------------------------------
    //          Slave: for DMAEN and DESC_BASE
    //-----------------------------------------------------
    logic [1:0] dma_state;
    typedef enum logic[1:0] {
        ADDR        = 2'b0,
        WRITE_DATA  = 2'b1,
        WRITE_RESP  = 2'd2
    } slave_state_t;
    slave_state_t slave_cs;
    slave_state_t slave_ns;
    logic aw_hask_S;
    logic wd_hask_S;
    logic wb_hask_S;
    assign aw_hask_S = AWVALID_S   & AWREADY_S;
    assign wd_hask_S = WVALID_S    & WREADY_S;
    assign wb_hask_S = BVALID_S    & BREADY_S;
    logic dma_ready;
    logic [`AXI_ADDR_BITS-1:0] AWADDR_S_reg;
    always_ff @(posedge clk) begin
        if(!rstn)begin
            AWADDR_S_reg <= `AXI_ADDR_BITS'b0;
        end else begin
            if(slave_cs == ADDR && aw_hask_S)begin
                AWADDR_S_reg <= AWADDR_S;
            end
        end
    end
    always_ff @(posedge clk) begin
        if(!rstn)begin
            slave_cs <= ADDR;
        end else begin
            slave_cs <= slave_ns;
        end
    end
    always_comb begin
        case (slave_cs)
            ADDR:       begin
                slave_ns = (aw_hask_S)? WRITE_DATA : ADDR;
            end
            WRITE_DATA: begin
                slave_ns = (wd_hask_S && WLAST_S)? WRITE_RESP:WRITE_DATA;
            end
            WRITE_RESP: begin
                slave_ns = (wb_hask_S)? ADDR: WRITE_RESP;
            end
            default: slave_ns = ADDR;
        endcase
    end
    assign AWREADY_S = (slave_cs == ADDR) & (dma_state == 2'b0 || dma_state == 2'd3);
    assign BVALID_S = (slave_cs == WRITE_RESP);
    assign WREADY_S = (slave_cs == WRITE_DATA)?dma_ready:1'b0;
    


    //-----------------------------------------------------
    //     Read Master: Read descriptors and move data
    //-----------------------------------------------------
    logic ar_hask_M;
    logic rd_hask_M;
    assign ar_hask_M = ARVALID_M    & ARREADY_M;
    assign rd_hask_M = RVALID_M     & RREADY_M;
    typedef enum logic [2:0] {
        IDLE                = 3'd0,
        DECRI_ADDR          = 3'd1,
        DECRI_READ_DATA     = 3'd2,
        MOVE_ADDR           = 3'd3,
        MOVE_READ_DATA      = 3'd4
    } master_r_state_t;
    master_r_state_t master_r_cs;
    master_r_state_t master_r_ns;
    logic [`AXI_DATA_BITS-1:0] read_addr_start;
    logic [`AXI_DATA_BITS-1:0] read_addr_end;
    logic [`AXI_ADDR_BITS - 1:0] addr_reg_master_r_q;
    logic [`AXI_ADDR_BITS - 1:0] addr_reg_master_r_d;
    logic [`AXI_LEN_BITS - 1:0] LEN_master_r_q;
    logic [`AXI_LEN_BITS - 1:0] LEN_master_r_d;
    logic [`AXI_DATA_BITS-1:0] descr_addr;
    logic descr_ready;
    logic read_da_ready;
    always_ff@(posedge clk) begin
        if(!rstn)begin
            master_r_cs <= IDLE;
        end else begin
            master_r_cs <= master_r_ns;
        end
    end
    always_comb begin
        case (master_r_cs)
            IDLE           : begin
                master_r_ns = (dma_state == 2'd1)?  DECRI_ADDR : IDLE;
            end
            DECRI_ADDR     : begin
                master_r_ns = (ar_hask_M)? DECRI_READ_DATA : DECRI_ADDR;
            end
            DECRI_READ_DATA: begin
                master_r_ns = (rd_hask_M && RLAST_M)? MOVE_ADDR : DECRI_READ_DATA;
            end
            MOVE_ADDR      : begin
                master_r_ns = (ar_hask_M)? MOVE_READ_DATA : MOVE_ADDR;
            end
            MOVE_READ_DATA : begin
                if(rd_hask_M && RLAST_M)begin
                    if(addr_reg_master_r_q + (({28'b0, LEN_master_r_q}+32'b1)<<2) == read_addr_end)begin
                        master_r_ns = IDLE;
                    end else begin
                        master_r_ns = MOVE_ADDR;
                    end
                end else begin
                    master_r_ns = MOVE_READ_DATA;
                end
            end
            default: master_r_ns = IDLE;
        endcase
    end
    // LEN reg
    always_ff @(posedge clk) begin
        if(!rstn)begin
            LEN_master_r_q <= `AXI_LEN_BITS'b0;
        end else begin
            LEN_master_r_q <= LEN_master_r_d;
        end
    end
    logic [`AXI_LEN_BITS - 1:0] remain_RLEN;
    assign remain_RLEN = ((read_addr_end - addr_reg_master_r_d) >> 2) - 32'b1;
    always_comb begin
        if(master_r_ns == DECRI_ADDR)begin
            LEN_master_r_d = `AXI_LEN_BITS'd4;
        end else if(master_r_cs == MOVE_READ_DATA && master_r_ns == MOVE_ADDR)begin
            if(addr_reg_master_r_d + `AXI_ADDR_BITS'd64 < read_addr_end)begin
                LEN_master_r_d = `AXI_LEN_BITS'd15;
            end else begin
                LEN_master_r_d = remain_RLEN;
            end
        end else if(master_r_cs == DECRI_READ_DATA && master_r_ns == MOVE_ADDR)begin
            if(addr_reg_master_r_d + `AXI_ADDR_BITS'd64 < read_addr_end)begin
                LEN_master_r_d = `AXI_LEN_BITS'd15;
            end else begin
                LEN_master_r_d = remain_RLEN;
            end
        end else begin
            LEN_master_r_d = LEN_master_r_q;
        end
    end

    // ADDR reg
    always_ff @(posedge clk) begin
        if(!rstn)begin
            addr_reg_master_r_q <= `AXI_ADDR_BITS'b0;
        end else begin
            addr_reg_master_r_q <= addr_reg_master_r_d;
        end
    end
    always_comb begin
        if(master_r_ns == DECRI_ADDR)begin
            addr_reg_master_r_d = descr_addr;
        end else if(master_r_cs == DECRI_READ_DATA && master_r_ns == MOVE_ADDR)begin
            addr_reg_master_r_d = read_addr_start;
        end else if(master_r_cs == MOVE_READ_DATA && master_r_ns == MOVE_ADDR)begin
            addr_reg_master_r_d = addr_reg_master_r_q + (({28'b0, LEN_master_r_q} + 32'b1)<<2);
        end else begin
            addr_reg_master_r_d = addr_reg_master_r_q;
        end
    end
    assign ARID_M = `AXI_ID_BITS'b0;
    assign ARADDR_M = addr_reg_master_r_q;
    assign ARLEN_M = LEN_master_r_q;
    assign ARSIZE_M = `AXI_SIZE_WORD;
    assign ARBURST_M = `AXI_BURST_INC;
    assign ARVALID_M = (master_r_cs == DECRI_ADDR || master_r_cs == MOVE_ADDR);
    assign RREADY_M = descr_ready | read_da_ready;



    //-----------------------------------------------------
    //              Write Master: Move data
    //-----------------------------------------------------
    logic aw_hask_M;
    logic wd_hask_M;
    logic wb_hask_M;
    assign aw_hask_M = AWVALID_M & AWREADY_M;
    assign wd_hask_M = WVALID_M & WREADY_M;
    assign wb_hask_M = BVALID_M & BREADY_M;
    typedef enum logic [1:0] {
        IDLE_W      = 2'd0,
        ADDR_W        = 2'd1,
        WRITE_DATA_W  = 2'd2,
        WRITE_RESP_W  = 2'd3
    } master_w_state_t;
    master_w_state_t master_w_cs;
    master_w_state_t master_w_ns;
    
    logic [`AXI_ADDR_BITS-1:0] write_addr_start;
    logic [`AXI_ADDR_BITS-1:0] write_addr_end;
    logic [`AXI_ADDR_BITS - 1:0] addr_reg_master_w_q;
    logic [`AXI_ADDR_BITS - 1:0] addr_reg_master_w_d;
    logic [`AXI_LEN_BITS - 1:0] LEN_master_w_q;
    logic [`AXI_LEN_BITS - 1:0] LEN_master_w_d;
    always_ff@(posedge clk) begin
        if(!rstn)begin
            master_w_cs <= IDLE_W;
        end else begin
            master_w_cs <= master_w_ns;
        end
    end
    always_comb begin
        case (master_w_cs)
            IDLE_W      : begin
                master_w_ns = (dma_state == 2'd2)?  ADDR_W : IDLE_W;
            end
            ADDR_W      : begin
                master_w_ns = (aw_hask_M)?  WRITE_DATA_W : ADDR_W;
            end
            WRITE_DATA_W: begin
                master_w_ns = (wd_hask_M && WLAST_M)?  WRITE_RESP_W : WRITE_DATA_W;
            end
            WRITE_RESP_W: begin
                if(wb_hask_M)begin
                    if(addr_reg_master_w_q + (({28'b0, LEN_master_w_q}+32'b1)<<2) == write_addr_end)begin
                        master_w_ns = IDLE_W;
                    end else begin
                        master_w_ns = ADDR_W;
                    end
                end else begin
                    master_w_ns = WRITE_RESP_W;
                end
            end
        endcase
    end

    // LEN reg
    always_ff @(posedge clk) begin
        if(!rstn)begin
            LEN_master_w_q <= `AXI_LEN_BITS'b0;
        end else begin
            LEN_master_w_q <= LEN_master_w_d;
        end
    end
    logic [`AXI_LEN_BITS - 1:0] remain_WLEN;
    assign remain_WLEN = ((write_addr_end - addr_reg_master_w_d) >> 2) - 32'b1;
    always_comb begin
        if(master_w_cs == WRITE_RESP_W && master_w_ns == ADDR_W)begin
            if(addr_reg_master_w_d + `AXI_ADDR_BITS'd64 < write_addr_end)begin
                LEN_master_w_d = `AXI_LEN_BITS'd15;
            end else begin
                LEN_master_w_d = remain_WLEN;
            end
        end else if(master_w_cs == IDLE_W && master_w_ns == ADDR_W)begin
            if(addr_reg_master_w_d + `AXI_ADDR_BITS'd64 < write_addr_end)begin
                LEN_master_w_d = `AXI_LEN_BITS'd15;
            end else begin
                LEN_master_w_d = remain_WLEN;
            end
        end else begin
            LEN_master_w_d = LEN_master_w_q;
        end
    end

    // ADDR reg
    always_ff @(posedge clk) begin
        if(!rstn)begin
            addr_reg_master_w_q <= `AXI_ADDR_BITS'b0;
        end else begin
            addr_reg_master_w_q <= addr_reg_master_w_d;
        end
    end
    always_comb begin
        if(master_w_cs == IDLE_W && master_w_ns == ADDR_W)begin
            addr_reg_master_w_d = write_addr_start;
        end else if(master_w_cs == WRITE_RESP_W && master_w_ns == ADDR_W) begin
            addr_reg_master_w_d = addr_reg_master_w_q + (({28'b0, LEN_master_w_q} + 32'b1) << 2);
        end else begin
            addr_reg_master_w_d = addr_reg_master_w_q;
        end
    end

    // Used for WLAST_M
    logic [`AXI_LEN_BITS -1:0] cnt;
    always_ff @(posedge clk) begin
        if(!rstn)begin
            cnt <= `AXI_LEN_BITS'b0;
        end else begin
            if(master_w_cs == ADDR_W)begin
                cnt <= AWLEN_M;
            end else if(master_w_cs == WRITE_DATA_W)begin
                if(wd_hask_M)begin
                    cnt <= cnt - `AXI_LEN_BITS'b1;
                end
            end
        end
    end
    assign AWID_M = `AXI_ID_BITS'b0;
    assign AWADDR_M = addr_reg_master_w_q;
    assign AWLEN_M = LEN_master_w_q;
    assign AWSIZE_M = `AXI_SIZE_WORD;
    assign AWBURST_M = `AXI_BURST_INC;
    assign AWVALID_M = (master_w_cs == ADDR_W);
    assign WSTRB_M = 4'hf;                      //! 1 for not pass?
    assign WLAST_M = (cnt == 0);
    
    assign BREADY_M = (master_w_cs == WRITE_RESP_W);


    DMA dma(
        .clk(clk),
        .rstn(rstn),
        .dma_state(dma_state),

        .dma_valid(WVALID_S && slave_cs == WRITE_DATA),
        .dma_ready(dma_ready),
        .dma_addr(AWADDR_S_reg),
        .dma_data(WDATA_S),
        .interrupt(interrupt_o),

        .descr_valid(RVALID_M),
        .descr_ready(descr_ready),
        .descr_addr(descr_addr),
        .descr_data(RDATA_M),

        .read_da_valid(RVALID_M && master_r_cs == MOVE_READ_DATA),
        .read_da_ready(read_da_ready),
        .read_addr_start(read_addr_start),
        .read_addr_end(read_addr_end),
        .read_da(RDATA_M),

        .write_da_ready(WREADY_M),
        .write_da_valid(WVALID_M),
        .write_addr_start(write_addr_start),
        .write_addr_end(write_addr_end),
        .write_da(WDATA_M)
    );

    // Write only, if get read request, return decode error.
    assign RID_S        = `AXI_IDS_BITS'b0;
    assign RDATA_S      = `AXI_DATA_BITS'b0;
    assign RRESP_S      = `AXI_RESP_DECERR;
    assign RLAST_S      = 1'b1;
    assign RVALID_S     = 1'b1;
    assign ARREADY_S    = 1'b1;
endmodule