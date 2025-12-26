`include "../include/config.svh"
`include "../include/define.svh"


module commit_tracker(
    input logic        clk,
    input logic        rst,
    input logic        commit_valid,
    input logic [31:0] commit_pc,
    input logic [31:0] commit_inst,
    input logic [5:0]  commit_Ard,
    input logic [31:0] commit_data,
    input logic        st_commit,
    input logic [31:0] st_addr,
    input logic [31:0] st_data
);

    integer f;
    
    // --- 新增 Cycle 計數器 ---
    logic [63:0] cycle_count;

    // 用來暫存移位後和遮罩後的資料
    logic [31:0] shifted_st_data;
    logic [31:0] final_st_data;
    logic [1:0]  byte_offset;

    initial begin
        f = $fopen("rtl_commit.log", "w");
    end

    final begin
        $fclose(f);
    end

    // --- Cycle Counter 邏輯 ---
    always_ff @(posedge clk) begin
        if (rst) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
        end
    end

    always_ff @(posedge clk) begin
        if (commit_valid && !rst) begin
            
            if (commit_pc >= 32'h2000) begin
                
                // --- 優先權 1: Store 指令 ---
                if (st_commit) begin
                    // 1. 計算 Byte Offset (地址的最後兩位)
                    byte_offset = st_addr[1:0];

                    // 2. 根據 Offset 將資料右移，讓有效資料回到 LSB
                    shifted_st_data = st_data >> (byte_offset * 8);

                    // 3. 根據 funct3 進行遮罩 (Masking) 並寫入 Log
                    case (commit_inst[14:12])
                        3'b000: begin // SB
                            $fwrite(f, "0x%08h (0x%08h) mem 0x%08h 0x%02h %0d\n", 
                            commit_pc, commit_inst, st_addr, shifted_st_data, cycle_count);
                        end
                        3'b001: begin // SH
                            $fwrite(f, "0x%08h (0x%08h) mem 0x%08h 0x%04h %0d\n", 
                            commit_pc, commit_inst, st_addr, shifted_st_data, cycle_count);
                        end
                        default: begin // SW
                            $fwrite(f, "0x%08h (0x%08h) mem 0x%08h 0x%08h %0d\n", 
                            commit_pc, commit_inst, st_addr, shifted_st_data, cycle_count);
                        end
                    endcase
                end
                
                // --- 優先權 2: 一般暫存器寫入 ---
                else if (commit_Ard != 6'd0 && commit_inst[6:2] != 5'b11000) begin
                    $fwrite(f, "0x%08h (0x%08h) x%-2d 0x%08h %0d\n", 
                            commit_pc, commit_inst, commit_Ard, commit_data, cycle_count);
                end
            end
        end
    end

endmodule