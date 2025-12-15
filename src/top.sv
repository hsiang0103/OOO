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
`include "../include/config.svh"
`include "SRAM_wrapper.sv"
`include "CPU.sv"

module top(
    input clk,
    input rst
);

logic [31:0]    fetch_data;
logic           fetch_data_valid;
logic           fetch_req_ready;
logic [31:0]    fetch_addr;
logic           fetch_req_valid;

logic [31:0] DM_rd_data;
logic        DM_c_en;
logic        DM_r_en;
logic [31:0] DM_w_en;
logic [31:0] DM_addr;
logic [31:0] DM_w_data;

CPU CPU(
    .clk(clk),
    .rst(rst),
    // IM
    .fetch_data(fetch_data),
    .fetch_data_valid(fetch_data_valid),
    .fetch_req_ready(fetch_req_ready),
    .fetch_addr(fetch_addr),
    .fetch_req_valid(fetch_req_valid),
    // DM
    .DM_rd_data(DM_rd_data),
    .DM_c_en(1'b0),
    .DM_r_en(DM_r_en),
    .DM_w_en(DM_w_en),
    .DM_addr(DM_addr),
    .DM_w_data(DM_w_data)
);

always_ff @(posedge clk) begin
    if (rst) begin
        fetch_req_ready     <= 1'b0;
        fetch_data_valid    <= 1'b0;
    end
    else begin
        fetch_req_ready     <= fetch_req_valid;
        fetch_data_valid    <= fetch_req_ready && fetch_req_valid;
    end
end

SRAM_wrapper IM1(
    .CLK(clk),
    .RST(rst),
    .CEB(1'b0),
    .WEB(1'b1), 
    .BWEB(32'hFFFFFFFF),
    .A(fetch_addr[15:2]),
    .DI(32'b0), 
    .DO(fetch_data)
);

SRAM_wrapper DM1(
    .CLK(clk),
    .RST(rst),
    .CEB(1'b0),
    .WEB(DM_r_en), 
    .BWEB(DM_w_en),
    .A(DM_addr[15:2]),
    .DI(DM_w_data), 
    .DO(DM_rd_data)
);


endmodule