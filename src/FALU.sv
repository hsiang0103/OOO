module FALU (
    input   logic           clk,
    input   logic           rst,
    input   logic [4:0]     funct5,
    input   logic [31:0]    operand1,
    input   logic [31:0]    operand2,

    input   logic           falu_i_valid,
    input   logic [2:0]     falu_i_rob_idx,
    input   logic [6:0]     falu_i_rd,
    output  logic           falu_o_valid,
    output  logic [2:0]     falu_o_rob_idx,
    output  logic [6:0]     falu_o_rd,
    output  logic [31:0]    falu_o_data
);

    logic [31:0] result;
    logic G, R, S, rounding;
    logic [ 7:0] leading_zeros;
    
    logic [22:0] mant_out;
    logic [27:0] mant_a_align, mant_b_align;
    logic [27:0] mant_res, mant_sub, mant_add;
    logic [27:0] mant_res_2nd_stage;
    logic [27:0] mant_norm;

    logic [ 7:0] exp_a , exp_b;
    logic [ 7:0] exp_diff, exp_res;
    logic [ 7:0] exp_norm;
    logic [ 7:0] exp_res_2nd_stage;
    
    logic        sign_a, sign_b;
    logic        sign_res;
    logic        sign_res_2nd_stage;
    
    always_comb begin
        sign_a = operand1[31];
        sign_b = (funct5 == `FSUBS) ^ operand2[31]; 
        exp_a  = operand1[30:23];
        exp_b  = operand2[30:23];
    end

    always_comb begin
        if(exp_a > exp_b) begin
            exp_res      = exp_a; 
            exp_diff     = exp_a - exp_b;
            mant_a_align = {2'b01, operand1[22:0], 3'd0};
            mant_b_align = {2'b01, operand2[22:0], 3'd0} >> exp_diff;
        end else begin
            exp_res      = exp_b; 
            exp_diff     = exp_b - exp_a;
            mant_a_align = {2'b01, operand1[22:0], 3'd0} >> exp_diff;
            mant_b_align = {2'b01, operand2[22:0], 3'd0};
        end
    end
    
    always_comb begin
        mant_add = mant_a_align + mant_b_align;
        mant_sub = mant_a_align - mant_b_align;

        if(sign_a == sign_b) begin
            mant_res = mant_add;
            sign_res = sign_a;
        end else begin
            sign_res = mant_sub[27]? sign_b    : sign_a  ;
            mant_res = mant_sub[27]? -mant_sub : mant_sub;
        end
    end

    always_ff @(posedge clk) begin
        sign_res_2nd_stage  <= sign_res;
        mant_res_2nd_stage  <= mant_res;
        exp_res_2nd_stage   <= exp_res;
        falu_o_rob_idx      <= falu_i_rob_idx;
        falu_o_valid        <= falu_i_valid;
        falu_o_rd           <= falu_i_rd;
    end

    always_comb begin
        priority case (1'b1) // for synthesis
            mant_res_2nd_stage[26]: leading_zeros = 8'd0;
            mant_res_2nd_stage[25]: leading_zeros = 8'd1;
            mant_res_2nd_stage[24]: leading_zeros = 8'd2;
            mant_res_2nd_stage[23]: leading_zeros = 8'd3;
            mant_res_2nd_stage[22]: leading_zeros = 8'd4;
            mant_res_2nd_stage[21]: leading_zeros = 8'd5;
            mant_res_2nd_stage[20]: leading_zeros = 8'd6;
            mant_res_2nd_stage[19]: leading_zeros = 8'd7;
            mant_res_2nd_stage[18]: leading_zeros = 8'd8;
            mant_res_2nd_stage[17]: leading_zeros = 8'd9;
            mant_res_2nd_stage[16]: leading_zeros = 8'd10;
            mant_res_2nd_stage[15]: leading_zeros = 8'd11;
            mant_res_2nd_stage[14]: leading_zeros = 8'd12;
            mant_res_2nd_stage[13]: leading_zeros = 8'd13;
            mant_res_2nd_stage[12]: leading_zeros = 8'd14;
            mant_res_2nd_stage[11]: leading_zeros = 8'd15;
            mant_res_2nd_stage[10]: leading_zeros = 8'd16;
            mant_res_2nd_stage[ 9]: leading_zeros = 8'd17;
            mant_res_2nd_stage[ 8]: leading_zeros = 8'd18;
            mant_res_2nd_stage[ 7]: leading_zeros = 8'd19;
            mant_res_2nd_stage[ 6]: leading_zeros = 8'd20;
            mant_res_2nd_stage[ 5]: leading_zeros = 8'd21;
            mant_res_2nd_stage[ 4]: leading_zeros = 8'd22;
            mant_res_2nd_stage[ 3]: leading_zeros = 8'd23;
            mant_res_2nd_stage[ 2]: leading_zeros = 8'd24;
            mant_res_2nd_stage[ 1]: leading_zeros = 8'd25;
            mant_res_2nd_stage[ 0]: leading_zeros = 8'd26;
            default:                leading_zeros = 8'd27;
        endcase

        if(mant_res_2nd_stage[27]) begin
            mant_norm = {1'd0, mant_res_2nd_stage[27:1]};
            exp_norm  = exp_res_2nd_stage + 8'd1;
        end 
        else begin
            mant_norm = mant_res_2nd_stage << leading_zeros;
            exp_norm  = exp_res_2nd_stage - leading_zeros;
        end

        G           = mant_norm[2];
        R           = mant_norm[1];
        S           = mant_norm[0];
        rounding    = G & (R | S);
        mant_out    = (rounding)? (mant_norm[25:3] + 23'd1) : (mant_norm[25:3]);
        falu_o_data = {sign_res_2nd_stage, exp_norm, mant_out};
    end
endmodule
