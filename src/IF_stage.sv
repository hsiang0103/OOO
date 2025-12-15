module IF_stage(
        input   logic           clk,
        input   logic           rst,
        // BPU (Branch Prediction Unit)
        input   logic [31:0]    next_pc,       // BPU 預測的下一個 PC
        input   logic           next_jump,     // BPU 預測是否跳轉
        // IM (Instruction Memory Wrapper)
        input   logic [31:0]    fetch_data,
        input   logic           fetch_data_valid,
        input   logic           fetch_req_ready,     
        output  logic [31:0]    fetch_addr,
        output  logic           fetch_req_valid,
        // EXE stage
        input   logic [31:0]    jb_pc,         // 正確的跳轉目標 (Jump/Branch PC)
        input   logic           mispredict,    // 預測錯誤信號
        // DC stage (Decode Stage)
        input   logic           DC_ready,      // 下一級是否準備好接收
        output  logic [31:0]    IF_out_pc,
        output  logic [31:0]    IF_out_inst,
        output  logic           IF_out_jump,
        output  logic           IF_valid
    );

    //================================================================
    // 1. State Machine Definition
    //================================================================
    typedef enum logic {
        SEND_REQ,   // 發送 Fetch Request (fetch_req_valid = 1)
        WAIT_DATA   // 等待 Memory 回傳 Data (fetch_req_valid = 0)
    } state_t;

    state_t cs, ns;
    logic fetch_handshake;
    assign fetch_handshake = fetch_req_valid && fetch_req_ready;

    //================================================================
    // 2. PC Control Logic
    //================================================================
    logic [31:0] pc;
    logic        jump;
    
    // fetch_addr 始終是對應當前 pc
    assign fetch_addr = pc;

    always_ff @(posedge clk) begin
        if (rst) begin
            pc      <= `RESET_ADDR; // 假設 Reset Addr 為 0，可改為 `RESET_ADDR
            jump    <= 1'b0;
        end
        else begin
            if (mispredict || fetch_data_valid) begin
                pc      <= next_pc;
                jump    <= next_jump;
            end
        end
    end

    //================================================================
    // 3. FSM Logic (Request Handshake Control)
    //================================================================
    
    // State Register
    always_ff @(posedge clk) begin
        if (rst) begin
            cs <= SEND_REQ; // Reset 後直接開始 Fetch
        end
        else begin
            cs <= ns;
        end
    end

    // Next State Logic
    always_comb begin
        if(mispredict) begin
            ns = SEND_REQ; // Mispredict 時立即回到發送請求狀態
        end
        else begin
            unique case (cs)
                SEND_REQ:   ns = (fetch_handshake) ? WAIT_DATA : SEND_REQ; 
                WAIT_DATA:  ns = (fetch_data_valid) ? SEND_REQ : WAIT_DATA; 
            endcase
        end
    end

    //================================================================
    // 4. FIFO Implementation
    //================================================================
    // 假設 FIFO 深度為 4 (可根據需求調整)
    localparam FIFO_DEPTH = 4;
    localparam DATA_WIDTH = 32 + 32 + 1; // PC(32) + Inst(32) + Jump(1)

    logic [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    logic [$clog2(FIFO_DEPTH):0] wr_ptr, rd_ptr; // 多一位用來判斷 full/empty
    logic [DATA_WIDTH-1:0] fifo_in;
    logic [DATA_WIDTH-1:0] fifo_out;
    
    logic fifo_full, fifo_empty;
    logic fifo_write, fifo_read;

    // FIFO Status
    assign fifo_empty = (wr_ptr == rd_ptr);
    assign fifo_full  = (wr_ptr[$clog2(FIFO_DEPTH)] != rd_ptr[$clog2(FIFO_DEPTH)]) && 
                        (wr_ptr[$clog2(FIFO_DEPTH)-1:0] == rd_ptr[$clog2(FIFO_DEPTH)-1:0]);

    // FIFO Control Signals
    // Write: 當 Memory 資料回來，且沒有 mispredict (若 mispredict 則丟棄回來的資料)
    assign fifo_write = fetch_data_valid && !mispredict && !fifo_full;
    
    // Read: 當下一級 (DC) Ready 且 FIFO 不為空
    assign fifo_read  = DC_ready && !fifo_empty;

    // Prepare Data to write: PC, Instruction, and BPU prediction info
    // 注意：這裡存的是當前 Fetch 回來的 Instruction 對應的 PC 和 prediction
    assign fifo_in = {pc, fetch_data, next_jump}; 

    // FIFO Pointers & Memory Update
    always_ff @(posedge clk) begin
        if (rst || mispredict) begin
            // Reset 或 Mispredict 時 Flush FIFO
            wr_ptr <= 0;
            rd_ptr <= 0;
        end
        else begin
            // Write Operation
            if (fifo_write) begin
                fifo_mem[wr_ptr[$clog2(FIFO_DEPTH)-1:0]] <= fifo_in;
                wr_ptr <= wr_ptr + 1;
            end
            
            // Read Operation
            if (fifo_read) begin
                rd_ptr <= rd_ptr + 1;
            end
        end
    end

    // FIFO Output Logic (First-Word Fall-Through 或是搭配 Read 信號)
    // 這裡使用 Combinational 輸出當前 Read Pointer 指向的資料
    assign fifo_out = fifo_mem[rd_ptr[$clog2(FIFO_DEPTH)-1:0]];

    //================================================================
    // 5. Output Assignment to Next Stage (DC)
    //================================================================
    
    // 將 FIFO 出來的資料解包給 Output
    assign {IF_out_pc, IF_out_inst, IF_out_jump} = fifo_out;
    
    // 告訴下一級現在 IF stage 有有效資料 (FIFO 不空)
    assign IF_valid = !fifo_empty;
    assign fetch_req_valid = (cs == SEND_REQ) && !mispredict && !fifo_full;

endmodule