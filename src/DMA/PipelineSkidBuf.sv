module PipelineSkidBuf
(
    input  logic          clk,
    input  logic          rstn,
    
    // Input Interface   
    input  logic [31 : 0] i_data,
    input  logic          i_valid,
    output logic          o_ready,
    
    // Output Interface
    output logic [31  : 0] o_data,
    output logic           o_valid,
    input  logic           i_ready
);
typedef enum logic {
    PIPE = 1'b0,
    SKID = 1'b1
} state_t;

logic valid_q;
logic ready_q;
logic valid_d;
logic ready_d;
logic ready;

state_t cs;
state_t ns;
always_ff @(posedge clk) begin
    if(!rstn)begin
        cs <= PIPE;
    end else begin
        cs <= ns;
    end
end
always_comb begin
    unique case (cs)
        PIPE: ns = (i_valid && !ready)? SKID : PIPE; 
        SKID: ns = (i_ready)? PIPE : SKID;
    endcase
end

always_ff @(posedge clk) begin
    if(!rstn)begin
        valid_q <= 1'b0;
        ready_q <= 1'b0;
    end else begin
        valid_q <= valid_d;
        ready_q <= ready_d;
    end
end
always_comb begin
    unique case (cs)
        PIPE: begin
            valid_d = (ready)? i_valid : valid_q;
            ready_d = ready || (ready_q && ~i_valid); // Magic -> AI said.
        end
        SKID: begin
            valid_d = 1'b1;
            ready_d = 1'b1;
        end
    endcase
end

logic [31 : 0] data_q;
logic [31 : 0] sparebuff_q;
logic [31 : 0] data_d;
logic [31 : 0] sparebuff_d;
always_ff @(posedge clk)begin
    if(!rstn)begin
        data_q      <= 'b0;
        sparebuff_q <= 'b0;
    end else begin
        data_q      <= data_d;
        sparebuff_q <= sparebuff_d;
    end
end
always_comb begin
    unique case (cs)
        PIPE:begin
            data_d      = (ready)? i_data : data_q;
            sparebuff_d = (i_valid && !ready)? i_data: sparebuff_q;
        end
        SKID:begin
            data_d      = data_q;
            sparebuff_d = sparebuff_q;
        end
    endcase
end
assign ready   = i_ready || ~valid_q;
assign o_ready = ready_q;
assign o_data  = data_q;
assign o_valid = valid_q;
endmodule
