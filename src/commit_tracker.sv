module commit_tracker(
    input logic        clk,
    input logic        rst,
    input logic        commit_valid,
    input logic [31:0] commit_pc,
    input logic [31:0] commit_inst,
    input logic [5:0]  commit_Ard,  // 目的地暫存器 Index (0-31)
    input logic [31:0] commit_data, // 寫回的數據
    input logic        st_commit,   // 是否為 Store 指令
    input logic [31:0] st_addr,     // Store 地址
    input logic [31:0] st_data      // Store 數據
);

    integer f;

    // 模擬開始時開啟檔案
    initial begin
        f = $fopen("rtl_commit.log", "w");
    end

    // 模擬結束時關閉檔案 (可選，但在某些 Simulator 很重要)
    final begin
        $fclose(f);
    end

    always @(posedge clk) begin
        // 只有在 Reset 解除且 Commit 有效時才記錄
        if (commit_valid && !rst) begin
            
            // 過濾掉 BootROM (Spike 預設 0x1000-0x1FFF，你的 Code 從 0x2000 開始)
            if (commit_pc >= 32'h2000) begin
                
                // 優先權 1: Store 指令 (對應 mem 格式)
                // 格式: PC (Inst) mem Addr Data
                if (st_commit) begin
                    $fwrite(f, "0x%08h (0x%08h) mem 0x%08h 0x%08h\n", 
                            commit_pc, commit_inst, st_addr, st_data);
                end
                
                // 優先權 2: 一般暫存器寫入 (對應 x... 格式)
                // 必須過濾掉寫入 x0 的情況 (例如 nop, branch, jump)
                // 格式: PC (Inst) xIdx Data
                else if (commit_Ard != 5'd0) begin
                    $fwrite(f, "0x%08h (0x%08h) x%-2d 0x%08h\n", 
                            commit_pc, commit_inst, commit_Ard, commit_data);
                end
                
                // 注意: 如果是指標跳轉或 NOP (寫入 x0 且非 Store)，
                // 這裡會自動跳過不印，與之前的 Python 邏輯保持一致。
            end
        end
    end

endmodule