module IF_stage(
        input   logic           clk,
        input   logic           rst,
        // BPU
        input   logic [31:0]    next_pc,
        input   logic           next_jump,
        // From IM
        input   logic [31:0]    IM_r_data,
        // From IS stage
        input   logic           mispredict,
        input   logic           stall,
        // From EXE stage
        input   logic [31:0]    jb_pc,
        // To IM
        output  logic [31:0]    IM_r_addr,
        output  logic           IM_ready,
        // To DC stage
        output  logic [31:0]    IF_out_pc,
        output  logic [31:0]    IF_out_inst,
        output  logic           IF_out_jump,
        // Handshake signals
        // IF --- DC
        output  logic           IF_valid,
        input   logic           DC_ready
    );

    logic [31:0] pc;
    logic [31:0] IF_DC_pc;
    logic        IF_DC_jump;

    assign IM_r_addr = mispredict ? jb_pc : pc;

    // PC register
    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 32'h2000;
        end
        else begin
            pc <= next_pc;
        end
    end

    // IF_DC register
    always_ff @(posedge clk) begin
        if (rst) begin
            IF_DC_pc    <= 32'b0;
            IF_DC_jump  <= 1'b0;
        end
        else begin
            IF_DC_pc    <= IM_r_addr;
            IF_DC_jump  <= next_jump;
        end
    end

    // skid buffer for IF out
    logic [31:0] IM_r_data_buf;
    logic [31:0] IF_out_pc_buf;
    logic        IF_out_jump_buf;
    logic        bypass;

    always_ff @(posedge clk) begin
        if (rst) begin
            IM_r_data_buf   <= 32'b0;
            IF_out_pc_buf   <= 32'b0;
            IF_out_jump_buf <= 1'b0;
            bypass          <= 1'b1;
        end
        else begin
            if(mispredict) begin
                IM_r_data_buf   <= 32'b0;
                IF_out_pc_buf   <= 32'b0;
                IF_out_jump_buf <= 1'b0;
                bypass          <= 1'b1;
            end
            else if (bypass) begin
                if (!DC_ready) begin
                    IM_r_data_buf   <= IM_r_data;
                    IF_out_pc_buf   <= IF_DC_pc;
                    IF_out_jump_buf <= IF_DC_jump;
                    bypass          <= 1'b0;
                end
            end
            else begin
                IM_r_data_buf   <= IM_r_data_buf;
                IF_out_pc_buf   <= IF_out_pc_buf;
                IF_out_jump_buf <= IF_out_jump_buf;
                bypass          <= DC_ready;
            end
        end
    end

    logic temp;
    always_ff @(posedge clk) begin
        if (rst) begin
            temp <= 1'b0;
        end
        else begin
            temp <= 1'b1;
        end
    end

    // Main output
    always_comb begin
        IF_out_inst = bypass ? IM_r_data  : IM_r_data_buf;
        IF_out_pc   = bypass ? IF_DC_pc   : IF_out_pc_buf;
        IF_out_jump = bypass ? IF_DC_jump : IF_out_jump_buf;
        IM_ready    = bypass;
        IF_valid    = temp;
    end
endmodule
