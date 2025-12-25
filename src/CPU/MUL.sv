module MUL (
    input   logic           clk,
    input   logic           rst,
    input   logic [2:0]     funct3,
    input   logic [31:0]    rs1_data,
    input   logic [31:0]    rs2_data,

    input   logic           mispredict,
    input   logic [`ROB_LEN-1:0] flush_mask,

    input   logic           mul_i_valid,
    input   logic [$clog2(`ROB_LEN)-1:0]     mul_i_rob_idx,
    input   logic [6:0]     mul_i_rd,
    output  logic           mul_o_valid,
    output  logic [$clog2(`ROB_LEN)-1:0]     mul_o_rob_idx,
    output  logic [6:0]     mul_o_rd,
    output  logic [31:0]    mul_o_data,
    output  logic           mul_o_ready
);

    logic signed [32:0] op1;       
    logic signed [32:0] op2;
    logic signed [65:0] product;
    always_comb begin
        case (funct3)
            `MUL:    op1 = {{rs1_data[31]}, rs1_data};
            `MULH:   op1 = {{rs1_data[31]}, rs1_data};
            `MULHU:  op1 = {1'b0          , rs1_data};
            `MULHSU: op1 = {{rs1_data[31]}, rs1_data};
            default: op1 = 33'b0;
        endcase

        case (funct3)
            `MUL:    op2 = {rs2_data[31], rs2_data};
            `MULH:   op2 = {rs2_data[31], rs2_data};
            `MULHU:  op2 = {1'b0        , rs2_data};
            `MULHSU: op2 = {1'b0        , rs2_data}; // Unsigned
            default: op2 = 33'b0;
        endcase

        product = op1 * op2;

        case (funct3)
            `MUL:    mul_o_data = product[31:0];  // Lower 32
            `MULH:   mul_o_data = product[63:32]; // Upper 32
            `MULHSU: mul_o_data = product[63:32];
            `MULHU:  mul_o_data = product[63:32];
            default: mul_o_data = 32'b0;
        endcase

        mul_o_ready     = 1'b1;
        mul_o_valid     = mul_i_valid;
        mul_o_rob_idx   = mul_i_rob_idx;
        mul_o_rd        = mul_i_rd;
    end
endmodule