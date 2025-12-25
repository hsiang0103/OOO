`include "../include/AXI_define.svh"
`include "../src/WDT/WDT.sv"
`include "../src/WDT/AsyncFIFO2.sv"

module WDT_wrapper (
    input  logic                      clk_m,
    input  logic                      rstn_m,
    input  logic                      clk_s,
    input  logic                      rstn_s,

    // ------------------interrupt------------------
    output logic                      interrupt_o,

    // -------------Communicate with AXI------------
    // AR channel
    input  logic [`AXI_IDS_BITS -1:0] ARID_S,
    input  logic [`AXI_ADDR_BITS-1:0] ARADDR_S,
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
    typedef enum logic [1:0] {
        ADDR        = 2'b0,
        WRITE_DATA  = 2'b1,
        WRITE_RESP  = 2'd2
    } state_t;

    typedef enum logic [1:0] {
        WDEN_T        = 2'd0,
        WDLIVE_T      = 2'd1,
        WTOCNT_T      = 2'd2
    } which_port;
    which_port port_type;
    
    state_t cs;
    state_t ns;

    logic aw_hask;
    logic wd_hask;
    logic wb_hask;
    assign aw_hask = AWVALID_S  & AWREADY_S;
    assign wd_hask = WVALID_S   & WREADY_S;
    assign wb_hask = BVALID_S   & BREADY_S;


    always_ff @(posedge clk_m) begin
        if(!rstn_m)begin
            cs <= ADDR;
        end else begin
            cs <= ns;
        end
    end
    always_comb begin
        case (cs)
            ADDR      :begin
                ns = (aw_hask)?((wd_hask && WLAST_S)?WRITE_RESP:WRITE_DATA):ADDR;
            end
            WRITE_DATA:begin
                ns = (wd_hask && WLAST_S)? WRITE_RESP:WRITE_DATA;
            end
            WRITE_RESP:begin
                ns = (wb_hask)?ADDR:WRITE_RESP;
            end
            default: ns = ADDR;
        endcase
    end
    assign AWREADY_S = (cs == ADDR);
    assign BVALID_S = (cs == WRITE_RESP);
    assign BRESP_S = `AXI_RESP_OKAY;
    assign BID_S = `AXI_IDS_BITS'b0;


    always_comb begin
        if(cs == ADDR && aw_hask)begin
            case (AWADDR_S)
                32'h1001_0100: port_type = WDEN_T;
                32'h1001_0200: port_type = WDLIVE_T;
                32'h1001_0300: port_type = WTOCNT_T;
                default:port_type = WDEN_T;
            endcase
        end else begin
            port_type = WDEN_T;
        end
    end

    logic WDEN_fifo_push_w;
    logic WDEN_fifo_full_w;

    logic WDEN_fifo_pop_r;
    logic WDEN_fifo_empty_r;
    logic WDEN;
    assign WDEN_fifo_push_w = WVALID_S && port_type ==  WDEN_T;
    AsyncFIFO2 #(.DATA_WIDTH(1)) WDEN_fifo(
        .clk_w(clk_m),
        .rstn_w(rstn_m),
        .push_w(WDEN_fifo_push_w),           // valid_i
        .full_w(WDEN_fifo_full_w),           // !ready_o
        .data_in(WDATA_S[0]),

        .clk_r(clk_s),
        .rstn_r(rstn_s),
        .pop_r(WDEN_fifo_pop_r),             // ready_i
        .empty_r(WDEN_fifo_empty_r),         // !valid_o
        .data_out(WDEN)
    );

    logic WDLIVE_fifo_push_w;
    logic WDLIVE_fifo_full_w;

    logic WDLIVE_fifo_pop_r;
    logic WDLIVE_fifo_empty_r;
    logic WDLIVE;
    assign WDLIVE_fifo_push_w = WVALID_S && port_type == WDLIVE_T;
    AsyncFIFO2 #(.DATA_WIDTH(1)) WDLIVE_fifo(
        .clk_w(clk_m),
        .rstn_w(rstn_m),
        .push_w(WDLIVE_fifo_push_w),            // valid_i
        .full_w(WDLIVE_fifo_full_w),            // !ready_o
        .data_in(WDATA_S[0]),

        .clk_r(clk_s),
        .rstn_r(rstn_s),
        .pop_r(WDLIVE_fifo_pop_r),              // ready_i
        .empty_r(WDLIVE_fifo_empty_r),          // !valid_o
        .data_out(WDLIVE)
    );

    logic WTOCNT_fifo_push_w;
    logic WTOCNT_fifo_full_w;

    logic WTOCNT_fifo_pop_r;
    logic WTOCNT_fifo_empty_r;
    logic [31:0] WTOCNT;
    assign WTOCNT_fifo_push_w = WVALID_S && port_type == WTOCNT_T;
    AsyncFIFO2 #(.DATA_WIDTH(32)) WTOCNT_fifo(
        .clk_w(clk_m),
        .rstn_w(rstn_m),
        .push_w(WTOCNT_fifo_push_w),            // valid_i
        .full_w(WTOCNT_fifo_full_w),            // !ready_o
        .data_in(WDATA_S),

        .clk_r(clk_s),
        .rstn_r(rstn_s),
        .pop_r(WTOCNT_fifo_pop_r),              // ready_i
        .empty_r(WTOCNT_fifo_empty_r),          // !valid_o
        .data_out(WTOCNT)
    );

    always_comb begin
        case (port_type)
            WDEN_T:   begin
                WREADY_S = ~WDEN_fifo_full_w;
            end
            WDLIVE_T: begin
                WREADY_S = ~WDLIVE_fifo_full_w;
            end
            WTOCNT_T: begin
                WREADY_S = ~WTOCNT_fifo_full_w;
            end
            default: WREADY_S = 1'b0;
        endcase
    end

    logic interrupt;
    logic interrupt_valid;
    logic interrupt_ready;
    logic interrupt_fifo_full_w;
    assign interrupt_ready = ~interrupt_fifo_full_w;
    WDT wdt(
        .clk(clk_s),
        .rstn(rstn_s),

        .WDEN_valid(~WDEN_fifo_empty_r),
        .WDEN_ready(WDEN_fifo_pop_r),
        .WDEN(WDEN),

        .WDLIVE_valid(~WDLIVE_fifo_empty_r),
        .WDLIVE_ready(WDLIVE_fifo_pop_r),
        .WDLIVE(WDLIVE),

        .WTOCNT_valid(~WTOCNT_fifo_empty_r),
        .WTOCNT_ready(WTOCNT_fifo_pop_r),
        .WTOCNT(WTOCNT),

        .interrupt_valid(interrupt_valid),
        .interrupt_ready(interrupt_ready),
        .interrupt(interrupt)
    );

    logic interrupt_q;
    logic interrupt_d;
    logic interrupt_fifo_empty_r;
    AsyncFIFO2 #(.DATA_WIDTH(1)) interrupt_fifo(
        .clk_w(clk_s),
        .rstn_w(rstn_s),
        .push_w(interrupt_valid),            // valid_i
        .full_w(interrupt_fifo_full_w),      // !ready_o
        .data_in(interrupt),

        .clk_r(clk_m),
        .rstn_r(rstn_m),
        .pop_r(1'b1),                           // ready_i
        .empty_r(interrupt_fifo_empty_r),       // !valid_o
        .data_out(interrupt_d)
    );

    logic interrupt_fifo_empty_r_delay;
    always_ff @(posedge clk_m) begin
        if(!rstn_m)begin
            interrupt_q <= 1'b0;
            interrupt_fifo_empty_r_delay <= 1'b0;
        end else begin
            interrupt_q <= (!interrupt_fifo_empty_r_delay)? interrupt_d:interrupt_q;
            interrupt_fifo_empty_r_delay <= interrupt_fifo_empty_r;
        end
    end
    assign interrupt_o = interrupt_q;


    // Write only, if get read request, return decode error.
    assign RID_S        = `AXI_IDS_BITS'b0;
    assign RDATA_S      = `AXI_DATA_BITS'b0;
    assign RRESP_S      = `AXI_RESP_DECERR;
    assign RLAST_S      = 1'b1;
    assign RVALID_S     = 1'b1;
    assign ARREADY_S    = 1'b1;
endmodule