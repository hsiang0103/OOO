`include "../include/AXI_define.svh"
module ROM_wrapper (
    input clk,
    input rstn,

    // -------------Communicate with ROM------------
    input [`AXI_DATA_BITS - 1 : 0]  DO,
    output                          OE,
    output                          CS,
    output [11 : 0]                 A,
    
    // -------------Communicate with AXI------------
    // AR
    input  logic [`AXI_IDS_BITS -1:0] ARID_S,
    input  logic [`AXI_ADDR_BITS-1:0] ARADDR_S,
    input  logic [`AXI_LEN_BITS -1:0] ARLEN_S,
    input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_S,
    input  logic [1:0]                ARBURST_S,
    input  logic                      ARVALID_S,
    output logic                      ARREADY_S,
    // R
    output logic [`AXI_IDS_BITS -1:0] RID_S,
    output logic [`AXI_DATA_BITS-1:0] RDATA_S,
    output logic [1:0]                RRESP_S,
    output logic                      RLAST_S,
    output logic                      RVALID_S,
    input  logic                      RREADY_S,
    // AW
    input  logic [`AXI_IDS_BITS -1:0] AWID_S,
    input  logic [`AXI_ADDR_BITS-1:0] AWADDR_S,
    input  logic [`AXI_LEN_BITS -1:0] AWLEN_S,
    input  logic [`AXI_SIZE_BITS-1:0] AWSIZE_S,
    input  logic [1:0]                AWBURST_S,
    input  logic                      AWVALID_S,
    output logic                      AWREADY_S,
    // W
    input  logic [`AXI_DATA_BITS-1:0] WDATA_S,
    input  logic [`AXI_STRB_BITS-1:0] WSTRB_S,
    input  logic                      WLAST_S,
    input  logic                      WVALID_S,
    output logic                      WREADY_S,
    // B
    output logic [`AXI_IDS_BITS -1:0] BID_S,
    output logic [1:0]                BRESP_S,
    output logic                      BVALID_S,
    input  logic                      BREADY_S
);
    logic ar_hask;
    logic rd_hask;
    logic aw_hask;
    logic wd_hask;
    logic wb_hask;

    assign ar_hask = ARVALID_S  & ARREADY_S;
    assign rd_hask = RVALID_S   & RREADY_S;
    assign aw_hask = AWVALID_S  & AWREADY_S;
    assign wd_hask = WVALID_S   & WREADY_S;
    assign wb_hask = BVALID_S   & BREADY_S;

    typedef enum logic {
        ADDR        = 1'b0,
        READ_DATA   = 1'b1
    } state_t;
    state_t cs;
    state_t ns;
    always_ff @(posedge clk) begin
        if(!rstn)begin
            cs <= ADDR;
        end else begin
            cs <= ns;
        end
    end
    always_comb begin
        case (cs)
            ADDR:       ns = (ar_hask)? READ_DATA : ADDR;
            READ_DATA : ns = (rd_hask && RLAST_S)? ADDR : READ_DATA;
        endcase
    end

    typedef struct packed {
        logic                       read_write; // 0: read, 1: write
        logic [`AXI_IDS_BITS -1:0]  ID;
        logic [`AXI_ADDR_BITS-1:0]  ADDR;
        logic [`AXI_LEN_BITS -1:0]  LEN;
        logic [`AXI_SIZE_BITS-1:0]  SIZE;
        logic [1:0]                 BURST;
    } request_t;
    request_t request_reg;
    always_ff @(posedge clk) begin
        if(!rstn)begin
            request_reg.read_write  <= 1'b0;
            request_reg.ID          <= `AXI_IDS_BITS'b0;
            request_reg.ADDR        <= `AXI_ADDR_BITS'b0;
            request_reg.LEN         <= `AXI_LEN_BITS'b0;
            request_reg.SIZE        <= `AXI_SIZE_BITS'b0;
            request_reg.BURST       <= 2'b0;
        end else begin
            if(cs == ADDR)begin
                if(ARVALID_S)begin
                    request_reg.read_write  <= 1'b0;
                    request_reg.ID          <= ARID_S;
                    //request_reg.ADDR        <= ARADDR_S + `AXI_ADDR_BITS'd1; // word address input
                    request_reg.ADDR        <= ARADDR_S + `AXI_ADDR_BITS'd4; // byte address input
                    request_reg.LEN         <= ARLEN_S;
                    request_reg.SIZE        <= ARSIZE_S;
                    request_reg.BURST       <= ARBURST_S;
                end else if(AWVALID_S)begin
                    request_reg.read_write  <= 1'b1;
                    request_reg.ID          <= AWID_S;
                    request_reg.ADDR        <= AWADDR_S;
                    request_reg.LEN         <= AWLEN_S;
                    request_reg.SIZE        <= AWSIZE_S;
                    request_reg.BURST       <= AWBURST_S;
                end
            end else if(cs == READ_DATA)begin
                if(rd_hask)begin
                    // request_reg.ADDR <= request_reg.ADDR + `AXI_ADDR_BITSd1; // word address input
                    request_reg.ADDR <= request_reg.ADDR + `AXI_ADDR_BITS'd4; // byte address input
                    request_reg.LEN <= request_reg.LEN - `AXI_LEN_BITS'b1;
                end
            end
        end
    end

    logic output_sel;
    always_ff @(posedge clk) begin
        if(!rstn)begin
            output_sel <= 1'b0;
        end else begin
            if(cs == ADDR && ns == READ_DATA)begin
                output_sel <= 1'b0;
            end else if(cs == READ_DATA)begin
                if(rd_hask)begin
                    output_sel <= 1'b0;
                end else begin
                    output_sel <= 1'b1;
                end
            end
        end
    end
    logic [`AXI_DATA_BITS - 1 : 0]rom_skid_buf;
    always_ff @(posedge clk) begin
        if(!rstn)begin
            rom_skid_buf <= `AXI_DATA_BITS'b0;
        end else begin
            if(!output_sel)begin
                rom_skid_buf <= DO;
            end
        end
    end

    // --------ROM interface---------
    assign OE = 1'b1;
    assign CS = 1'b1;
    // assign A = (cs == ADDR)? ARADDR_S : (cs == READ_DATA)? request_reg.ADDR[11:0]: 12'b0; // word address input
    assign A = (cs == ADDR)?  ARADDR_S[13:2] : (cs == READ_DATA)? {2'b0,request_reg.ADDR[11:2]}: 12'b0; // byte address input
    // --------ROM interface---------

    // --------AXI interface---------
    // AR
    assign ARREADY_S = (cs == ADDR);

    // R
    assign RID_S = (request_reg.ID);
    assign RDATA_S = (output_sel)? rom_skid_buf : DO;
    assign RRESP_S = `AXI_RESP_OKAY;
    assign RLAST_S = (cs == READ_DATA && request_reg.LEN == `AXI_LEN_BITS'b0);
    assign RVALID_S = (cs == READ_DATA);
    // --------AXI interface---------

    // --------read only---------
    // If get Write request, return decode error.
    assign AWREADY_S    = 1'b1;
    assign WREADY_S     = 1'b1;
    assign BID_S        = `AXI_IDS_BITS'b0;
    assign BRESP_S      = `AXI_RESP_DECERR;
    assign BVALID_S     = 1'b1;
    // --------read only---------
endmodule