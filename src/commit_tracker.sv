module commit_tracker(
        input logic        clk,
        input logic        rst,
        input logic        commit_valid,
        input logic [31:0] commit_pc,
        input logic [31:0] commit_inst,
        input logic [4:0]  commit_Ard,
        input logic [31:0] commit_data
    );

    integer fd;

    initial begin
        fd = $fopen("commit.log", "w");
        if (fd == 0) begin
            $display("Error: Could not open commit.log");
        end
    end

    always_ff @(posedge clk) begin
        if (!rst && commit_valid) begin
            $fwrite(fd, "PC: %08x, Inst: %08x, Ard: %02d, Data: %08x\n",
                    commit_pc, commit_inst, commit_Ard, commit_data);
        end
    end
    endmodule
