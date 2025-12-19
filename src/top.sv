//////////////////////////////////////////////////////////////////////
//          ██╗       ██████╗   ██╗  ██╗    ██████╗            		//
//          ██║       ██╔══█║   ██║  ██║    ██╔══█║            		//
//          ██║       ██████║   ███████║    ██████║            		//
//          ██║       ██╔═══╝   ██╔══██║    ██╔═══╝            		//
//          ███████╗  ██║  	    ██║  ██║    ██║  	           		//
//          ╚══════╝  ╚═╝  	    ╚═╝  ╚═╝    ╚═╝  	           		//
//                                                             		//
// 	2025 Advanced VLSI System Design, Advisor: Lih-Yih, Chiou		//
//                                                             		//
//////////////////////////////////////////////////////////////////////
//                                                             		//
// 	Author: 		                           				  	    //
//	Filename:		top.sv		                                    //
//	Description:	top module for AVSD HW1                     	//
// 	Date:			2025/XX/XX								   		//
// 	Version:		1.0	    								   		//
//////////////////////////////////////////////////////////////////////
`include "../include/define.svh"
`include "../include/AXI_define.svh"
`include "../include/config.svh"
`include "AXI/AXI.sv"
`include "SRAM_wrapper.sv"
`include "CPU_wrapper.sv"

module top(
    input clk,
    input rst
);

    logic ACLK;
    logic ARESETn;

    assign ACLK     = clk;
    assign ARESETn  = ~rst;

    /*
    // ---------------
    //     Master1   
    // ---------------

    // AXI Master1 Write Address Channel (DM)
    logic [`AXI_ID_BITS-1:0]        AWID_M1;
    logic [`AXI_ADDR_BITS-1:0]      AWADDR_M1;
    logic [`AXI_LEN_BITS-1:0]       AWLEN_M1;
    logic [`AXI_SIZE_BITS-1:0]      AWSIZE_M1;
    logic [1:0]                     AWBURST_M1;
    logic                           AWVALID_M1;
    logic                           AWREADY_M1;
        
    // AXI Master1 Write Data Channel (DM)
    logic [`AXI_DATA_BITS-1:0]      WDATA_M1;
    logic [`AXI_STRB_BITS-1:0]      WSTRB_M1;
    logic                           WLAST_M1;
    logic                           WVALID_M1;
    logic                           WREADY_M1;
        
    // AXI Master1 Write Response Channel (DM)
    logic [`AXI_ID_BITS-1:0]        BID_M1;
    logic [1:0]                     BRESP_M1;
    logic                           BVALID_M1;
    logic                           BREADY_M1;

    // AXI Master1 Read Address Channel (DM)
    logic [`AXI_ID_BITS-1:0]        ARID_M1;
    logic [`AXI_ADDR_BITS-1:0]      ARADDR_M1;
    logic [`AXI_LEN_BITS-1:0]       ARLEN_M1;
    logic [`AXI_SIZE_BITS-1:0]      ARSIZE_M1;
    logic [1:0]                     ARBURST_M1;
    logic                           ARVALID_M1;
    logic                           ARREADY_M1;
        
    // AXI Master1 Read Data Channel (DM)
    logic [`AXI_ID_BITS-1:0]        RID_M1;
    logic [`AXI_DATA_BITS-1:0]      RDATA_M1;
    logic [1:0]                     RRESP_M1;
    logic                           RLAST_M1;
    logic                           RVALID_M1;
    logic                           RREADY_M1;

    // ---------------
    //     Master0     
    // ---------------

    // AXI Master0 Read Address Channel (IM)
    logic [`AXI_ID_BITS-1:0]        ARID_M0;
    logic [`AXI_ADDR_BITS-1:0]      ARADDR_M0;
    logic [`AXI_LEN_BITS-1:0]       ARLEN_M0;
    logic [`AXI_SIZE_BITS-1:0]      ARSIZE_M0;
    logic [1:0]                     ARBURST_M0;
    logic                           ARVALID_M0;
    logic                           ARREADY_M0;
        
    // AXI Master0 Read Data Channel (IM)
    logic [`AXI_ID_BITS-1:0]        RID_M0;
    logic [`AXI_DATA_BITS-1:0]      RDATA_M0;
    logic [1:0]                     RRESP_M0;
    logic                           RLAST_M0;
    logic                           RVALID_M0;
    logic                           RREADY_M0;

    CPU_wrapper CPU1(
        .ACLK       	(ACLK        ),
        .ARESETn    	(ARESETn     ),
        // AXI Master1 Write Address Channel (DM)
        .AWID_M1    	(AWID_M1     ),
        .AWADDR_M1  	(AWADDR_M1   ),
        .AWLEN_M1   	(AWLEN_M1    ),
        .AWSIZE_M1  	(AWSIZE_M1   ),
        .AWBURST_M1 	(AWBURST_M1  ),
        .AWVALID_M1 	(AWVALID_M1  ),
        .AWREADY_M1 	(AWREADY_M1  ),
        // AXI Master1 Write Data Channel (DM)
        .WDATA_M1   	(WDATA_M1    ),
        .WSTRB_M1   	(WSTRB_M1    ),
        .WLAST_M1   	(WLAST_M1    ),
        .WVALID_M1  	(WVALID_M1   ),
        .WREADY_M1  	(WREADY_M1   ),
        // AXI Master1 Write Response Channel (DM)
        .BID_M1     	(BID_M1      ),
        .BRESP_M1   	(BRESP_M1    ),
        .BVALID_M1  	(BVALID_M1   ),
        .BREADY_M1  	(BREADY_M1   ),
        // AXI Master1 Read Address Channel (DM)
        .ARID_M1    	(ARID_M1     ),
        .ARADDR_M1  	(ARADDR_M1   ),
        .ARLEN_M1   	(ARLEN_M1    ),
        .ARSIZE_M1  	(ARSIZE_M1   ),
        .ARBURST_M1 	(ARBURST_M1  ),
        .ARVALID_M1 	(ARVALID_M1  ),
        .ARREADY_M1 	(ARREADY_M1  ),
        // AXI Master1 Read Data Channel (DM)
        .RID_M1     	(RID_M1      ),
        .RDATA_M1   	(RDATA_M1    ),
        .RRESP_M1   	(RRESP_M1    ),
        .RLAST_M1   	(RLAST_M1    ),
        .RVALID_M1  	(RVALID_M1   ),
        .RREADY_M1  	(RREADY_M1   ),
        // AXI Master0 Read Address Channel (IM)
        .ARID_M0    	(ARID_M0     ),
        .ARADDR_M0  	(ARADDR_M0   ),
        .ARLEN_M0   	(ARLEN_M0    ),
        .ARSIZE_M0  	(ARSIZE_M0   ),
        .ARBURST_M0 	(ARBURST_M0  ),
        .ARVALID_M0 	(ARVALID_M0  ),
        .ARREADY_M0 	(ARREADY_M0  ),
        // AXI Master0 Read Data Channel (IM)
        .RID_M0     	(RID_M0      ),
        .RDATA_M0   	(RDATA_M0    ),
        .RRESP_M0   	(RRESP_M0    ),
        .RLAST_M0   	(RLAST_M0    ),
        .RVALID_M0  	(RVALID_M0   ),
        .RREADY_M0  	(RREADY_M0   )
    );
    
    SRAM_wrapper IM1(
        .ACLK       	(ACLK        ),
        .ARESETn    	(ARESETn     ),
        // AW Channel
        .AWID_S    	    ( '0          ),
        .AWADDR_S    	( '0          ),
        .AWLEN_S     	( '0          ),
        .AWSIZE_S    	( '0          ),
        .AWBURST_S   	( '0          ),
        .AWVALID_S   	( '0          ),
        .AWREADY_S   	(             ),
        // W Channel
        .WDATA_S     	( '0          ),
        .WSTRB_S     	( '0          ),
        .WLAST_S     	( '0          ),
        .WVALID_S    	( '0          ),
        .WREADY_S    	(             ),
        // B Channel
        .BID_S       	(             ),
        .BRESP_S     	(             ),
        .BVALID_S    	(             ),
        .BREADY_S    	( '0          ),
        // AR Channel
        .ARID_S      	(ARID_M0      ),
        .ARADDR_S    	(ARADDR_M0    ),
        .ARLEN_S     	(ARLEN_M0     ),
        .ARSIZE_S    	(ARSIZE_M0    ),
        .ARBURST_S   	(ARBURST_M0   ),
        .ARVALID_S   	(ARVALID_M0   ),
        .ARREADY_S   	(ARREADY_M0   ),
        // R Channel
        .RID_S       	(RID_M0       ),
        .RDATA_S     	(RDATA_M0     ),
        .RRESP_S     	(RRESP_M0     ),
        .RLAST_S     	(RLAST_M0     ),
        .RVALID_S    	(RVALID_M0    ),    
        .RREADY_S    	(RREADY_M0    )
    );

    
    SRAM_wrapper DM1(
        .ACLK       	(ACLK         ),
        .ARESETn    	(ARESETn      ),
        // AW Channel
        .AWID_S    	    (AWID_M1      ),
        .AWADDR_S    	(AWADDR_M1    ),
        .AWLEN_S     	(AWLEN_M1     ),
        .AWSIZE_S    	(AWSIZE_M1    ),
        .AWBURST_S   	(AWBURST_M1   ),
        .AWVALID_S   	(AWVALID_M1   ),
        .AWREADY_S   	(AWREADY_M1   ),
        // W Channel
        .WDATA_S     	(WDATA_M1     ),
        .WSTRB_S     	(WSTRB_M1     ),
        .WLAST_S     	(WLAST_M1     ),
        .WVALID_S    	(WVALID_M1    ),
        .WREADY_S    	(WREADY_M1    ),
        // B Channel
        .BID_S       	(BID_M1       ),
        .BRESP_S     	(BRESP_M1     ),
        .BVALID_S    	(BVALID_M1    ),
        .BREADY_S    	(BREADY_M1    ),
        // AR Channel
        .ARID_S      	(ARID_M1      ),
        .ARADDR_S    	(ARADDR_M1    ),
        .ARLEN_S     	(ARLEN_M1     ),
        .ARSIZE_S    	(ARSIZE_M1    ),
        .ARBURST_S   	(ARBURST_M1   ),
        .ARVALID_S   	(ARVALID_M1   ),
        .ARREADY_S   	(ARREADY_M1   ),
        // R Channel
        .RID_S       	(RID_M1       ),
        .RDATA_S     	(RDATA_M1     ),
        .RRESP_S     	(RRESP_M1     ),
        .RLAST_S     	(RLAST_M1     ),
        .RVALID_S    	(RVALID_M1    ),    
        .RREADY_S    	(RREADY_M1    )
    );
    */

    // --------------------------------------------
    //       Write Address Channel - Master1       
    // --------------------------------------------
    logic [`AXI_ID_BITS  -1:0] awid_m1;
    logic [`AXI_ADDR_BITS-1:0] awaddr_m1;
    logic [`AXI_LEN_BITS -1:0] awlen_m1;
    logic [`AXI_SIZE_BITS-1:0] awsize_m1;
    logic [1:0]                awburst_m1;
    logic                      awvalid_m1;
    logic                      awready_m1;

    // --------------------------------------------
    //         Write Data Channel - Master1        
    // --------------------------------------------
    logic [`AXI_DATA_BITS-1:0] wdata_m1;
    logic [`AXI_STRB_BITS-1:0] wstrb_m1;
    logic                      wlast_m1;
    logic                      wvalid_m1;
    logic                      wready_m1;

    // --------------------------------------------
    //       Write Response Channel - Master1      
    // --------------------------------------------
    logic [`AXI_ID_BITS  -1:0] bid_m1;
    logic [1:0]                bresp_m1;
    logic                      bvalid_m1;
    logic                      bready_m1;

    // --------------------------------------------
    //        Read Address Channel - Master0       
    // --------------------------------------------
    logic [`AXI_ID_BITS  -1:0] arid_m0;
    logic [`AXI_DATA_BITS-1:0] araddr_m0;
    logic [`AXI_LEN_BITS -1:0] arlen_m0;
    logic [`AXI_SIZE_BITS-1:0] arsize_m0;
    logic [1:0]                arburst_m0;
    logic                      arvalid_m0;
    logic                      arready_m0;

    // --------------------------------------------
    //          Read Data Channel - Master0        
    // --------------------------------------------
    logic [`AXI_ID_BITS  -1:0] rid_m0;
    logic [`AXI_DATA_BITS-1:0] rdata_m0;
    logic [1:0]                rresp_m0;
    logic                      rlast_m0;
    logic                      rvalid_m0;
    logic                      rready_m0;

    // --------------------------------------------
    //        Read Address Channel - Master1       
    // -------------------------------------------- 
    logic [`AXI_ID_BITS  -1:0] arid_m1;
    logic [`AXI_DATA_BITS-1:0] araddr_m1;
    logic [`AXI_LEN_BITS -1:0] arlen_m1;
    logic [`AXI_SIZE_BITS-1:0] arsize_m1;
    logic [1:0]                arburst_m1;
    logic                      arvalid_m1;
    logic                      arready_m1;

    // --------------------------------------------
    //          Read Data Channel - Master1        
    // --------------------------------------------
    logic [`AXI_ID_BITS  -1:0] rid_m1;
    logic [`AXI_DATA_BITS-1:0] rdata_m1;
    logic [1:0]                rresp_m1;
    logic                      rlast_m1;
    logic                      rvalid_m1;
    logic                      rready_m1;

    // --------------------------------------------
    //        Write Address Channel - Slave0       
    // --------------------------------------------
    logic [`AXI_IDS_BITS -1:0] awid_s0;
    logic [`AXI_ADDR_BITS-1:0] awaddr_s0;
    logic [`AXI_LEN_BITS -1:0] awlen_s0;
    logic [`AXI_SIZE_BITS-1:0] awsize_s0;
    logic [1:0]                awburst_s0;
    logic                      awvalid_s0;
    logic                      awready_s0;

    // --------------------------------------------
    //         Write Data Channel - Slave0         
    // --------------------------------------------
    logic [`AXI_DATA_BITS-1:0] wdata_s0;
    logic [`AXI_STRB_BITS-1:0] wstrb_s0;
    logic                      wlast_s0;
    logic                      wvalid_s0;
    logic                      wready_s0;

    // --------------------------------------------
    //       Write Response Channel - Slave0       
    // --------------------------------------------
    logic [`AXI_IDS_BITS -1:0] bid_s0;
    logic [1:0]                bresp_s0;
    logic                      bvalid_s0;
    logic                      bready_s0;

    // --------------------------------------------
    //        Read Address Channel - Slave0        
    // --------------------------------------------
    logic [`AXI_IDS_BITS -1:0] arid_s0;
    logic [`AXI_DATA_BITS-1:0] araddr_s0;
    logic [`AXI_LEN_BITS -1:0] arlen_s0;
    logic [`AXI_SIZE_BITS-1:0] arsize_s0;
    logic [1:0]                arburst_s0;
    logic                      arvalid_s0;
    logic                      arready_s0;

    // --------------------------------------------
    //          Read Data Channel - Slave0         
    // --------------------------------------------
    logic [`AXI_IDS_BITS -1:0] rid_s0;
    logic [`AXI_DATA_BITS-1:0] rdata_s0;
    logic [1:0]                rresp_s0;
    logic                      rlast_s0;
    logic                      rvalid_s0;
    logic                      rready_s0;

    // --------------------------------------------
    //        Write Address Channel - Slave1       
    // --------------------------------------------
    logic [`AXI_IDS_BITS -1:0] awid_s1;
    logic [`AXI_ADDR_BITS-1:0] awaddr_s1;
    logic [`AXI_LEN_BITS -1:0] awlen_s1;
    logic [`AXI_SIZE_BITS-1:0] awsize_s1;
    logic [1:0]                awburst_s1;
    logic                      awvalid_s1;
    logic                      awready_s1;

    // --------------------------------------------
    //         Write Data Channel - Slave1         
    // --------------------------------------------
    logic [`AXI_DATA_BITS-1:0] wdata_s1;
    logic [`AXI_STRB_BITS-1:0] wstrb_s1;
    logic                      wlast_s1;
    logic                      wvalid_s1;
    logic                      wready_s1;

    // --------------------------------------------
    //       Write Response Channel - Slave1       
    // --------------------------------------------
    logic [`AXI_IDS_BITS -1:0] bid_s1;
    logic [1:0]                bresp_s1;
    logic                      bvalid_s1;
    logic                      bready_s1;

    // --------------------------------------------
    //        Read Address Channel - Slave1        
    // --------------------------------------------
    logic [`AXI_IDS_BITS -1:0] arid_s1;
    logic [`AXI_DATA_BITS-1:0] araddr_s1;
    logic [`AXI_LEN_BITS -1:0] arlen_s1;
    logic [`AXI_SIZE_BITS-1:0] arsize_s1;
    logic [1:0]                arburst_s1;
    logic                      arvalid_s1;
    logic                      arready_s1;

    // --------------------------------------------
    //          Read Data Channel - Slave1         
    // --------------------------------------------
    logic [`AXI_IDS_BITS -1:0] rid_s1;
    logic [`AXI_DATA_BITS-1:0] rdata_s1;
    logic [1:0]                rresp_s1;
    logic                      rlast_s1;
    logic                      rvalid_s1;
    logic                      rready_s1;


    CPU_wrapper CPU_wrapper(
        .ACLK          (clk       ),
        .ARESETn       (~rst      ),

        .AWID_M1       (awid_m1   ),
        .AWADDR_M1     (awaddr_m1 ),
        .AWLEN_M1      (awlen_m1  ),
        .AWSIZE_M1     (awsize_m1 ),
        .AWBURST_M1    (awburst_m1),
        .AWVALID_M1    (awvalid_m1),
        .AWREADY_M1    (awready_m1),

        .WDATA_M1      (wdata_m1  ),
        .WSTRB_M1      (wstrb_m1  ),
        .WLAST_M1      (wlast_m1  ),
        .WVALID_M1     (wvalid_m1 ),
        .WREADY_M1     (wready_m1 ),

        .BID_M1        (bid_m1    ),
        .BRESP_M1      (bresp_m1  ),
        .BVALID_M1     (bvalid_m1 ),
        .BREADY_M1     (bready_m1 ),

        .ARID_M0       (arid_m0   ),
        .ARADDR_M0     (araddr_m0 ),
        .ARLEN_M0      (arlen_m0  ),
        .ARSIZE_M0     (arsize_m0 ),
        .ARBURST_M0    (arburst_m0),
        .ARVALID_M0    (arvalid_m0),
        .ARREADY_M0    (arready_m0),

        .RID_M0        (rid_m0    ),
        .RDATA_M0      (rdata_m0  ),
        .RRESP_M0      (rresp_m0  ),
        .RLAST_M0      (rlast_m0  ),
        .RVALID_M0     (rvalid_m0 ),
        .RREADY_M0     (rready_m0 ),

        .ARID_M1       (arid_m1   ),
        .ARADDR_M1     (araddr_m1 ),
        .ARLEN_M1      (arlen_m1  ),
        .ARSIZE_M1     (arsize_m1 ),
        .ARBURST_M1    (arburst_m1),
        .ARVALID_M1    (arvalid_m1),
        .ARREADY_M1    (arready_m1),

        .RID_M1        (rid_m1    ),
        .RDATA_M1      (rdata_m1  ),
        .RRESP_M1      (rresp_m1  ),
        .RLAST_M1      (rlast_m1  ),
        .RVALID_M1     (rvalid_m1 ),
        .RREADY_M1     (rready_m1 )
    );

    AXI AXI(
        .ACLK          (clk       ),
        .ARESETn       (~rst      ),

        .AWID_M1       (awid_m1   ),
        .AWADDR_M1     (awaddr_m1 ),
        .AWLEN_M1      (awlen_m1  ),
        .AWSIZE_M1     (awsize_m1 ),
        .AWBURST_M1    (awburst_m1),
        .AWVALID_M1    (awvalid_m1),
        .AWREADY_M1    (awready_m1),

        .WDATA_M1      (wdata_m1  ),
        .WSTRB_M1      (wstrb_m1  ),
        .WLAST_M1      (wlast_m1  ),
        .WVALID_M1     (wvalid_m1 ),
        .WREADY_M1     (wready_m1 ),

        .BID_M1        (bid_m1    ),
        .BRESP_M1      (bresp_m1  ),
        .BVALID_M1     (bvalid_m1 ),
        .BREADY_M1     (bready_m1 ),

        .ARID_M0       (arid_m0   ),
        .ARADDR_M0     (araddr_m0 ),
        .ARLEN_M0      (arlen_m0  ),
        .ARSIZE_M0     (arsize_m0 ),
        .ARBURST_M0    (arburst_m0),
        .ARVALID_M0    (arvalid_m0),
        .ARREADY_M0    (arready_m0),

        .RID_M0        (rid_m0    ),
        .RDATA_M0      (rdata_m0  ),
        .RRESP_M0      (rresp_m0  ),
        .RLAST_M0      (rlast_m0  ),
        .RVALID_M0     (rvalid_m0 ),
        .RREADY_M0     (rready_m0 ),

        .ARID_M1       (arid_m1   ),
        .ARADDR_M1     (araddr_m1 ),
        .ARLEN_M1      (arlen_m1  ),
        .ARSIZE_M1     (arsize_m1 ),
        .ARBURST_M1    (arburst_m1),
        .ARVALID_M1    (arvalid_m1),
        .ARREADY_M1    (arready_m1),

        .RID_M1        (rid_m1    ),
        .RDATA_M1      (rdata_m1  ),
        .RRESP_M1      (rresp_m1  ),
        .RLAST_M1      (rlast_m1  ),
        .RVALID_M1     (rvalid_m1 ),
        .RREADY_M1     (rready_m1 ),

        .AWID_S0       (awid_s0   ),
        .AWADDR_S0     (awaddr_s0 ),
        .AWLEN_S0      (awlen_s0  ),
        .AWSIZE_S0     (awsize_s0 ),
        .AWBURST_S0    (awburst_s0),
        .AWVALID_S0    (awvalid_s0),
        .AWREADY_S0    (awready_s0),

        .WDATA_S0      (wdata_s0  ),
        .WSTRB_S0      (wstrb_s0  ),
        .WLAST_S0      (wlast_s0  ),
        .WVALID_S0     (wvalid_s0 ),
        .WREADY_S0     (wready_s0 ),

        .BID_S0        (bid_s0    ),
        .BRESP_S0      (bresp_s0  ),
        .BVALID_S0     (bvalid_s0 ),
        .BREADY_S0     (bready_s0 ),

        .AWID_S1       (awid_s1   ),
        .AWADDR_S1     (awaddr_s1 ),
        .AWLEN_S1      (awlen_s1  ),
        .AWSIZE_S1     (awsize_s1 ),
        .AWBURST_S1    (awburst_s1),
        .AWVALID_S1    (awvalid_s1),
        .AWREADY_S1    (awready_s1),

        .WDATA_S1      (wdata_s1  ),
        .WSTRB_S1      (wstrb_s1  ),
        .WLAST_S1      (wlast_s1  ),
        .WVALID_S1     (wvalid_s1 ),
        .WREADY_S1     (wready_s1 ),

        .BID_S1        (bid_s1    ),
        .BRESP_S1      (bresp_s1  ),
        .BVALID_S1     (bvalid_s1 ),
        .BREADY_S1     (bready_s1 ),

        .ARID_S0       (arid_s0   ),
        .ARADDR_S0     (araddr_s0 ),
        .ARLEN_S0      (arlen_s0  ),
        .ARSIZE_S0     (arsize_s0 ),
        .ARBURST_S0    (arburst_s0),
        .ARVALID_S0    (arvalid_s0),
        .ARREADY_S0    (arready_s0),

        .RID_S0        (rid_s0    ),
        .RDATA_S0      (rdata_s0  ),
        .RRESP_S0      (rresp_s0  ),
        .RLAST_S0      (rlast_s0  ),
        .RVALID_S0     (rvalid_s0 ),
        .RREADY_S0     (rready_s0 ),

        .ARID_S1       (arid_s1   ),
        .ARADDR_S1     (araddr_s1 ),
        .ARLEN_S1      (arlen_s1  ),
        .ARSIZE_S1     (arsize_s1 ),
        .ARBURST_S1    (arburst_s1),
        .ARVALID_S1    (arvalid_s1),
        .ARREADY_S1    (arready_s1),

        .RID_S1        (rid_s1    ),
        .RDATA_S1      (rdata_s1  ),
        .RRESP_S1      (rresp_s1  ),
        .RLAST_S1      (rlast_s1  ),
        .RVALID_S1     (rvalid_s1 ),
        .RREADY_S1     (rready_s1 )
    );

    SRAM_wrapper IM1(

        .ACLK          (clk       ),
        .ARESETn       (~rst      ),

        .AWID_S        (awid_s0   ),
        .AWADDR_S      (awaddr_s0 ),
        .AWLEN_S       (awlen_s0  ),
        .AWSIZE_S      (awsize_s0 ),
        .AWBURST_S     (awburst_s0),
        .AWVALID_S     (awvalid_s0),
        .AWREADY_S     (awready_s0),

        .WDATA_S       (wdata_s0  ),
        .WSTRB_S       (wstrb_s0  ),
        .WLAST_S       (wlast_s0  ),
        .WVALID_S      (wvalid_s0 ),
        .WREADY_S      (wready_s0 ),

        .BID_S         (bid_s0    ),
        .BRESP_S       (bresp_s0  ),
        .BVALID_S      (bvalid_s0 ),
        .BREADY_S      (bready_s0 ),

        .ARID_S        (arid_s0   ),
        .ARADDR_S      (araddr_s0 ),
        .ARLEN_S       (arlen_s0  ),
        .ARSIZE_S      (arsize_s0 ),
        .ARBURST_S     (arburst_s0),
        .ARVALID_S     (arvalid_s0),
        .ARREADY_S     (arready_s0),

        .RID_S         (rid_s0    ),
        .RDATA_S       (rdata_s0  ),
        .RRESP_S       (rresp_s0  ),
        .RLAST_S       (rlast_s0  ),
        .RVALID_S      (rvalid_s0 ),
        .RREADY_S      (rready_s0 )
    );

    SRAM_wrapper DM1(
        .ACLK          (clk       ),
        .ARESETn       (~rst      ),

        .AWID_S        (awid_s1   ),
        .AWADDR_S      (awaddr_s1 ),
        .AWLEN_S       (awlen_s1  ),
        .AWSIZE_S      (awsize_s1 ),
        .AWBURST_S     (awburst_s1),
        .AWVALID_S     (awvalid_s1),
        .AWREADY_S     (awready_s1),

        .WDATA_S       (wdata_s1  ),
        .WSTRB_S       (wstrb_s1  ),
        .WLAST_S       (wlast_s1  ),
        .WVALID_S      (wvalid_s1 ),
        .WREADY_S      (wready_s1 ),

        .BID_S         (bid_s1    ),
        .BRESP_S       (bresp_s1  ),
        .BVALID_S      (bvalid_s1 ),
        .BREADY_S      (bready_s1 ),

        .ARID_S        (arid_s1   ),
        .ARADDR_S      (araddr_s1 ),
        .ARLEN_S       (arlen_s1  ),
        .ARSIZE_S      (arsize_s1 ),
        .ARBURST_S     (arburst_s1),
        .ARVALID_S     (arvalid_s1),
        .ARREADY_S     (arready_s1),

        .RID_S         (rid_s1    ),
        .RDATA_S       (rdata_s1  ),
        .RRESP_S       (rresp_s1  ),
        .RLAST_S       (rlast_s1  ),
        .RVALID_S      (rvalid_s1 ),
        .RREADY_S      (rready_s1 )
    );




endmodule
