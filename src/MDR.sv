module MDR (
    input logic clk,
    input logic rst,
    input logic [2:0] funct3,
    input logic [31:0] rs1_data,
    input logic [31:0] rs2_data,

    input logic         mdr_start,
    input logic [2:0]   EXE_rob_idx,
    output logic [31:0] mdr_out,
    output logic [2:0]  mdr_rob_idx,
    output logic        mdr_o_valid
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
            s0: ns = (mdr_start);
            s1: ns = (count != 5'd11);
        endcase

        m0 = 33'b0;
        m1 = op1;
        m2 = op1 << 1;
        m3 = (op1 << 1) + op1;
        m4 = op1 << 2;

        unique case (product[3:0])
            4'b0000, 4'b1111: temp2 = m0;
            4'b0001, 4'b0010: temp2 = m1;
            4'b0011, 4'b0100: temp2 = m2;
            4'b0101, 4'b0110: temp2 = m3;
            4'b0111:          temp2 = m4;
            4'b1000:          temp2 = -m4;
            4'b1001, 4'b1010: temp2 = -m3;
            4'b1011, 4'b1100: temp2 = -m2;
            4'b1101, 4'b1110: temp2 = -op1;    
        endcase

        temp        = {product[66:34] + temp2, product[33:0]};
        mdr_o_valid = (cs == s1) && (ns == s0);
    end

    always_ff @(posedge clk) begin
        case (cs)
            s0: begin
                product     <= {33'b0, op2, 1'b0}; 
                count       <= 5'b0;
                mdr_rob_idx <= EXE_rob_idx;
            end
            s1: begin
                product     <= {{3{temp[66]}}, temp[66:3]};
                count       <= count + 5'b1;
                mdr_rob_idx <= mdr_rob_idx;
            end
        endcase
    end

    // MDR operations
    always_comb begin
        case (funct3)
            `MUL:   op1 = {rs1_data[31], rs1_data};
            `MULH:  op1 = {rs1_data[31], rs1_data};
            `MULHU: op1 = {1'b0        , rs1_data};
            `MULHSU:op1 = {rs1_data[31], rs1_data};
            default: op1 = 33'b0;
        endcase

        case (funct3)
            `MUL:   op2 = {rs2_data[31], rs2_data};
            `MULH:  op2 = {rs2_data[31], rs2_data};
            `MULHU: op2 = {1'b0        , rs2_data};
            `MULHSU:op2 = {1'b0        , rs2_data};
            default: op2 = 33'b0;
        endcase

        case (funct3)
            `MUL:    mdr_out = product[32:1];
            `MULH:   mdr_out = product[64:33];
            `MULHSU: mdr_out = product[64:33];
            `MULHU:  mdr_out = product[64:33];
            default: mdr_out = 32'b0;
        endcase
    end
endmodule