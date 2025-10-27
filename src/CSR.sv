module CSR(
    input logic clk,
    input logic rst,
    input logic [31:0] EXE_in_result,
    input logic [11:0] imm,
    input logic waiting,
    output logic [31:0] CSR_out
);  

    logic [63:0] cycle;
    logic [63:0] instret;

    always_ff @(posedge clk) begin
        if (rst) begin
            cycle   <= 64'b0;
            instret <= 64'b0;
        end
        else begin
            cycle   <= cycle + 1;
            instret <= instret + (EXE_in_result != 32'h00000013 && !waiting);
        end
    end

    always_comb begin
        case (imm)
            12'hC00: CSR_out = cycle[31:0];
            12'hC80: CSR_out = cycle[63:32];
            12'hC02: CSR_out = instret[31:0];
            12'hC82: CSR_out = instret[63:32];
            default: CSR_out = 32'b0;
        endcase
    end
endmodule