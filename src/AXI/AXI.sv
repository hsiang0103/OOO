//////////////////////////////////////////////////////////////////////
//          ██╗       ██████╗   ██╗  ██╗    ██████╗            		//
//          ██║       ██╔══█║   ██║  ██║    ██╔══█║            		//
//          ██║       ██████║   ███████║    ██████║            		//
//          ██║       ██╔═══╝   ██╔══██║    ██╔═══╝            		//
//          ███████╗  ██║  	    ██║  ██║    ██║  	           		//
//          ╚══════╝  ╚═╝  	    ╚═╝  ╚═╝    ╚═╝  	           		//
//                                                             		//
// 	2024 Advanced VLSI System Design, advisor: Lih-Yih, Chiou		//
//                                                             		//
//////////////////////////////////////////////////////////////////////
//                                                             		//
// 	Autor: 			TZUNG-JIN, TSAI (Leo)				  	   		//
//	Filename:		 AXI.sv			                            	//
//	Description:	Top module of AXI	 							//
// 	Version:		1.0	    								   		//
//////////////////////////////////////////////////////////////////////
`include "../include/AXI_define.svh"

module AXI(

        input ACLK,
        input ARESETn,

        //SLAVE INTERFACE FOR MASTERS

        //WRITE ADDRESS
        input [`AXI_ID_BITS-1:0] AWID_M1,
        input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
        input [`AXI_LEN_BITS-1:0] AWLEN_M1,
        input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
        input [1:0] AWBURST_M1,
        input AWVALID_M1,
        output logic AWREADY_M1,

        //WRITE DATA
        input [`AXI_DATA_BITS-1:0] WDATA_M1,
        input [`AXI_STRB_BITS-1:0] WSTRB_M1,
        input WLAST_M1,
        input WVALID_M1,
        output logic WREADY_M1,

        //WRITE RESPONSE
        output logic [`AXI_ID_BITS-1:0] BID_M1,
        output logic [1:0] BRESP_M1,
        output logic BVALID_M1,
        input BREADY_M1,

        //READ ADDRESS0
        input [`AXI_ID_BITS-1:0] ARID_M0,
        input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
        input [`AXI_LEN_BITS-1:0] ARLEN_M0,
        input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
        input [1:0] ARBURST_M0,
        input ARVALID_M0,
        output logic ARREADY_M0,

        //READ DATA0
        output logic [`AXI_ID_BITS-1:0] RID_M0,
        output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
        output logic [1:0] RRESP_M0,
        output logic RLAST_M0,
        output logic RVALID_M0,
        input RREADY_M0,

        //READ ADDRESS1
        input [`AXI_ID_BITS-1:0] ARID_M1,
        input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
        input [`AXI_LEN_BITS-1:0] ARLEN_M1,
        input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
        input [1:0] ARBURST_M1,
        input ARVALID_M1,
        output logic ARREADY_M1,

        //READ DATA1
        output logic [`AXI_ID_BITS-1:0] RID_M1,
        output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
        output logic [1:0] RRESP_M1,
        output logic RLAST_M1,
        output logic RVALID_M1,
        input RREADY_M1,

        //MASTER INTERFACE FOR SLAVES
        //WRITE ADDRESS0
        output logic [`AXI_IDS_BITS-1:0] AWID_S0,
        output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
        output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
        output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
        output logic [1:0] AWBURST_S0,
        output logic AWVALID_S0,
        input AWREADY_S0,

        //WRITE DATA0
        output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
        output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
        output logic WLAST_S0,
        output logic WVALID_S0,
        input WREADY_S0,

        //WRITE RESPONSE0
        input [`AXI_IDS_BITS-1:0] BID_S0,
        input [1:0] BRESP_S0,
        input BVALID_S0,
        output logic BREADY_S0,

        //WRITE ADDRESS1
        output logic [`AXI_IDS_BITS-1:0] AWID_S1,
        output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
        output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
        output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
        output logic [1:0] AWBURST_S1,
        output logic AWVALID_S1,
        input AWREADY_S1,

        //WRITE DATA1
        output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
        output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
        output logic WLAST_S1,
        output logic WVALID_S1,
        input WREADY_S1,

        //WRITE RESPONSE1
        input [`AXI_IDS_BITS-1:0] BID_S1,
        input [1:0] BRESP_S1,
        input BVALID_S1,
        output logic BREADY_S1,

        //READ ADDRESS0
        output logic [`AXI_IDS_BITS-1:0] ARID_S0,
        output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
        output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
        output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
        output logic [1:0] ARBURST_S0,
        output logic ARVALID_S0,
        input ARREADY_S0,

        //READ DATA0
        input [`AXI_IDS_BITS-1:0] RID_S0,
        input [`AXI_DATA_BITS-1:0] RDATA_S0,
        input [1:0] RRESP_S0,
        input RLAST_S0,
        input RVALID_S0,
        output logic RREADY_S0,

        //READ ADDRESS1
        output logic [`AXI_IDS_BITS-1:0] ARID_S1,
        output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
        output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
        output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
        output logic [1:0] ARBURST_S1,
        output logic ARVALID_S1,
        input ARREADY_S1,

        //READ DATA1
        input [`AXI_IDS_BITS-1:0] RID_S1,
        input [`AXI_DATA_BITS-1:0] RDATA_S1,
        input [1:0] RRESP_S1,
        input RLAST_S1,
        input RVALID_S1,
        output logic RREADY_S1

    );
	
    // ===============================
    //         Slave to Master
    // ===============================
    // M0
    logic [`AXI_ID_BITS-1:0]    RID_to_M0;
    logic [`AXI_DATA_BITS-1:0]  RDATA_to_M0;
    logic [1:0]                 RRESP_to_M0;
    logic                       RLAST_to_M0;
    logic                       RVALID_to_M0;

    // M1
    logic [`AXI_ID_BITS-1:0]    RID_to_M1;
    logic [`AXI_DATA_BITS-1:0]  RDATA_to_M1;
    logic [1:0]                 RRESP_to_M1;
    logic                       RLAST_to_M1;
    logic                       RVALID_to_M1;

    logic [`AXI_ID_BITS-1:0]    BID_to_M1;
    logic [1:0]                 BRESP_to_M1;
    logic                       BVALID_to_M1;

    // S0
    logic                       RREADY_to_S0;
    logic                       BREADY_to_S0;

    // S1
    logic                       RREADY_to_S1;
    logic                       BREADY_to_S1;

    // ===============================
    //         Master to Slave
    // ===============================
    // S0
    logic [`AXI_IDS_BITS-1:0]   AWID_to_S0;
    logic [`AXI_ADDR_BITS-1:0]  AWADDR_to_S0;
    logic [`AXI_LEN_BITS-1:0]   AWLEN_to_S0;
    logic [`AXI_SIZE_BITS-1:0]  AWSIZE_to_S0;
    logic [1:0]                 AWBURST_to_S0;
    logic                       AWVALID_to_S0;

    logic [`AXI_DATA_BITS-1:0]  WDATA_to_S0;
    logic [`AXI_STRB_BITS-1:0]  WSTRB_to_S0;
    logic                       WLAST_to_S0;
    logic                       WVALID_to_S0;

    logic [`AXI_IDS_BITS-1:0]   ARID_to_S0;
    logic [`AXI_ADDR_BITS-1:0]  ARADDR_to_S0;
    logic [`AXI_LEN_BITS-1:0]   ARLEN_to_S0;
    logic [`AXI_SIZE_BITS-1:0]  ARSIZE_to_S0;
    logic [1:0]                 ARBURST_to_S0;
    logic                       ARVALID_to_S0;

    // S1
    logic [`AXI_IDS_BITS-1:0]   AWID_to_S1;
    logic [`AXI_ADDR_BITS-1:0]  AWADDR_to_S1;
    logic [`AXI_LEN_BITS-1:0]   AWLEN_to_S1;
    logic [`AXI_SIZE_BITS-1:0]  AWSIZE_to_S1;
    logic [1:0]                 AWBURST_to_S1;
    logic                       AWVALID_to_S1;

    logic [`AXI_DATA_BITS-1:0]  WDATA_to_S1;
    logic [`AXI_STRB_BITS-1:0]  WSTRB_to_S1;
    logic                       WLAST_to_S1;
    logic                       WVALID_to_S1;

    logic [`AXI_IDS_BITS-1:0]   ARID_to_S1;
    logic [`AXI_ADDR_BITS-1:0]  ARADDR_to_S1;
    logic [`AXI_LEN_BITS-1:0]   ARLEN_to_S1;
    logic [`AXI_SIZE_BITS-1:0]  ARSIZE_to_S1;
    logic [1:0]                 ARBURST_to_S1;
    logic                       ARVALID_to_S1;

    // M0
    logic                       ARREADY_to_M0;

    // M1
    logic                       AWREADY_to_M1;
    logic                       WREADY_to_M1;
    logic                       ARREADY_to_M1;

    // ===============================
    //              READ                           
    // ===============================

    logic [1:0]                 M0_AR_slv;
    logic [1:0]                 M0_AR_slv_r;
    logic [`AXI_ID_BITS-1:0]    M0_ARID_r;	

    logic [1:0]                 M1_AR_slv;
    logic [1:0]                 M1_AR_slv_r;
    logic [`AXI_ID_BITS-1:0]    M1_ARID_r;
	
    logic [`AXI_IDS_BITS-1:0]   S0_RID_r;	
    logic [`AXI_DATA_BITS-1:0]  S0_RDATA_r;
    logic [1:0]                 S0_RRESP_r;
    logic                       S0_RLAST_r;
    logic                       S0_RVALID_r;

    logic [`AXI_IDS_BITS-1:0]   S1_RID_r;	
    logic [`AXI_DATA_BITS-1:0]  S1_RDATA_r;
    logic [1:0]                 S1_RRESP_r;
    logic                       S1_RLAST_r;
    logic                       S1_RVALID_r;

	logic [`AXI_LEN_BITS-1:0]	M0_ARLEN_r;
	logic [`AXI_LEN_BITS-1:0]  	M1_ARLEN_r;

    typedef enum logic [2:0] {
        M0_IDLE, M0_WAIT_S0, M0_WAIT_S1, M0_READ_S0, M0_READ_S1
    } M0_state_t;

    typedef enum logic [2:0] {
        M1_IDLE, M1_WAIT_S0, M1_WAIT_S1, M1_READ_S0, M1_READ_S1
    } M1_state_t;

    M0_state_t M0_cs, M0_ns;
    M1_state_t M1_cs, M1_ns;

    always_comb begin
        M0_AR_slv = (ARVALID_M0) ? {1'b0, ARADDR_M0[16]} : 2'd2;
        M1_AR_slv = (ARVALID_M1) ? {1'b0, ARADDR_M1[16]} : 2'd2;
    end
    
    always_ff @(posedge ACLK) begin
        if(!ARESETn) begin
            M0_cs <= M0_IDLE;
            M1_cs <= M1_IDLE;
        end
        else begin
            M0_cs <= M0_ns;
            M1_cs <= M1_ns;
        end
    end

    always_comb begin
        unique case (M0_cs)
            M0_IDLE: begin
                unique case (M0_AR_slv)
                    2'b00:      M0_ns = (ARREADY_S0) ? M0_READ_S0 : M0_WAIT_S0;
                    2'b01:      M0_ns = (ARREADY_S1) ? M0_READ_S1 : M0_WAIT_S1;
                    default:    M0_ns = M0_IDLE;
                endcase
            end
            M0_WAIT_S0: M0_ns = (ARREADY_S0) ? M0_READ_S0 : M0_WAIT_S0;
            M0_WAIT_S1: M0_ns = (ARREADY_S1) ? M0_READ_S1 : M0_WAIT_S1;
            M0_READ_S0: M0_ns = (RREADY_M0 && RVALID_to_M0 && RLAST_to_M0) ? M0_IDLE : M0_READ_S0;
            M0_READ_S1: M0_ns = (RREADY_M0 && RVALID_to_M0 && RLAST_to_M0) ? M0_IDLE : M0_READ_S1;
        endcase

        unique case (M1_cs)
            M1_IDLE: begin
                unique case (M1_AR_slv)
                    2'b00: 		M1_ns = (M0_ns != M0_READ_S0 && M0_ns != M0_WAIT_S0) ?  ((ARREADY_S0) ? M1_READ_S0 : M1_WAIT_S0) : M1_IDLE;
                    2'b01: 		M1_ns = (M0_ns != M0_READ_S1 && M0_ns != M0_WAIT_S1) ?  ((ARREADY_S1) ? M1_READ_S1 : M1_WAIT_S1) : M1_IDLE;
                    default:    M1_ns = M1_IDLE;
                endcase
            end
            M1_WAIT_S0: M1_ns = (M0_cs != M0_READ_S0 && ARREADY_S0) ? M1_READ_S0 : M1_WAIT_S0;
            M1_WAIT_S1: M1_ns = (M0_cs != M0_READ_S1 && ARREADY_S1) ? M1_READ_S1 : M1_WAIT_S1;
            M1_READ_S0: M1_ns = (RREADY_M1 && RVALID_to_M1 && RLAST_to_M1) ? M1_IDLE : M1_READ_S0;
            M1_READ_S1: M1_ns = (RREADY_M1 && RVALID_to_M1 && RLAST_to_M1) ? M1_IDLE : M1_READ_S1;
        endcase
    end

	logic buffer;

    always_ff @(posedge ACLK) begin
        unique case (M0_cs)
            M0_IDLE: begin  
                M0_AR_slv_r <= M0_AR_slv;
                M0_ARID_r   <= ARID_M0;
            end
            default: begin
                M0_AR_slv_r <= M0_AR_slv_r;
                M0_ARID_r   <= M0_ARID_r;
            end
        endcase

		unique case (M0_cs)
            M0_IDLE: 	M0_ARLEN_r  <= ARLEN_M0;
			M0_READ_S0:	M0_ARLEN_r  <= (RVALID_to_M0 && RREADY_M0)? M0_ARLEN_r - 1 : M0_ARLEN_r; 
			M0_READ_S1:	M0_ARLEN_r  <= (RVALID_to_M0 && RREADY_M0)? M0_ARLEN_r - 1 : M0_ARLEN_r; 
            default: 	M0_ARLEN_r  <= M0_ARLEN_r;
        endcase
        
        unique case (M1_cs)
            M1_IDLE:  begin 
                M1_AR_slv_r <= M1_AR_slv;
                M1_ARID_r   <= ARID_M1;
				M1_ARLEN_r  <= ARLEN_M1;
            end
            default: begin 
                M1_AR_slv_r <= M1_AR_slv_r;
                M1_ARID_r   <= M1_ARID_r;
				M1_ARLEN_r  <= M1_ARLEN_r;
            end
        endcase

		unique case (M1_cs)
            M1_IDLE: 	M1_ARLEN_r  <= ARLEN_M1;
			M1_READ_S0:	M1_ARLEN_r  <= (RVALID_to_M1 && RREADY_M1)? M1_ARLEN_r - 4'b1 : M1_ARLEN_r; 
			M1_READ_S1:	M1_ARLEN_r  <= (RVALID_to_M1 && RREADY_M1)? M1_ARLEN_r - 4'b1 : M1_ARLEN_r; 
            default: 	M1_ARLEN_r  <= M1_ARLEN_r;
        endcase
		
		if(RVALID_S0 && M1_ARID_r == RID_S0[3:0] && M1_cs == M1_READ_S0 && buffer == 1'b0) begin
			S0_RID_r	<= RID_S0;	
			S0_RDATA_r	<= RDATA_S0;
			S0_RRESP_r	<= RRESP_S0;
			S0_RLAST_r	<= RLAST_S0;
			S0_RVALID_r	<= RVALID_S0;
		end
	
		if(RVALID_S1 && M1_ARID_r == RID_S1[3:0] && M1_cs == M1_READ_S1 && buffer == 1'b0) begin
			S1_RID_r	<= RID_S1;	
    		S1_RDATA_r	<= RDATA_S1;
    		S1_RRESP_r	<= RRESP_S1;
    		S1_RLAST_r	<= RLAST_S1;
    		S1_RVALID_r	<= RVALID_S1;
		end
		
		
		unique case (M1_cs) 
			M1_READ_S0: buffer <= RVALID_S0 && M1_ARID_r == RID_S0[3:0] ? (!RREADY_M1) ? 1'b1 : 1'b0 : buffer;
			M1_READ_S1: buffer <= RVALID_S1 && M1_ARID_r == RID_S1[3:0] ? (!RREADY_M1) ? 1'b1 : 1'b0 : buffer;
			default: buffer <= 1'b0;
		endcase
    end

    always_comb begin
        unique case (M0_cs) 
            M0_IDLE: begin
                unique case (M0_AR_slv)
                    2'b00:      ARREADY_to_M0  = ARREADY_S0;
                    2'b01:      ARREADY_to_M0  = ARREADY_S1;
                    default:    ARREADY_to_M0  = 1'b0;
                endcase
            end
            M0_WAIT_S0: ARREADY_to_M0  = ARREADY_S0;
            M0_WAIT_S1: ARREADY_to_M0  = ARREADY_S1;
            default:    ARREADY_to_M0  = 1'b0;
        endcase

        unique case (M1_cs) 
            M1_IDLE: begin
                priority case (M1_AR_slv)
                    2'b00: ARREADY_to_M1  = (M0_ns != M0_READ_S0) ? ARREADY_S0 : 1'b0;
                    2'b01: ARREADY_to_M1  = (M0_ns != M0_READ_S1) ? ARREADY_S1 : 1'b0;
                    default:            ARREADY_to_M1  = 1'b0;
                endcase
            end
            M1_WAIT_S0: ARREADY_to_M1  = (M0_cs != M0_READ_S0) ? ARREADY_S0 : 1'b0;
            M1_WAIT_S1: ARREADY_to_M1  = (M0_cs != M0_READ_S1) ? ARREADY_S1 : 1'b0;
            default:    ARREADY_to_M1  = 1'b0;
        endcase
        
        priority case (1'b1)
            M0_ARID_r == RID_S0[3:0] && M0_AR_slv_r == 2'b00 && M0_cs == M0_READ_S0 && RLAST_S0: begin
                RID_to_M0       = RID_S0[3:0];
                RDATA_to_M0     = RDATA_S0;
                RRESP_to_M0     = RRESP_S0;
                RLAST_to_M0     = M0_ARLEN_r == 4'b0;
                RVALID_to_M0    = RVALID_S0;
            end
            M0_ARID_r == RID_S1[3:0] && M0_AR_slv_r == 2'b01 && M0_cs == M0_READ_S1 && RLAST_S1: begin
                RID_to_M0       = RID_S1[3:0];
                RDATA_to_M0     = RDATA_S1;
                RRESP_to_M0     = RRESP_S1;
                RLAST_to_M0     = M0_ARLEN_r == 4'b0;
                RVALID_to_M0    = RVALID_S1;
            end
            default: begin
                RID_to_M0       = 4'b0;
                RDATA_to_M0     = 32'b0;
                RRESP_to_M0     = 2'b00;
                RLAST_to_M0     = 1'b0;
                RVALID_to_M0    = 1'b0;
            end
        endcase

        priority case (1'b1)
            (M1_ARID_r == RID_S0[3:0] || M1_ARID_r == S0_RID_r[3:0]) && M1_AR_slv_r == 2'b00 && M1_cs == M1_READ_S0: begin
                RID_to_M1       = buffer ? S0_RID_r[3:0] 	: RID_S0[3:0];
                RDATA_to_M1     = buffer ? S0_RDATA_r 	: RDATA_S0;
                RRESP_to_M1     = buffer ? S0_RRESP_r 	: RRESP_S0;
                RLAST_to_M1     = M1_ARLEN_r == 4'b0;
                RVALID_to_M1    = buffer ? S0_RVALID_r 	: RVALID_S0;
            end
            (M1_ARID_r == RID_S1[3:0] || M1_ARID_r == S1_RID_r[3:0]) && M1_AR_slv_r == 2'b01 && M1_cs == M1_READ_S1: begin
                RID_to_M1       = buffer ? S1_RID_r[3:0] 	: RID_S1[3:0];
                RDATA_to_M1     = buffer ? S1_RDATA_r 	: RDATA_S1;
                RRESP_to_M1     = buffer ? S1_RRESP_r 	: RRESP_S1;
                RLAST_to_M1     = M1_ARLEN_r == 4'b0;
                RVALID_to_M1    = buffer ? S1_RVALID_r 	: RVALID_S1;
            end
            default: begin
                RID_to_M1       = 4'b0;
                RDATA_to_M1     = 32'b0;
                RRESP_to_M1     = 2'b00;
                RLAST_to_M1     = 1'b0;
                RVALID_to_M1    = 1'b0;
            end
        endcase

        priority case (1'b1) 
            (M0_cs == M0_IDLE && M0_AR_slv == 2'b00 || M0_cs == M0_WAIT_S0) && M1_cs != M1_WAIT_S0 && M1_cs != M1_READ_S0: begin
                ARID_to_S0    = {4'b0, ARID_M0};
                ARADDR_to_S0  = ARADDR_M0;
                ARLEN_to_S0   = ARLEN_M0;
                ARSIZE_to_S0  = ARSIZE_M0;
                ARBURST_to_S0 = ARBURST_M0;
                ARVALID_to_S0 = ARVALID_M0;
            end
            (M1_cs == M1_IDLE && M1_AR_slv == 2'b00 || M1_cs == M1_WAIT_S0) : begin
                ARID_to_S0    = {4'b0, ARID_M1};
                ARADDR_to_S0  = ARADDR_M1;
                ARLEN_to_S0   = ARLEN_M1;
                ARSIZE_to_S0  = ARSIZE_M1;
                ARBURST_to_S0 = ARBURST_M1;
                ARVALID_to_S0 = ARVALID_M1 && M0_cs != M0_READ_S0;
            end
            default: begin
                ARID_to_S0     = 8'b0;
                ARADDR_to_S0   = 32'b0;
                ARLEN_to_S0    = 4'b0;
                ARSIZE_to_S0   = 3'b0;
                ARBURST_to_S0  = 2'b00;
                ARVALID_to_S0  = 1'b0;
            end
        endcase

        priority case (1'b1)
            ((M0_cs == M0_IDLE && M0_AR_slv == 2'b01) || M0_cs == M0_WAIT_S1) && M1_cs != M1_WAIT_S1 && M1_cs != M1_READ_S1: begin
                ARID_to_S1    = {4'b0, ARID_M0};
                ARADDR_to_S1  = ARADDR_M0;
                ARLEN_to_S1   = ARLEN_M0;
                ARSIZE_to_S1  = ARSIZE_M0;
                ARBURST_to_S1 = ARBURST_M0;
                ARVALID_to_S1 = ARVALID_M0;
            end
            ((M1_cs == M1_IDLE && M1_AR_slv == 2'b01) || M1_cs == M1_WAIT_S1): begin
                ARID_to_S1    = {4'b0, ARID_M1};
                ARADDR_to_S1  = ARADDR_M1;
                ARLEN_to_S1   = ARLEN_M1;
                ARSIZE_to_S1  = ARSIZE_M1;
                ARBURST_to_S1 = ARBURST_M1;
                ARVALID_to_S1 = ARVALID_M1 && M0_cs != M0_READ_S1;
            end
            default: begin
                ARID_to_S1     = 8'b0;
                ARADDR_to_S1   = 32'b0;
                ARLEN_to_S1    = 4'b0;
                ARSIZE_to_S1   = 3'b0;
                ARBURST_to_S1  = 2'b00;
                ARVALID_to_S1  = 1'b0;
            end
        endcase

        priority case (1'b1)
            M0_cs == M0_READ_S0: RREADY_to_S0 = RREADY_M0;
            M1_cs == M1_READ_S0: RREADY_to_S0 = RREADY_M1;
            default:             RREADY_to_S0 = 1'b0;
        endcase

        priority case (1'b1)
            M0_cs == M0_READ_S1: RREADY_to_S1 = RREADY_M0;
            M1_cs == M1_READ_S1: RREADY_to_S1 = RREADY_M1;
            default:             RREADY_to_S1 = 1'b0;
        endcase
    end

    // =============================
    //             Write                 
    // =============================
    logic [1:0]                 M1_AW_t_slv;
    logic [1:0]                 M1_W_t_slv;

    logic [1:0]                 S0_AW_mst;
    logic [1:0]                 S1_AW_mst;
    logic [1:0]                 S0_W_mst;
    logic [1:0]                 S1_W_mst;

    logic [1:0]                 S0_B_t_mst;
    logic [1:0]                 S1_B_t_mst;

    logic [1:0]                 M1_B_slv;

    logic [1:0]    				WID_buffer;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            WID_buffer <= 2'b0;
        end
        else begin
            WID_buffer <= (AWVALID_M1)? {1'b0, AWADDR_M1[16]} : WID_buffer;
        end
    end

    always_comb begin
        M1_AW_t_slv = (AWVALID_M1) ? AWADDR_M1[16] : 2'd2;
        if(WVALID_M1) begin
            M1_W_t_slv  = (AWVALID_M1)? {1'b0, AWADDR_M1[16]} : WID_buffer;
        end
        else begin
            M1_W_t_slv  = 2'd2;
        end
    end

    always_comb begin 
        // AW Channel
        if(M1_AW_t_slv == 2'b0) begin
            AWID_to_S0     = {4'b0, AWID_M1};
            AWADDR_to_S0   = AWADDR_M1;
            AWLEN_to_S0    = AWLEN_M1;
            AWSIZE_to_S0   = AWSIZE_M1;
            AWBURST_to_S0  = AWBURST_M1;
            AWVALID_to_S0  = AWVALID_M1;
            S0_AW_mst      = 2'b1;
        end
        else begin
            AWID_to_S0     = 8'b0;
            AWADDR_to_S0   = 32'b0;
            AWLEN_to_S0    = 4'b0;
            AWSIZE_to_S0   = 3'b0;
            AWBURST_to_S0  = 2'b0;
            AWVALID_to_S0  = 1'b0;
            S0_AW_mst      = 2'd2;
        end

        // W Channel
        if(M1_W_t_slv == 2'b0) begin
            WDATA_to_S0    = WDATA_M1;
            WSTRB_to_S0    = WSTRB_M1;
            WLAST_to_S0    = WLAST_M1;
            WVALID_to_S0   = WVALID_M1;
            S0_W_mst       = 2'b1;
        end
        else begin
            WDATA_to_S0    = 32'b0;
            WSTRB_to_S0    = 4'b0;
            WLAST_to_S0    = 1'b0;
            WVALID_to_S0   = 1'b0;
            S0_W_mst       = 2'd2;
        end
    end

    always_comb begin 
        // AW Channel
        if(M1_AW_t_slv == 2'b1) begin
            AWID_to_S1     = {4'b0, AWID_M1};
            AWADDR_to_S1   = AWADDR_M1;
            AWLEN_to_S1    = AWLEN_M1;
            AWSIZE_to_S1   = AWSIZE_M1;
            AWBURST_to_S1  = AWBURST_M1;
            AWVALID_to_S1  = AWVALID_M1;
            S1_AW_mst      = 2'b1;
        end
        else begin
            AWID_to_S1     = 8'b0;
            AWADDR_to_S1   = 32'b0;
            AWLEN_to_S1    = 4'b0;
            AWSIZE_to_S1   = 3'b0;
            AWBURST_to_S1  = 2'b0;
            AWVALID_to_S1  = 1'b0;
            S1_AW_mst      = 2'd2;
        end

        // W Channel
        if(M1_W_t_slv == 2'b1) begin
            WDATA_to_S1    = WDATA_M1;
            WSTRB_to_S1    = WSTRB_M1;
            WLAST_to_S1    = WLAST_M1;
            WVALID_to_S1   = WVALID_M1;
            S1_W_mst       = 2'b1;
        end
        else begin
            WDATA_to_S1    = 32'b0;
            WSTRB_to_S1    = 4'b0;
            WLAST_to_S1    = 1'b0;
            WVALID_to_S1   = 1'b0;
            S1_W_mst       = 2'd2;
        end
    end

    always_comb begin
        S0_B_t_mst = (BVALID_S0) ? BID_S0[1:0] : 2'd2;
        S1_B_t_mst = (BVALID_S1) ? BID_S1[1:0] : 2'd2;
    end

    always_comb begin 
        priority case (1'b1)
            S0_B_t_mst == 2'b1: begin
                BID_to_M1     = BID_S0[3:0];
                BRESP_to_M1   = BRESP_S0;
                BVALID_to_M1  = BVALID_S0;
                M1_B_slv      = 2'b0;
            end
            S1_B_t_mst == 2'b1: begin
                BID_to_M1     = BID_S1[3:0];
                BRESP_to_M1   = BRESP_S1;
                BVALID_to_M1  = BVALID_S1;
                M1_B_slv      = 2'b1;
            end
            default: begin
                BID_to_M1     = 4'b0;
                BRESP_to_M1   = 2'b00;
                BVALID_to_M1  = 1'b0;
                M1_B_slv      = 2'd2;
            end
        endcase

        unique case (1'b1)  
            S0_AW_mst:  AWREADY_to_M1   = AWREADY_S0;
            S1_AW_mst:  AWREADY_to_M1   = AWREADY_S1;
            default:    AWREADY_to_M1   = 1'b0;
        endcase

        unique case (1'b1)
            S0_W_mst:   WREADY_to_M1    = WREADY_S0;
            S1_W_mst:   WREADY_to_M1    = WREADY_S1;
            default:    WREADY_to_M1    = 1'b0;
        endcase

        unique case (1'b0)
            M1_B_slv: BREADY_to_S0 = BREADY_M1;
            default:  BREADY_to_S0 = 1'b0;
        endcase

        unique case (1'b1)
            M1_B_slv: BREADY_to_S1 = BREADY_M1;
            default:  BREADY_to_S1 = 1'b0;
        endcase
    end

    // =============================
    //         Wire connect                 
    // =============================
    always_comb begin : S0_interface
        // AW
        AWID_S0     = AWID_to_S0;
        AWADDR_S0   = AWADDR_to_S0;
        AWLEN_S0    = AWLEN_to_S0;
        AWSIZE_S0   = AWSIZE_to_S0;
        AWBURST_S0  = AWBURST_to_S0;
        AWVALID_S0  = AWVALID_to_S0;
        // W
        WDATA_S0    = WDATA_to_S0;
        WSTRB_S0    = WSTRB_to_S0;
        WLAST_S0    = WLAST_to_S0;
        WVALID_S0   = WVALID_to_S0;
        // B
        BREADY_S0   = BREADY_to_S0;
        // AR
        ARID_S0     = ARID_to_S0;
        ARADDR_S0   = ARADDR_to_S0;
        ARLEN_S0    = ARLEN_to_S0;
        ARSIZE_S0   = ARSIZE_to_S0;
        ARBURST_S0  = ARBURST_to_S0;
        ARVALID_S0  = ARVALID_to_S0;
        // R
        RREADY_S0   = RREADY_to_S0;
    end

    always_comb begin : S1_interface
        // AW
        AWID_S1     = AWID_to_S1;
        AWADDR_S1   = AWADDR_to_S1;
        AWLEN_S1    = AWLEN_to_S1;
        AWSIZE_S1   = AWSIZE_to_S1;
        AWBURST_S1  = AWBURST_to_S1;
        AWVALID_S1  = AWVALID_to_S1;
        // W
        WDATA_S1    = WDATA_to_S1;
        WSTRB_S1    = WSTRB_to_S1;
        WLAST_S1    = WLAST_to_S1;
        WVALID_S1   = WVALID_to_S1;
        // B
        BREADY_S1   = BREADY_to_S1;
        // AR
        ARID_S1     = ARID_to_S1;
        ARADDR_S1   = ARADDR_to_S1;
        ARLEN_S1    = ARLEN_to_S1;
        ARSIZE_S1   = ARSIZE_to_S1;
        ARBURST_S1  = ARBURST_to_S1;
        ARVALID_S1  = ARVALID_to_S1;
        // R
        RREADY_S1   = RREADY_to_S1;
    end

    always_comb begin : M0_interface
        // AR
        ARREADY_M0  = ARREADY_to_M0;
        // R
        RID_M0      = RID_to_M0;
        RDATA_M0    = RDATA_to_M0;
        RRESP_M0    = RRESP_to_M0;
        RLAST_M0    = RLAST_to_M0;
        RVALID_M0   = RVALID_to_M0;
    end

    always_comb begin : M1_interface
        // AW
        AWREADY_M1  = AWREADY_to_M1;
        // W
        WREADY_M1   = WREADY_to_M1;
        // B
        BID_M1      = BID_to_M1;
        BRESP_M1    = BRESP_to_M1;
        BVALID_M1   = BVALID_to_M1;
        // AR
        ARREADY_M1  = ARREADY_to_M1;
        // R
        RID_M1      = RID_to_M1;
        RDATA_M1    = RDATA_to_M1;
        RRESP_M1    = RRESP_to_M1;
        RLAST_M1    = RLAST_to_M1;
        RVALID_M1   = RVALID_to_M1;
    end
endmodule
