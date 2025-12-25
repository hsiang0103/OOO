module AsyncFIFO2 #(
    parameter DATA_WIDTH = 1
)
(
    input                       clk_w,
    input                       rstn_w,
    input                       push_w, // valid_i
    output                      full_w, // !ready_o
    input   [DATA_WIDTH - 1:0]  data_in,
    
    input                       clk_r,
    input                       rstn_r,
    input                       pop_r,  // ready_i
    output                      empty_r,// !valid_o
    output  [DATA_WIDTH - 1:0]  data_out
);
    logic [DATA_WIDTH - 1:0] fifo [2];

    //logic [DATA_WIDTH - 1:0] read_data_reg;

    logic w_hask;
    logic r_hask;
    assign w_hask = (push_w && !full_w);
    assign r_hask = (pop_r && !empty_r);

    // sync ptr_w
    logic ptr_w;
    logic ptr_w_sync_temp;
    logic ptr_w_sync;
    always_ff @(posedge clk_r) begin
        if(!rstn_r)begin
            ptr_w_sync_temp <= 1'b0;
            ptr_w_sync      <= 1'b0;
        end else begin
            ptr_w_sync_temp <= ptr_w;
            ptr_w_sync      <= ptr_w_sync_temp;
        end
    end

    // sync ptr_r
    logic ptr_r;
    logic ptr_r_sync_temp;
    logic ptr_r_sync;
    always_ff @(posedge clk_w) begin
        if(!rstn_w)begin
            ptr_r_sync_temp <= 1'b0;
            ptr_r_sync      <= 1'b0;
        end else begin
            ptr_r_sync_temp <= ptr_r;
            ptr_r_sync      <= ptr_r_sync_temp;
        end
    end
    
    // write
    always_ff @(posedge clk_w) begin
        if(!rstn_w)begin
            fifo[0]             <= 'b0;
            fifo[1]             <= 'b0;
            ptr_w               <= 1'b0;
        end else begin
            if(w_hask) begin
                fifo[ptr_w]     <= data_in;
                ptr_w           <= ~ptr_w;
            end
        end
    end

    // read
    logic [DATA_WIDTH - 1:0] data_out_q;
    always_ff @(posedge clk_r) begin
        if(!rstn_r)begin
            ptr_r               <= 1'b0;
            data_out_q          <= 'b0;
        end else begin
            if(r_hask)begin
                ptr_r           <= ~ptr_r;
                data_out_q      <= fifo[ptr_r];
            end
        end
    end

    assign full_w  = (ptr_w != ptr_r_sync);
    assign empty_r = (ptr_w_sync == ptr_r);
    assign data_out = data_out_q;
endmodule