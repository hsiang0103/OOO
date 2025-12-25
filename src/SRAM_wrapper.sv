`include "../include/AXI_define.svh"

module SRAM_wrapper(
    input                                   ACLK,		
    input                                   ARESETn,	

    // AXI Slave Write Address Channel
    input [`AXI_IDS_BITS-1:0]               AWID_S,		
    input [`AXI_ADDR_BITS-1:0]              AWADDR_S,   
    input [`AXI_LEN_BITS-1:0]               AWLEN_S,    
    input [`AXI_SIZE_BITS-1:0]              AWSIZE_S,   
    input [1:0]                             AWBURST_S,  
    input                                   AWVALID_S,	
    output logic                            AWREADY_S, 

    // AXI Slave Write Data Channel 
    input [`AXI_DATA_BITS-1:0]              WDATA_S,	
    input [`AXI_STRB_BITS-1:0]              WSTRB_S,    
    input                                   WLAST_S,    
    input                                   WVALID_S,   
    output logic                            WREADY_S,

    // AXI Slave Write Response Channel 
    output logic [`AXI_IDS_BITS-1:0]        BID_S,		
    output logic [1:0]                      BRESP_S,    
    output logic                            BVALID_S,   
    input                                   BREADY_S,   

    // AXI Slave Read Address Channel
    input [`AXI_IDS_BITS-1:0]               ARID_S,     
    input [`AXI_ADDR_BITS-1:0]              ARADDR_S,   
    input [`AXI_LEN_BITS-1:0]               ARLEN_S,    
    input [`AXI_SIZE_BITS-1:0]              ARSIZE_S,   
    input [1:0]                             ARBURST_S,  
    input                                   ARVALID_S,  
    output logic                            ARREADY_S,  

    // AXI Slave Read Data Channel
    output logic [`AXI_IDS_BITS-1:0]        RID_S,		
    output logic [`AXI_DATA_BITS-1:0]       RDATA_S,    
    output logic [1:0]                      RRESP_S,    
    output logic                            RLAST_S,    
    output logic                            RVALID_S,   
    input                                   RREADY_S   
);

    logic           CEB;
    logic           WEB;
    logic [31:0]    BWEB;
    logic [31:0]    A;
    logic [31:0]    DI;
    logic [31:0]    DO;

    TS1N16ADFPCLLLVTA512X45M4SWSHOD i_SRAM (
        .SLP     (1'b0 ),
        .DSLP    (1'b0 ),
        .SD      (1'b0 ),
        .PUDELAY (     ),
        .CLK     (ACLK ),
        .CEB     (1'b0 ),
        .WEB     (WEB  ),
        .A       (A[13:0]),
        .D       (DI   ),
        .BWEB    (BWEB ),
        .RTSEL   (2'b01),
        .WTSEL   (2'b01),
        .Q       (DO   )
    );

    typedef enum logic [2:0] {
        IDLE,
        R_MID,
        R_END,
        W_MID,
        W_LAST,
        W_END
    } state_t;

    state_t cs, ns;

    logic AW_handshake;
    logic W_handshake;
    logic B_handshake;
    logic AR_handshake;
    logic R_handshake;

    assign AW_handshake = AWVALID_S & AWREADY_S;
    assign W_handshake  = WVALID_S  & WREADY_S;
    assign B_handshake  = BVALID_S  & BREADY_S;
    assign AR_handshake = ARVALID_S & ARREADY_S;
    assign R_handshake  = RVALID_S  & RREADY_S;

    logic [`AXI_LEN_BITS:0]     burst_len;
    logic [`AXI_ADDR_BITS-1:0]  burst_addr;
    logic [`AXI_IDS_BITS-1:0]   burst_id;

    logic [`AXI_LEN_BITS:0]     burst_count;
    logic [31:0]                WBWEB;
    logic [31:0]                AXI_addr;

    assign WBWEB = ~{{8{WSTRB_S[3]}}, {8{WSTRB_S[2]}}, {8{WSTRB_S[1]}}, {8{WSTRB_S[0]}}};

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            cs <= IDLE;
        end 
        else begin
            cs <= ns;
        end
    end

    // state transition
    always_comb begin
        unique case (cs)
            IDLE  : begin
                priority case(1'b1)
                    AR_handshake && ARLEN_S == 4'b0                 : ns = R_END;
                    AR_handshake                                    : ns = R_MID;
                    AW_handshake && W_handshake && AWLEN_S == 4'b0  : ns = W_END;
                    AW_handshake && AWLEN_S == 4'b0                 : ns = W_LAST;
                    AW_handshake                                    : ns = W_MID;
                    default                                         : ns = IDLE;
                endcase
            end
            R_MID   : ns = (R_handshake && burst_count == burst_len)? R_END : R_MID;
            R_END   : ns = (R_handshake)? IDLE : R_END;
            W_MID   : ns = (W_handshake && burst_count == burst_len)? W_LAST : W_MID;
            W_LAST  : ns = (W_handshake)? W_END : W_LAST;
            W_END   : ns = (B_handshake)? IDLE : W_END;
            default : ns = IDLE;
        endcase
    end
    
    // 
    always_comb begin
        AWREADY_S = 1'b0;
        WREADY_S  = 1'b0;
        BVALID_S  = 1'b0;
        BRESP_S   = `AXI_RESP_OKAY;
        BID_S     = burst_id;
        ARREADY_S = 1'b0;
        RVALID_S  = 1'b0;
        RID_S     = burst_id;
        RDATA_S   = DO;
        RRESP_S   = `AXI_RESP_OKAY;
        RLAST_S   = 1'b0;
        unique case (cs)
            IDLE  : begin
                AWREADY_S = 1'b1;
                WREADY_S  = 1'b1;
                ARREADY_S = 1'b1;
            end
            R_MID : begin
                RVALID_S  = 1'b1;
            end
            R_END : begin
                RVALID_S  = 1'b1;
                RLAST_S   = 1'b1;
            end
            W_MID : begin
                WREADY_S  = 1'b1;
            end
            W_LAST: begin
                WREADY_S  = 1'b1;
            end
            W_END : begin
                BVALID_S  = 1'b1;
            end
        endcase
    end

    // Internal signals
    always_ff @(posedge ACLK) begin
        if(!ARESETn) begin
            burst_count <= 4'b0;
            burst_len   <= 4'b0;
            burst_addr  <= 32'b0;
            burst_id    <= 8'b0;
        end
        else begin
            unique case (cs)
                IDLE  : begin
                    burst_len   <= (AR_handshake)? ARLEN_S - 4'b1 : AWLEN_S - 4'b1;
                    burst_addr  <= (AR_handshake)? ARADDR_S : AWADDR_S;
                    burst_id    <= (AR_handshake)? ARID_S   : AWID_S;
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

    // SRAM control signals
    always_comb begin
		AXI_addr    = burst_addr + {burst_count + {3'b0, R_handshake}, 2'b0};
        DI          = WDATA_S;
        WEB         = !W_handshake;

        if (cs == IDLE) begin
            BWEB    = (AW_handshake && W_handshake)? WBWEB : 32'hFFFFFFFF;
            A       = (AR_handshake)? ARADDR_S[31:2] : AWADDR_S[31:2];
        end
        else begin
            BWEB    = WBWEB;
            A       = AXI_addr[31:2];
        end
    end
endmodule


