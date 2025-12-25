`include "../include/AXI_define.svh"
`include "../include/define.svh"

`include "CPU/CPU.sv" 

module CPU_wrapper(

    input clk,
    input rstn,
    //-------------------------------------//
    //      Port: MASTER <-> AXI BUS       //
    //-------------------------------------//
    input logic DMA_interrupt_i, 
    input logic WDT_interrupt_i,
    // ---------------
    //     Master1   
    // ---------------

    // AXI Master1 Write Address Channel (DM)
    output logic [`AXI_ID_BITS-1:0]     AWID_M1,
    output logic [`AXI_ADDR_BITS-1:0]   AWADDR_M1,
    output logic [`AXI_LEN_BITS-1:0]    AWLEN_M1,
    output logic [`AXI_SIZE_BITS-1:0]   AWSIZE_M1,
    output logic [1:0]                  AWBURST_M1,
    output logic                        AWVALID_M1,
    input                               AWREADY_M1,
        
    // AXI Master1 Write Data Channel (DM)
    output logic [`AXI_DATA_BITS-1:0]   WDATA_M1,
    output logic [`AXI_STRB_BITS-1:0]   WSTRB_M1,
    output logic                        WLAST_M1,
    output logic                        WVALID_M1,
    input                               WREADY_M1,
        
    // AXI Master1 Write Response Channel (DM)
    input [`AXI_ID_BITS-1:0]            BID_M1,
    input [1:0]                         BRESP_M1,
    input                               BVALID_M1,
    output logic                        BREADY_M1,

    // AXI Master1 Read Address Channel (DM)
    output logic [`AXI_ID_BITS-1:0]     ARID_M1,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR_M1,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN_M1,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE_M1,
    output logic [1:0]                  ARBURST_M1,
    output logic                        ARVALID_M1,
    input                               ARREADY_M1,
        
    // AXI Master1 Read Data Channel (DM)
    input [`AXI_ID_BITS-1:0]            RID_M1,
    input [`AXI_DATA_BITS-1:0]          RDATA_M1,
    input [1:0]                         RRESP_M1,
    input                               RLAST_M1,
    input                               RVALID_M1,
    output logic                        RREADY_M1,

    // ---------------
    //     Master0     
    // ---------------

    // AXI Master0 Read Address Channel (IM)
    output logic [`AXI_ID_BITS-1:0]     ARID_M0,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR_M0,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN_M0,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE_M0,
    output logic [1:0]                  ARBURST_M0,
    output logic                        ARVALID_M0,
    input                               ARREADY_M0,
        
    // AXI Master0 Read Data Channel (IM)
    input [`AXI_ID_BITS-1:0]            RID_M0,
    input [`AXI_DATA_BITS-1:0]          RDATA_M0,
    input [1:0]                         RRESP_M0,
    input                               RLAST_M0,
    input                               RVALID_M0,
    output logic                        RREADY_M0
);

    // Instruction Memory Interface
    logic [31:0] fetch_data;
    logic        fetch_data_valid;
    logic        fetch_req_ready;
    logic [31:0] fetch_addr;
    logic        fetch_req_valid;
    // Data Memory Interface
    logic [31:0] ld_st_req_addr;
    logic        store_data_valid;
    logic [3:0]  store_strb;
    logic [31:0] store_data;
    logic        store_req_valid;
    logic        store_req_ready;
    logic        load_data_valid;
    logic [31:0] load_data;
    logic        load_req_valid;
    logic        load_req_ready;

    CPU cpu(
        .clk                (clk),
        .rst                (~rstn),
        // Interrupt
        .DMA_interrupt      (DMA_interrupt_i),
        .WDT_interrupt      (WDT_interrupt_i),
        // Instruction Memory Interface
        .fetch_data(fetch_data),
        .fetch_data_valid(fetch_data_valid),
        .fetch_req_ready(fetch_req_ready),
        .fetch_addr(fetch_addr),
        .fetch_req_valid(fetch_req_valid),
        // Data Memory Interface
        .ld_st_req_addr(ld_st_req_addr),
        .store_data_valid(store_data_valid),
        .store_strb(store_strb),
        .store_data(store_data),
        .store_req_valid(store_req_valid),
        .store_req_ready(store_req_ready),
        .load_data_valid(load_data_valid),
        .load_data(load_data),
        .load_req_valid(load_req_valid),
        .load_req_ready(load_req_ready)
    );

    // ---------------
    //     Master0     
    // ---------------

    logic M0_AR_handshake;
    logic M0_R_handshake;
    logic fetch_handshake;

    assign M0_AR_handshake = ARVALID_M0 & ARREADY_M0;
    assign M0_R_handshake  = RVALID_M0 & RREADY_M0;
    assign fetch_handshake = fetch_req_valid & fetch_req_ready;


    typedef enum logic [1:0] {
        M0_IDLE, M0_WAIT_R, M0_READ
    } M0_state_t;

    M0_state_t M0_cs, M0_ns;

    typedef enum logic [2:0] {
        IDLE, WAIT_R, READ, WAIT_W, WRITE, BRESP
    } M1_state_t;

    M1_state_t M1_cs, M1_ns;

    assign fetch_req_ready = (M0_cs == M0_IDLE);

    always_ff @(posedge clk) begin
        if (!rstn) begin
            M0_cs <= M0_IDLE;
        end
        else begin
            M0_cs <= M0_ns;
        end
    end

    always_comb begin
        unique case (M0_cs)
            M0_IDLE:       M0_ns = (fetch_handshake)? ((M0_AR_handshake)? M0_READ : M0_WAIT_R) : M0_IDLE;
            M0_WAIT_R:     M0_ns = (M0_AR_handshake)? M0_READ : M0_WAIT_R;
            M0_READ:       M0_ns = (M0_R_handshake)?                     M0_IDLE : M0_READ;
        endcase
    end
	
	logic [31:0] M0_buff_addr;

    always_comb begin
        // AR
        ARID_M0             = 4'b0;
        ARADDR_M0           = 32'b0;
        ARLEN_M0            = 4'b0;
        ARSIZE_M0           = 3'b0;
        ARBURST_M0          = 2'b0; 
        ARVALID_M0          = 1'b0;
        // R    
        RREADY_M0           = 1'b0;
        // Output
        fetch_data          = 32'b0;
        fetch_data_valid    = 1'b0;
        unique case (M0_cs)
            M0_IDLE: begin
                // AR
                ARADDR_M0       = fetch_addr;
                ARID_M0         = 4'b0;
                ARSIZE_M0       = 3'b010; // 4 bytes
                ARBURST_M0      = 2'b01;  // INCR
                ARVALID_M0      = fetch_handshake;
            end
	    	M0_WAIT_R: begin
                // AR
                ARADDR_M0       = M0_buff_addr;
                ARID_M0         = 4'b0;
                ARSIZE_M0       = 3'b010; // 4 bytes
                ARBURST_M0      = 2'b01;  // INCR
                ARVALID_M0      = 1'b1;
            end
            M0_READ: begin
                // R    
                RREADY_M0       = 1'b1;
                // Output
                fetch_data      = (M0_R_handshake)? RDATA_M0 : 32'b0;
                fetch_data_valid   = (M0_R_handshake)? 1'b1     : 1'b0;
            end
            default: begin
                // Do nothing
            end
        endcase
    end

    always_ff @(posedge clk) begin
		if(!rstn) begin
			M0_buff_addr <= 32'b0;
		end
		else begin
			case(M0_cs) 
				M0_IDLE:      M0_buff_addr <= fetch_addr;
            	M0_WAIT_R:    M0_buff_addr <= M0_buff_addr;
            	M0_READ:      M0_buff_addr <= M0_buff_addr; 
			endcase
		end
	end

    // ---------------
    //     Master1     
    // ---------------

    logic M1_AW_handshake;
    logic M1_W_handshake;
    logic M1_B_handshake;
    logic M1_AR_handshake;
    logic M1_R_handshake;
    logic load_handshake;
    logic store_handshake;

    assign M1_AW_handshake = AWVALID_M1 & AWREADY_M1;
    assign M1_W_handshake  = WVALID_M1 & WREADY_M1;
    assign M1_B_handshake  = BVALID_M1 & BREADY_M1;
    assign M1_AR_handshake = ARVALID_M1 & ARREADY_M1;
    assign M1_R_handshake  = RVALID_M1 & RREADY_M1;

    assign load_handshake = load_req_valid  & load_req_ready;
    assign store_handshake = store_req_valid & store_req_ready;

    assign load_req_ready  = (M1_cs == IDLE);
    assign store_req_ready = (M1_cs == IDLE);

    always_ff @(posedge clk) begin
        if (!rstn) begin
            M1_cs <= IDLE;
        end
        else begin
            M1_cs <= M1_ns;
        end
    end

    always_comb begin
        unique case (M1_cs)
            IDLE: begin
                priority case (1'b1)
                    store_handshake : M1_ns = (M1_AW_handshake)? ((M1_W_handshake)? BRESP : WRITE) : WAIT_W;
                    load_handshake  : M1_ns = (M1_AR_handshake)? READ   : WAIT_R;
                    default:        M1_ns = IDLE;
                endcase
            end
	    	WAIT_R:     M1_ns = (M1_AR_handshake)? READ : WAIT_R;
            READ:       M1_ns = (M1_R_handshake)? IDLE  : READ;
			WAIT_W:     M1_ns = (M1_AW_handshake)? ((M1_W_handshake)? BRESP : WRITE) : WAIT_W;
            WRITE:      M1_ns = (M1_W_handshake)? BRESP : WRITE;
            BRESP:      M1_ns = (M1_B_handshake)? IDLE  : BRESP;
        endcase
    end

	
	logic [31:0] M1_buff_addr;
	logic [31:0] M1_buff_data;
	logic [3:0]  M1_buff_strb;
	always_ff @(posedge clk) begin
		if(!rstn) begin
			M1_buff_addr <= 32'b0;
            M1_buff_data <= 32'b0;
            M1_buff_strb <= 4'b0;
		end
		else begin
			case(M1_cs) 
				IDLE:       M1_buff_addr <= ld_st_req_addr;
            	default:    M1_buff_addr <= M1_buff_addr;
			endcase

			case(M1_cs) 
				IDLE:       M1_buff_data <= store_data;
            	default:   	M1_buff_data <= M1_buff_data;
			endcase

			case(M1_cs) 
				IDLE:       M1_buff_strb <= ~store_strb[3:0];
            	default:    M1_buff_strb <= M1_buff_strb;
			endcase
		end
	end

    always_comb begin
        // AW
        AWID_M1         = 4'b0;
        AWADDR_M1       = 32'b0;
        AWLEN_M1        = 4'b0;
        AWSIZE_M1       = 3'b0;
        AWBURST_M1      = 2'b0;
        AWVALID_M1      = 1'b0;
        // W
        WDATA_M1        = 32'b0;
        WSTRB_M1        = 4'b0;
        WLAST_M1        = 1'b0;
        WVALID_M1       = 1'b0;
        // B
        BREADY_M1       = 1'b0;
        // AR
        ARID_M1         = 4'b0;
        ARADDR_M1       = 32'b0;
        ARLEN_M1        = 4'b0;
        ARSIZE_M1       = 3'b0; // 4 bytes
        ARBURST_M1      = 2'b0;  // INCR
        ARVALID_M1      = 1'b0;
        // R    
        RREADY_M1       = 1'b0;
        // Output
        load_data           = 32'b0;
        load_data_valid     = 1'b0;
        store_data_valid    = 1'b0;
        unique case (M1_cs)
            IDLE: begin
                // AW
                AWADDR_M1       = ld_st_req_addr;
                AWID_M1         = 4'b1;
                AWSIZE_M1       = 3'b010; // 4 bytes
                AWBURST_M1      = 2'b01;  // INCR
                AWVALID_M1      = store_handshake;
                // W
                WDATA_M1        = store_data;
                WSTRB_M1        = ~store_strb[3:0];
                WLAST_M1        = M1_AW_handshake;
                WVALID_M1       = M1_AW_handshake;
                // AR
                ARADDR_M1       = ld_st_req_addr;
                ARID_M1         = 4'b1;
                ARSIZE_M1       = 3'b010; // 4 bytes
                ARBURST_M1      = 2'b01;  // INCR
                ARVALID_M1      = load_handshake;
            end
			WAIT_R: begin
				ARADDR_M1       = M1_buff_addr;
                ARID_M1         = 4'b1;
		        ARSIZE_M1       = 3'b010; // 4 bytes
		        ARBURST_M1      = 2'b01;  // INCR
		        ARVALID_M1      = 1'b1;
			end
            READ: begin
                // R    
                RREADY_M1       = 1'b1;
                // Output
                load_data           = (M1_R_handshake)? RDATA_M1 : 32'b0;
                load_data_valid     = (M1_R_handshake)? 1'b1     : 1'b0;
            end
			WAIT_W: begin
                // AW
                AWADDR_M1       = M1_buff_addr;
                AWID_M1         = 1'b1;
                AWSIZE_M1       = 3'b010; // 4 bytes
                AWBURST_M1      = 2'b01;  // INCR
                AWVALID_M1      = 1'b1;
				// Ws
				WDATA_M1        = M1_buff_data;
                WSTRB_M1        = M1_buff_strb;
                WLAST_M1        = M1_AW_handshake;
                WVALID_M1       = M1_AW_handshake;
            end
            WRITE: begin
                // W
                WDATA_M1        = M1_buff_data;
                WSTRB_M1        = M1_buff_strb;
                WLAST_M1        = 1'b1;
                WVALID_M1       = 1'b1;
            end
            BRESP: begin
                // B
                BREADY_M1       = 1'b1;
                // Output
                store_data_valid   = (M1_B_handshake)? 1'b1 : 1'b0;
            end
            default: begin
                // Do nothing
            end
        endcase
    end

endmodule
