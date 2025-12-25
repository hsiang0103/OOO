`timescale 1ns/10ps
`define CYCLE 1.0 // Cycle time
`define MAX 500000 // Max cycle number
`ifdef SYN
`include "top_syn.v"
`timescale 1ns/10ps
// `include "/usr/cad/CBDK/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/VERILOG/N16ADFP_StdCell.v"
`include "/SRAM/TS1N16ADFPCLLLVTA512X45M4SWSHOD.sv"
`else
`include "top.sv"
`include "/SRAM/SRAM_rtl.sv"
`endif
`timescale 1ns/10ps
`include "ROM/ROM.v"
`include "DRAM/DRAM.sv"
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

    for(b = 0; b < 16384; b = b + 1) begin
        TOP.IM1.i_SRAM.MEMORY[b/32][b%32] = Memory_word[16384 + b];
    end
    for(b = 0; b < 16384; b = b + 1) begin
        TOP.DM1.i_SRAM.MEMORY[b/32][b%32] = Memory_word[32768 + b];
    end

    num = 0;
    gf = $fopen({prog_path, "/golden.hex"}, "r");
    while (!$feof(gf))
    begin
      $fscanf(gf, "%h\n", GOLDEN[num]);
      num++;
    end
    $fclose(gf);

    wait(`mem_word(`SIM_END) == `SIM_END_CODE);
    $display("\nDone\n");
    err = 0;

    for (i = 0; i < num; i++)
    begin
      if (`mem_word(`TEST_START + i) !== GOLDEN[i])
      begin
        $display("DM[%4d] = %h, expect = %h", `TEST_START + i, `mem_word(`TEST_START + i), GOLDEN[i]);
        err = err + 1;
      end
      else
      begin
        $display("DM[%4d] = %h, pass", `TEST_START + i, `mem_word(`TEST_START + i));
      end
    end
	//`ifdef RDCYCLE
	if (rdcycle == "1") begin
	  
	  $display("your total cycle is %f ",`mem_word(`TEST_START + num));
	  $display("your total cycle is %f ",`mem_word(`TEST_START + num+1));
	  
	end
	
	//`endif
    result(err, num);
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
    for (i = 0; i < num; i++)
    begin
      if (`mem_word(`TEST_START + i) !== GOLDEN[i])
      begin
        $display("DM[%4d] = %h, expect = %h", `TEST_START + i, `mem_word(`TEST_START + i), GOLDEN[i]);
        err = err + 1;
      end
      else
      begin
        $display("DM[%4d] = %h, pass", `TEST_START + i, `mem_word(`TEST_START + i));
      end
    end
    $display("SIM_END(%5d) = %h, expect = %h", `SIM_END, `mem_word(`SIM_END), `SIM_END_CODE);
    result(num, num);
    $finish;
  end
  
  task result;
    input integer err;
    input integer num;
    integer rf;
    begin
      `ifdef SYN
			rf = $fopen({prog_path, "/result_syn.txt"}, "w");
      `else
			rf = $fopen({prog_path, "/result_rtl.txt"}, "w");
      `endif
      $fdisplay(rf, "%d,%d", num - err, num);
      if (err === 0)
      begin
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
      end
      else
      begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  OOPS!!                **      / X,X  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation Failed!!   **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("         Totally has %d errors                     ", err); 
        $display("\n");
      end
    end
  endtask

endmodule