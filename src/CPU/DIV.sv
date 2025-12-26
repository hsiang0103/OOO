`include "../include/config.svh"

module DIV (
    input  logic        clk,
    input  logic        rst,
    input  logic [2:0]  funct3,           // 100:DIV 101:DIVU 110:REM 111:REMU
    input  logic [31:0] rs1_data,             // rs1 (dividend)
    input  logic [31:0] rs2_data,             // rs2 (divisor)

    input  logic        mispredict,
    input  logic [`ROB_LEN-1:0] flush_mask,

    input   logic           div_i_valid,
    input   logic           div_i_ready,      // Downstream Ready signal (0 = Stall)
    input   logic [$clog2(`ROB_LEN)-1:0]     div_i_rob_idx,
    input   logic [6:0]     div_i_rd,
    output  logic           div_o_valid,
    output  logic [$clog2(`ROB_LEN)-1:0]     div_o_rob_idx,
    output  logic [6:0]     div_o_rd,
    output  logic [31:0]    div_o_data
);

    parameter XLEN = 32;
    parameter STAGE_LIST = 32'h01010101; // Fully pipelined

    // ---------------------------------------------------------
    // 1. Flow Control / Stall Logic
    // ---------------------------------------------------------
    logic stall;
    // 當後端 (div_i_ready) 拉低時，我們產生 stall 訊號停住 Pipeline
    assign stall = ~div_i_ready;

    // ---------------------------------------------------------
    // 2. Pre-processing
    // ---------------------------------------------------------
    logic is_signed;
    logic is_rem;
    logic [31:0] op1_abs;
    logic [31:0] op2_abs;
    logic neg_quo;
    logic neg_rem;
    logic use_special;
    logic [31:0] special_data;

    assign is_signed = ~funct3[0]; 
    assign is_rem    = funct3[1];  

    logic op1_sign, op2_sign;
    assign op1_sign = is_signed & rs1_data[31];
    assign op2_sign = is_signed & rs2_data[31];

    assign op1_abs = op1_sign ? -rs1_data : rs1_data;
    assign op2_abs = op2_sign ? -rs2_data : rs2_data;

    assign neg_quo = op1_sign ^ op2_sign;
    assign neg_rem = op1_sign;

    // Corner cases
    logic is_div_by_zero;
    logic is_overflow;

    assign is_div_by_zero = (rs2_data == 0);
    assign is_overflow    = is_signed && (rs1_data == 32'h80000000) && (rs2_data == 32'hffffffff);

    always_comb begin
        use_special = 0;
        special_data = 0;
        if (is_div_by_zero) begin
            use_special = 1;
            special_data = (is_rem)? rs1_data : 32'hffffffff;
        end 
        if (is_overflow) begin
            use_special = 1;
            special_data = (is_rem)? 32'b0 : 32'h80000000;
        end
    end

    // ---------------------------------------------------------
    // 3. Divfunc Instantiation (Connecting Stall)
    // ---------------------------------------------------------
    logic [31:0] quo_raw, rem_raw;
    logic div_ack;

    // 注意：這裡假設底層 divfunc 已經加入了 input stall 接口
    divfunc #(
        .XLEN(XLEN),
        .STAGE_LIST(STAGE_LIST)
    ) u_divfunc (
        .clk(clk),
        .rst(rst),
        .stall(stall),    // <--- 連接 Stall 訊號
        .a(op1_abs),
        .b(op2_abs),
        .vld(div_i_valid & ~stall), // 如果 stall，雖然內部FF會擋住，但建議也不要送 vld 進去
        .quo(quo_raw),
        .rem(rem_raw),
        .ack(div_ack)
    );

    // ---------------------------------------------------------
    // 4. Metadata Pipeline (Controlled by Stall)
    // ---------------------------------------------------------
    typedef struct packed {
        logic [$clog2(`ROB_LEN)-1:0] rob_idx;
        logic [6:0] rd;
        logic is_rem;
        logic neg_quo;
        logic neg_rem;
        logic use_special;
        logic [31:0] special_data;
        logic valid;
    } metadata_t;

    metadata_t meta_in, meta_out;
    
    assign meta_in.rob_idx      = div_i_rob_idx;
    assign meta_in.rd           = div_i_rd;
    assign meta_in.is_rem       = is_rem;
    assign meta_in.neg_quo      = neg_quo;
    assign meta_in.neg_rem      = neg_rem;
    assign meta_in.use_special  = use_special;
    assign meta_in.special_data = special_data;
    assign meta_in.valid        = div_i_valid & ~stall; // 如果 stall，metadata 也不應該前進

    metadata_t meta_pipe [XLEN:0];
    
    always_comb begin
        meta_pipe[0] = meta_in;
    end

    genvar i;
    generate
        for (i=0; i<XLEN; i=i+1) begin : gen_meta_pipe
            if (STAGE_LIST[XLEN-i-1]) begin : gen_ff
                always_ff @(posedge clk) begin
                    if (rst) begin
                        meta_pipe[i+1] <= '0;
                    end 
                    else if (mispredict && flush_mask[meta_pipe[i].rob_idx]) begin
                        meta_pipe[i+1] <= '0; // Flush
                    end
                    else if (~stall) begin 
                        meta_pipe[i+1] <= meta_pipe[i];
                    end
                end
            end 
            else begin : gen_comb
                always_comb begin
                    meta_pipe[i+1] = meta_pipe[i];
                end
            end
        end
    endgenerate

    assign meta_out = meta_pipe[XLEN];

    // ---------------------------------------------------------
    // 5. Post-processing
    // ---------------------------------------------------------
    logic [31:0] quo_final;
    logic [31:0] rem_final;
    logic [31:0] result_calc;

    assign quo_final        = meta_out.neg_quo ? -quo_raw : quo_raw;
    assign rem_final        = meta_out.neg_rem ? -rem_raw : rem_raw;
    
    assign result_calc      = meta_out.is_rem ? rem_final : quo_final;

    assign div_o_data       = meta_out.use_special ? meta_out.special_data : result_calc;
    assign div_o_rob_idx    = meta_out.rob_idx;
    assign div_o_rd         = meta_out.rd;
    
    // 輸出有效訊號：必須 divfunc 完成 (ack) 且 我們沒有被 stall 住 (或者是被 stall 住時保持住舊的 valid)
    // 這裡通常直接接 ack 即可，因為如果 stall，ack 也會由 divfunc 內部的 FF 保持住狀態。
    assign div_o_valid      = div_ack & ~stall & meta_out.valid; 

endmodule