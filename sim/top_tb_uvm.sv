`timescale 1ns/10ps
`include "../include/AXI_define.svh"
`include "../include/config.svh"
`include "../include/define.svh"
`define CYCLE 1.0 // Cycle time
`define MAX 500000 // Max cycle number
`ifdef SYN
`include "top_syn.v"
`timescale 1ns/10ps
`include "/SRAM/TS1N16ADFPCLLLVTA512X45M4SWSHOD.sv"
`else
`include "top.sv"
`include "/SRAM/SRAM_rtl.sv"
`endif
`timescale 1ns/10ps
`include "ROM/ROM.v"
`include "DRAM/DRAM.sv"
`include "konata.sv"
`include "commit_tracker.sv"
`define mem_word(addr) \
  {TOP.DM1.i_SRAM.MEMORY[addr >> 5][(addr&6'b011111)]}
`define SIM_END 'h3fff
`define SIM_END_CODE -32'd1
`define TEST_START 'h0000
module top_tb;

  logic clk;
  logic rst;
  logic [31:0] GOLDEN[128];
  integer gf, i, num,a,b,c;
  integer err;
  integer  cycle_err;
  logic [63:0]total_cycle ;
  string prog_path;
  string rdcycle;
  always #(`CYCLE/2) clk = ~clk;
  logic [7:0] Memory_byte0 [65535:0];
  logic [7:0] Memory_byte1 [65535:0];
  logic [7:0] Memory_byte2 [65535:0];
  logic [7:0] Memory_byte3 [65535:0];
  logic [31:0] Memory_word [65535:0];

  logic [31:0] ROM_out;
  logic [31:0] DRAM_Q;
  logic ROM_enable;
  logic ROM_read;
  logic [11:0] ROM_address;
  logic sensor_en;
  logic DRAM_CSn;
  logic [3:0]DRAM_WEn;
  logic DRAM_RASn;
  logic DRAM_CASn;
  logic [10:0] DRAM_A;
  logic [31:0] DRAM_D; 
  logic DRAM_valid;

  `ifdef ENABLE_DEBUG_PORTS
  // Debug signals
  logic        debug_fetch_req_valid;
  logic        debug_fetch_req_ready;
  logic [31:0] debug_fetch_addr;
  logic        debug_IF_valid;
  logic        debug_DC_ready;
  logic [31:0] debug_IF_out_pc;
  logic [31:0] debug_IF_out_inst;
  logic [$clog2(`ROB_LEN)-1:0] debug_DC_rob_idx;
  logic        debug_DC_valid;
  logic        debug_dispatch_valid;
  logic [31:0] debug_DC_out_pc;
  logic        debug_IS_valid;
  logic        debug_RR_ready;
  logic [$clog2(`ROB_LEN)-1:0] debug_IS_out_rob_idx;
  logic        debug_RR_valid;
  logic        debug_EX_ready_selected;
  logic [$clog2(`ROB_LEN)-1:0] debug_RR_out_rob_idx;
  logic [31:0] debug_RR_out_pc;
  logic        debug_WB_out_valid;
  logic [$clog2(`ROB_LEN)-1:0] debug_WB_out_rob_idx;
  logic        debug_commit;
  logic [$clog2(`ROB_LEN)-1:0] debug_commit_rob_idx;
  logic        debug_mispredict;
  logic [`ROB_LEN-1:0] debug_flush_mask;
  logic [31:0] debug_commit_pc;
  logic [31:0] debug_commit_inst;
  logic [5:0]  debug_commit_A_rd;
  logic [31:0] debug_commit_data;
  logic        debug_st_commit;
  logic [31:0] debug_st_addr;
  logic [31:0] debug_st_data;

  konata k1(
      .clk(clk),
      .rst(rst),

      .fetch_request(debug_fetch_req_valid && debug_fetch_req_ready),
      .fetch_addr(debug_fetch_addr),

      .IF_valid(debug_IF_valid),
      .DC_ready(debug_DC_ready),
      .IF_out_pc(debug_IF_out_pc),
      .IF_out_inst(debug_IF_out_inst),
      .ROB_tail(debug_DC_rob_idx),

      .DC_valid(debug_DC_valid),
      .IS_ready(debug_dispatch_valid),
      .DC_out_pc(debug_DC_out_pc),

      .IS_valid(debug_IS_valid),
      .RR_ready(debug_RR_ready),
      .IS_out_rob_idx(debug_IS_out_rob_idx),

      .RR_valid(debug_RR_valid),
      .EX_ready(debug_EX_ready_selected),
      .RR_out_rob_idx(debug_RR_out_rob_idx),
      .RR_out_pc(debug_RR_out_pc),

      .EX_valid(debug_WB_out_valid),
      .EX_out_rob_idx(debug_WB_out_rob_idx),

      .commit(debug_commit),
      .commit_rob_idx(debug_commit_rob_idx),
      
      .mispredict(debug_mispredict),
      .flush_mask(debug_flush_mask)
  );
  
  commit_tracker ct1(
      .clk(clk),
      .rst(rst),

      .commit_valid(debug_commit),
      .commit_pc(debug_commit_pc),
      .commit_inst(debug_commit_inst),
      .commit_Ard(debug_commit_A_rd),
      .commit_data(debug_commit_data),
      
      .st_commit(debug_st_commit),
      .st_addr(debug_st_addr),
      .st_data(debug_st_data)
  );
  `endif

  top TOP(
    .clk		  (clk),
    .clk2		  (clk2),
    .rst		  (rst),
    .rst2		  (rst2),
    .ROM_out      (ROM_out      ),
    .DRAM_valid   (DRAM_valid   ),
    .DRAM_Q       (DRAM_Q       ),
    .ROM_read     (ROM_read     ),
    .ROM_enable   (ROM_enable   ),
    .ROM_address  (ROM_address  ),
    .DRAM_CSn     (DRAM_CSn     ),
    .DRAM_WEn     (DRAM_WEn     ),
    .DRAM_RASn    (DRAM_RASn    ),
    .DRAM_CASn    (DRAM_CASn    ),
    .DRAM_A       (DRAM_A       ),
    .DRAM_D       (DRAM_D       )
    `ifdef ENABLE_DEBUG_PORTS
    ,
    .debug_fetch_req_valid(debug_fetch_req_valid),
    .debug_fetch_req_ready(debug_fetch_req_ready),
    .debug_fetch_addr(debug_fetch_addr),
    .debug_IF_valid(debug_IF_valid),
    .debug_DC_ready(debug_DC_ready),
    .debug_IF_out_pc(debug_IF_out_pc),
    .debug_IF_out_inst(debug_IF_out_inst),
    .debug_DC_rob_idx(debug_DC_rob_idx),
    .debug_DC_valid(debug_DC_valid),
    .debug_dispatch_valid(debug_dispatch_valid),
    .debug_DC_out_pc(debug_DC_out_pc),
    .debug_IS_valid(debug_IS_valid),
    .debug_RR_ready(debug_RR_ready),
    .debug_IS_out_rob_idx(debug_IS_out_rob_idx),
    .debug_RR_valid(debug_RR_valid),
    .debug_EX_ready_selected(debug_EX_ready_selected),
    .debug_RR_out_rob_idx(debug_RR_out_rob_idx),
    .debug_RR_out_pc(debug_RR_out_pc),
    .debug_WB_out_valid(debug_WB_out_valid),
    .debug_WB_out_rob_idx(debug_WB_out_rob_idx),
    .debug_commit(debug_commit),
    .debug_commit_rob_idx(debug_commit_rob_idx),
    .debug_mispredict(debug_mispredict),
    .debug_flush_mask(debug_flush_mask),
    .debug_commit_pc(debug_commit_pc),
    .debug_commit_inst(debug_commit_inst),
    .debug_commit_A_rd(debug_commit_A_rd),
    .debug_commit_data(debug_commit_data),
    .debug_st_commit(debug_st_commit),
    .debug_st_addr(debug_st_addr),
    .debug_st_data(debug_st_data)
    `endif
  );  

  ROM i_ROM(
    .CK (clk        ),
    .CS (ROM_enable ),
    .OE (ROM_read   ),
    .A  (ROM_address),
    .DO (ROM_out    )
  );

  DRAM i_DRAM(
    .CK   (clk        ),
    .Q    (DRAM_Q     ),
    .RST  (rst        ),
    .CSn  (DRAM_CSn   ),
    .WEn  (DRAM_WEn   ),
    .RASn (DRAM_RASn  ),
    .CASn (DRAM_CASn  ),
    .A    (DRAM_A     ),
    .D    (DRAM_D     ),
    .VALID(DRAM_valid )
  );

  initial
  begin
    $value$plusargs("prog_path=%s", prog_path);
	$value$plusargs("rdcycle=%s", rdcycle);
    clk = 0;    rst = 1;
    #(`CYCLE)   rst = 0;

    $readmemh({prog_path, "/main0.hex"}, Memory_byte0);
    $readmemh({prog_path, "/main1.hex"}, Memory_byte1); 
    $readmemh({prog_path, "/main2.hex"}, Memory_byte2);
    $readmemh({prog_path, "/main3.hex"}, Memory_byte3); 
    $readmemh({prog_path, "/dram0.hex"}, i_DRAM.Memory_byte0);
    $readmemh({prog_path, "/dram1.hex"}, i_DRAM.Memory_byte1);
    $readmemh({prog_path, "/dram2.hex"}, i_DRAM.Memory_byte2);
    $readmemh({prog_path, "/dram3.hex"}, i_DRAM.Memory_byte3);
    
    for(a = 0; a < 65536; a = a + 1) begin
        Memory_word[a] = {Memory_byte3[a], Memory_byte2[a], Memory_byte1[a], Memory_byte0[a]};
    end

    for(int b = 0; b < 16384; b = b + 1) begin
        TOP.IM1.i_SRAM.MEMORY[b/32][b%32] = 32'b0;
        TOP.DM1.i_SRAM.MEMORY[b/32][b%32] = 32'b0;
        i_ROM.Memory_byte0[b] = 8'h00;
        i_ROM.Memory_byte1[b] = 8'h00;
        i_ROM.Memory_byte2[b] = 8'h00;
        i_ROM.Memory_byte3[b] = 8'h00;
    end

    for(b = 0; b < 16384; b = b + 1) begin
        TOP.IM1.i_SRAM.MEMORY[b/32][b%32] = Memory_word[16384 + b];
    end
    for(b = 0; b < 16384; b = b + 1) begin
        TOP.DM1.i_SRAM.MEMORY[b/32][b%32] = Memory_word[32768 + b];
    end

    wait(`mem_word(`SIM_END) == `SIM_END_CODE);
    $display("\nDone\n");
    err = 0;

    $display("\n");
    $display("\n");
    $display("        ****************************               ");
    $display("        **                        **       |\__||  ");
    $display("        **  Congratulations !!    **      / O.O  | ");
    $display("        **                        **    /_____   | ");
    $display("        **  Simulation PASS!!     **   /^ ^ ^ \\  |");
    $display("        **                        **  |^ ^ ^ ^ |w| ");
    $display("        ****************************   \\m___m__|_|");
    $display("\n");

    $finish;
  end

always@(posedge clk, posedge rst)
begin
  if(rst) total_cycle <= 64'd0;
  else total_cycle <= total_cycle+64'd1;
end

  `ifdef SYN
  initial $sdf_annotate("../syn/top_syn.sdf", TOP);
  `endif

  initial
  begin
    `ifdef FSDB
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0, TOP);
    `elsif FSDB_ALL
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars("+struct", "+mda", TOP);
    `endif
    #(`CYCLE*`MAX)
    
    $display("SIM_END(%5d) = %h, expect = %h", `SIM_END, `mem_word(`SIM_END), `SIM_END_CODE);

    $display("\n");
    $display("\n");
    $display("        ****************************               ");
    $display("        **                        **       |\__||  ");
    $display("        **  Congratulations !!    **      / O.O  | ");
    $display("        **                        **    /_____   | ");
    $display("        **  Simulation PASS!!     **   /^ ^ ^ \\  |");
    $display("        **                        **  |^ ^ ^ ^ |w| ");
    $display("        ****************************   \\m___m__|_|");
    $display("\n");

    $finish;
  end

endmodule