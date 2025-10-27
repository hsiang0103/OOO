module RegFile (
        input logic clk,
        input logic rst,

        // Decode Read
        input logic [6:0] rs1_index,
        input logic [6:0] rs2_index,
        output logic [31:0] rs1_data_out,
        output logic [31:0] rs2_data_out,

        // Write back
        input logic wb_en,
        input logic [31:0] wb_data,
        input logic [6:0] rd_index
    );

    logic [31:0] registers [0:79];

    // Decode Read
    assign rs1_data_out = rs1_index != 0? registers[rs1_index] : 32'b0; // x0 is always 0
    assign rs2_data_out = rs2_index != 0? registers[rs2_index] : 32'b0; // x0 is always 0

    // Write back
    always_ff @(posedge clk) begin
        if(rst) begin
            for (int i = 0; i < 80; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end
        else begin
            registers[rd_index] <= wb_en? wb_data : registers[rd_index];
        end
    end
endmodule
