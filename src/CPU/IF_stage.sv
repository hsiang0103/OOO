module IF_stage(
        input   logic           clk,
        input   logic           rst,
        // BPU (Branch Prediction Unit)
        input   logic [31:0]    next_pc,      
        input   logic           next_jump,    
        // IM (Instruction Memory Wrapper)
        input   logic [31:0]    fetch_data,
        input   logic           fetch_data_valid,
        input   logic           fetch_req_ready,     
        output  logic [31:0]    fetch_addr,
        output  logic           fetch_req_valid,
        // EXE stage
        input   logic [31:0]    jb_pc,         
        input   logic           mispredict,    
        // DC stage (Decode Stage)
        input   logic           DC_ready,     
        output  logic [31:0]    IF_out_pc,
        output  logic [31:0]    IF_out_inst,
        output  logic           IF_out_jump,
        output  logic           IF_valid
    );


    typedef enum logic {
        SEND_REQ,   
        WAIT_DATA   
    } state_t;

    state_t cs, ns;
    logic fetch_handshake;

    localparam FIFO_DEPTH = `INST_QUEUE_LEN;
    localparam DATA_WIDTH = 32 + 32 + 1; // PC(32) + Inst(32) + Jump(1)

    logic [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    logic [$clog2(FIFO_DEPTH):0] wr_ptr, rd_ptr; 
    logic [DATA_WIDTH-1:0] fifo_in;
    logic [DATA_WIDTH-1:0] fifo_out;
    
    logic fifo_full, fifo_empty;
    logic fifo_write, fifo_read;


    assign fetch_handshake = fetch_req_valid && fetch_req_ready;

    logic [31:0] pc;
    logic        jump;
    logic        mispredict_r;
    
    assign fetch_addr = pc;

    always_ff @(posedge clk) begin
        if (rst) begin
            pc              <= `RESET_ADDR;
            jump            <= 1'b0;
            mispredict_r    <= 1'b0;
        end
        else begin
            if (mispredict || (fetch_data_valid && !mispredict_r)) begin
                pc      <= next_pc;
                jump    <= next_jump;
            end

            if(cs == SEND_REQ) begin
                mispredict_r <= 1'b0;
            end
            else  begin
                mispredict_r <= (mispredict_r)? mispredict_r : mispredict;
            end
        end
    end

    assign fetch_req_valid = (cs == SEND_REQ) && !mispredict && !fifo_full;


    // State Register
    always_ff @(posedge clk) begin
        if (rst) begin
            cs <= SEND_REQ; 
        end
        else begin
            cs <= ns;
        end
    end

    // Next State Logic
    always_comb begin
        if(cs == SEND_REQ) begin
            ns = (fetch_handshake) ? WAIT_DATA : SEND_REQ; 
        end
        else begin
            ns = (fetch_data_valid) ? SEND_REQ : WAIT_DATA; 
        end
    end

    
    assign fifo_empty = (wr_ptr == rd_ptr);
    assign fifo_full  = (wr_ptr[$clog2(FIFO_DEPTH)] != rd_ptr[$clog2(FIFO_DEPTH)]) && 
                        (wr_ptr[$clog2(FIFO_DEPTH)-1:0] == rd_ptr[$clog2(FIFO_DEPTH)-1:0]);

    assign fifo_write = fetch_data_valid && !mispredict && !mispredict_r && !fifo_full;
    assign fifo_read  = DC_ready && !fifo_empty;
    assign fifo_in = {pc, fetch_data, next_jump}; 

    // FIFO Pointers & Memory Update
    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end
        else begin
            if(mispredict) begin
                wr_ptr <= 0;
                rd_ptr <= 0;
            end
            else begin
                if (fifo_write) begin
                    fifo_mem[wr_ptr[$clog2(FIFO_DEPTH)-1:0]] <= fifo_in;
                    wr_ptr <= wr_ptr + 1;
                end
                
                if (fifo_read) begin
                    rd_ptr <= rd_ptr + 1;
                end
            end
        end
    end

    assign fifo_out = fifo_mem[rd_ptr[$clog2(FIFO_DEPTH)-1:0]];
    assign {IF_out_pc, IF_out_inst, IF_out_jump} = (IF_valid)? fifo_out : {32'b0, 32'b0, 1'b0};
    assign IF_valid = !fifo_empty;
    

endmodule