module IF_stage(
        input logic         clk,
        input logic         rst,

        // From IM
        input logic [31:0]  IM_r_data,

        // From IS stage
        input logic         mispredict,

        // From EXE stage
        input logic [15:0]  jb_pc,

        // To IM
        output logic [15:0] IM_r_addr,
        output logic        IM_ready,

        // To DC stage
        output logic [15:0] IF_out_pc,
        output logic [31:0] IF_out_inst,

        // Handshake signals
        // IF --- DC
        output logic        IF_valid,
        input  logic        DC_ready
    );

    logic [15:0] next_pc;
    logic [15:0] IF_DC_pc;

    assign IM_r_addr = mispredict ? jb_pc : next_pc;

    // IM_r_addr register
    always_ff @(posedge clk) begin
        if (rst) begin
            next_pc <= 16'b0;
        end
        else begin
            if(mispredict) begin
                next_pc <= jb_pc + 16'd4;
            end
            else begin
                if(DC_ready) begin
                    next_pc <= next_pc + 16'd4;
                end
                else begin
                    next_pc <= next_pc;
                end
            end
        end
    end

    // IF_DC register
    always_ff @(posedge clk) begin
        if (rst) begin
            IF_DC_pc <= 16'b0;
        end
        else begin
            IF_DC_pc <= IM_r_addr;
        end
    end

    // skid buffer for IF out
    logic [31:0] IM_r_data_buf;
    logic [15:0] IF_out_pc_buf;
    logic        bypass;

    always_ff @(posedge clk) begin
        if (rst) begin
            IM_r_data_buf   <= 32'b0;
            IF_out_pc_buf   <= 16'b0;
            bypass          <= 1'b1;
        end 
        else begin
            if(mispredict) begin
                IM_r_data_buf   <= 32'b0;
                IF_out_pc_buf   <= 16'b0;
                bypass          <= 1'b1;
            end
            else if (bypass) begin
                if (!DC_ready) begin
                    IM_r_data_buf   <= IM_r_data;
                    IF_out_pc_buf   <= IF_DC_pc;
                    bypass          <= 1'b0;
                end
            end
            else begin
                IM_r_data_buf   <= IM_r_data_buf;
                IF_out_pc_buf   <= IF_out_pc_buf;
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
        if(mispredict) begin
            IF_out_inst = 32'h0;
            IF_out_pc   = 16'h0;
            IM_ready    = 1'b1;
            IF_valid    = 1'b0;
        end
        else begin
            IF_out_inst = bypass ? IM_r_data : IM_r_data_buf;
            IF_out_pc   = bypass ? IF_DC_pc : IF_out_pc_buf;
            IM_ready    = bypass;
            IF_valid    = temp;
        end
    end
endmodule
