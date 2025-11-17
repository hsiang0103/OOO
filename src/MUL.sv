module MUL (
    input   logic           clk,
    input   logic           rst,
    input   logic [2:0]     funct3,
    input   logic [31:0]    rs1_data,
    input   logic [31:0]    rs2_data,

    input   logic           mul_i_valid,
    input   logic [2:0]     mul_i_rob_idx,
    input   logic [6:0]     mul_i_rd,
    output  logic           mul_o_valid,
    output  logic [2:0]     mul_o_rob_idx,
    output  logic [6:0]     mul_o_rd,
    output  logic [31:0]    mul_o_data,
    output  logic           mul_idle
);
    
    logic [32:0] op1, op2;
    logic [32:0] temp2;
    logic [66:0] temp;
    logic [66:0] product;
    logic [4:0] count;
    logic cs, ns;
    parameter s0 = 1'b0; // IDLE
    parameter s1 = 1'b1; // CALC

    logic [32:0] m0, m1, m2, m3, m4;
    logic [32:0] op1_r;
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
            s1: ns = (count != 5'd11);
        endcase
    
        unique case (cs)
            s0: begin
                m0 = 33'b0;
                m1 = op1;
                m2 = op1 << 1;
                m3 = (op1 << 1) + op1;
                m4 = op1 << 2;
            end
            s1: begin
                m0 = 33'b0;
                m1 = op1_r;
                m2 = op1_r << 1;
                m3 = (op1_r << 1) + op1_r;
                m4 = op1_r << 2;
            end
        endcase

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

        temp        = {product[66:34] + temp2, product[33:0]};
        mul_o_valid = (cs == s1) && (ns == s0);
    end

    always_ff @(posedge clk) begin
        case (cs)
            s0: begin
                product         <= {33'b0, op2, 1'b0}; 
                count           <= 5'b0;
                mul_o_rob_idx   <= mul_i_rob_idx;
                mul_o_rd        <= mul_i_rd;
                op1_r           <= op1;
                f3_r            <= funct3;
            end
            s1: begin
                product         <= {{3{temp[66]}}, temp[66:3]};
                count           <= count + 5'b1;
                mul_o_rob_idx   <= mul_o_rob_idx;
                mul_o_rd        <= mul_o_rd;
                op1_r           <= op1_r;
                f3_r            <= f3_r;
            end
        endcase
    end

    // mul operations
    always_comb begin
        case (funct3)
            `MUL:       op1 = {rs1_data[31], rs1_data};
            `MULH:      op1 = {rs1_data[31], rs1_data};
            `MULHU:     op1 = {1'b0        , rs1_data};
            `MULHSU:    op1 = {rs1_data[31], rs1_data};
            default:    op1 = 33'b0;
        endcase

        case (funct3)
            `MUL:       op2 = {rs2_data[31], rs2_data};
            `MULH:      op2 = {rs2_data[31], rs2_data};
            `MULHU:     op2 = {1'b0        , rs2_data};
            `MULHSU:    op2 = {1'b0        , rs2_data};
            default:    op2 = 33'b0;
        endcase

        case (f3_r)
            `MUL:    mul_o_data = product[32:1];
            `MULH:   mul_o_data = product[64:33];
            `MULHSU: mul_o_data = product[64:33];
            `MULHU:  mul_o_data = product[64:33];
            default: mul_o_data = 32'b0;
        endcase

        mul_idle = (cs == s0);
    end
endmodule