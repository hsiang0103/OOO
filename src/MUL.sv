module MUL (
    input   logic           clk,
    input   logic           rst,
    input   logic [2:0]     funct3,
    input   logic [31:0]    rs1_data,
    input   logic [31:0]    rs2_data,

    input   logic           mispredict,
    input  logic [`ROB_LEN-1:0] flush_mask,

    input   logic           mul_i_valid,
    input   logic [$clog2(`ROB_LEN)-1:0]     mul_i_rob_idx,
    input   logic [6:0]     mul_i_rd,
    output  logic           mul_o_valid,
    output  logic [$clog2(`ROB_LEN)-1:0]     mul_o_rob_idx,
    output  logic [6:0]     mul_o_rd,
    output  logic [31:0]    mul_o_data,
    output  logic           mul_o_ready
);
    
    // --------------------------------------------------------
    // 修改 1: 增加位寬防止溢位
    // --------------------------------------------------------
    // Radix-8 最大會用到 4倍 (Shift 2)。
    // 32-bit 輸入擴展符號位到 33-bit 後，乘以 4 需要 35-bits。
    // 為了安全與對齊，我們使用 36-bits。
    logic [35:0] op1;       // 原本 [32:0] -> 改為 [35:0]
    logic [32:0] op2;       // Multiplier 只要維持 33-bit 即可
    
    logic [35:0] temp2;     // 加法器的第二操作數，需配合 op1 寬度
    
    // Product 暫存器總寬度 = Accumulator(36) + Multiplier(33) + Phantom(1) = 70 bits
    logic [69:0] temp;      // 原本 [66:0] -> 改為 [69:0]
    logic [69:0] product;   // 原本 [66:0] -> 改為 [69:0]
    logic [69:0] product_shifted; // 新增：用於修正輸出時序的訊號

    logic [4:0] count;
    logic cs, ns;
    parameter s0 = 1'b0; // IDLE
    parameter s1 = 1'b1; // CALC

    // Pre-computed multiples
    logic [35:0] m0, m1, m2, m3, m4; // 寬度改為 36 bits
    logic [35:0] op1_r;              // Latch 也要加寬
    logic [2:0] f3_r;

    always_ff @(posedge clk) begin
        if (rst) begin
            cs <= s0;
        end
        else begin
            cs <= ns;
        end
    end

    always_comb begin
        unique case (cs)
            s0: ns = (mul_i_valid);
            s1: begin
                if(mispredict && flush_mask[mul_o_rob_idx]) begin
                    ns = s0;
                end
                else begin
                    ns = (count != 5'd10);
                end
            end
        endcase
    
        // 計算倍數 (注意: op1 已經是 36-bit)
        unique case (cs)
            s0: begin
                m0 = 36'b0;
                m1 = op1;
                m2 = op1 << 1;
                m3 = (op1 << 1) + op1;
                m4 = op1 << 2; // 因為寬度夠 (36b)，這裡不會切掉符號位
            end
            s1: begin
                m0 = 36'b0;
                m1 = op1_r;
                m2 = op1_r << 1;
                m3 = (op1_r << 1) + op1_r;
                m4 = op1_r << 2;
            end
        endcase

        // Booth Selector
        unique case (product[3:0])
            4'b0000, 4'b1111: temp2 = m0;
            4'b0001, 4'b0010: temp2 = m1;
            4'b0011, 4'b0100: temp2 = m2;
            4'b0101, 4'b0110: temp2 = m3;
            4'b0111:          temp2 = m4;
            4'b1000:          temp2 = -m4;
            4'b1001, 4'b1010: temp2 = -m3;
            4'b1011, 4'b1100: temp2 = -m2;
            4'b1101, 4'b1110: temp2 = -m1;    
        endcase

        // ALU 加法 (High part: [69:34])
        temp = {product[69:34] + temp2, product[33:0]};
        
        // 預先計算移位後的結果 (Arithmetic Shift Right by 3)
        product_shifted = {{3{temp[69]}}, temp[69:3]};

        // Valid 訊號
        mul_o_valid = (cs == s1) && count == 5'd10;
    end

    always_ff @(posedge clk) begin
        case (cs)
            s0: begin
                // 初始化: Accumulator清零 (36bits), 載入Multiplier (33bits), Phantom bit (1bit)
                product         <= {36'b0, op2, 1'b0}; 
                count           <= 5'b0;
                mul_o_rob_idx   <= mul_i_rob_idx;
                mul_o_rd        <= mul_i_rd;
                op1_r           <= op1;
                f3_r            <= funct3;
            end
            s1: begin
                // 每個 cycle 載入移位後的結果
                product         <= product_shifted;
                count           <= count + 5'b1;
                mul_o_rob_idx   <= mul_o_rob_idx;
                mul_o_rd        <= mul_o_rd;
                op1_r           <= op1_r;
                f3_r            <= f3_r;
            end
        endcase
    end

    // --------------------------------------------------------
    // 修改 2: 輸入與輸出的位寬/索引調整
    // --------------------------------------------------------
    always_comb begin
        // 輸入符號擴展至 36 bits
        case (funct3)
            `MUL:    op1 = {{4{rs1_data[31]}}, rs1_data};
            `MULH:   op1 = {{4{rs1_data[31]}}, rs1_data};
            `MULHU:  op1 = {4'b0             , rs1_data}; // Unsigned
            `MULHSU: op1 = {{4{rs1_data[31]}}, rs1_data};
            default: op1 = 36'b0;
        endcase

        // Op2 只需要 33 bits
        case (funct3)
            `MUL:    op2 = {rs2_data[31], rs2_data};
            `MULH:   op2 = {rs2_data[31], rs2_data};
            `MULHU:  op2 = {1'b0        , rs2_data};
            `MULHSU: op2 = {1'b0        , rs2_data}; // Unsigned
            default: op2 = 33'b0;
        endcase

        // 輸出選擇: 使用 product_shifted 而非 product
        // 這是因為當 mul_o_valid 拉高時，最新的運算結果在 product_shifted 線路上，
        // 而 product 暫存器還存著上一次的舊值。
        case (f3_r)
            `MUL:    mul_o_data = product_shifted[32:1];  // Lower 32
            `MULH:   mul_o_data = product_shifted[64:33]; // Upper 32
            `MULHSU: mul_o_data = product_shifted[64:33];
            `MULHU:  mul_o_data = product_shifted[64:33];
            default: mul_o_data = 32'b0;
        endcase

        mul_o_ready = (cs == s0);
    end
endmodule