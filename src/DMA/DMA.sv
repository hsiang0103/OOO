module DMA (
    input clk,
    input rstn,
    output [1:0]                        dma_state,
    input                               dma_valid,
    output                              dma_ready,
    input [`AXI_ADDR_BITS - 1: 0]       dma_addr,
    input [`AXI_DATA_BITS - 1 : 0]      dma_data,
    output                              interrupt,

    input                               descr_valid,
    output                              descr_ready,
    output  [`AXI_ADDR_BITS - 1: 0]     descr_addr,
    input   [`AXI_DATA_BITS - 1 : 0]    descr_data,
    
    input                               read_da_valid,
    output                              read_da_ready,
    output  [`AXI_ADDR_BITS - 1: 0]     read_addr_start,
    output  [`AXI_ADDR_BITS - 1: 0]     read_addr_end,
    input   [`AXI_DATA_BITS - 1 : 0]    read_da,

    input                               write_da_ready,
    output                              write_da_valid,
    output  [`AXI_ADDR_BITS - 1: 0]     write_addr_start,
    output  [`AXI_ADDR_BITS - 1: 0]     write_addr_end,
    output  [`AXI_DATA_BITS - 1 : 0]    write_da
);  
    parameter DMAEN_ADDR        = 32'h10020100;
    parameter DESC_BASE_ADDR    = 32'h10020200;

    typedef enum logic [1:0]{
        IDLE        = 2'd0,
        READ_DECR   = 2'd1,
        MOVE_DATA   = 2'd2,
        FINISH      = 2'd3
    } state_t;

    typedef struct packed {
        logic [`AXI_DATA_BITS - 1 : 0] DMASRC;
        logic [`AXI_DATA_BITS - 1 : 0] DMADST;
        logic [`AXI_DATA_BITS - 1 : 0] DMALEN;
        logic [`AXI_DATA_BITS - 1 : 0] NEXT_DESC;
        logic [`AXI_DATA_BITS - 1 : 0] EOC;
    } Descriptor_t;

    parameter DEXSRIPTOR_LEN_MINUS_ONE = 4;

    logic dma_hask;
    logic descr_hask;
    logic read_da_hask;
    logic write_da_hask;
    assign dma_hask         = dma_valid         & dma_ready;
    assign descr_hask       = descr_valid       & descr_ready;
    assign read_da_hask     = read_da_valid     & read_da_ready;
    assign write_da_hask    = write_da_valid    & write_da_ready;
    logic [2 : 0]                   cnt_decr;
    logic [`AXI_DATA_BITS - 1 : 0]  cnt_read;
    logic [`AXI_DATA_BITS - 1 : 0]  cnt_write;
    Descriptor_t descriptor_reg;
    state_t cs;
    state_t ns;
    always_ff @(posedge clk) begin
        if(!rstn)begin
            cs <= IDLE;
        end else begin
            cs <= ns;
        end
    end
    always_comb begin
        case (cs)
            IDLE:       begin
                if(dma_hask && dma_addr == DMAEN_ADDR && dma_data == 32'b1)begin
                    ns = READ_DECR;
                end else begin
                    ns = IDLE;
                end
            end
            READ_DECR:  begin
                if(cnt_decr == DEXSRIPTOR_LEN_MINUS_ONE && descr_hask)begin
                    ns = MOVE_DATA;
                end else begin
                    ns = READ_DECR;
                end
            end   
            MOVE_DATA:  begin
                if((cnt_write == descriptor_reg.DMALEN-1)&& write_da_hask)begin
                    if(descriptor_reg.EOC)begin
                        ns = FINISH;
                    end else begin
                        ns = READ_DECR;
                    end
                end else begin
                    ns = MOVE_DATA;
                end
            end
            FINISH:     begin
                if(dma_hask && dma_addr == DMAEN_ADDR && dma_data == 32'b0)begin
                    ns = IDLE;
                end else begin
                    ns = FINISH;
                end
            end
        endcase
    end

    // -----------------------------------
    //                  IDLE
    // -----------------------------------
    logic [`AXI_DATA_BITS - 1 : 0] DESC_BASE_reg;
    always_ff @(posedge clk) begin
        if(!rstn)begin
            DESC_BASE_reg <= `AXI_DATA_BITS;
        end else begin
            if(cs == IDLE)begin
                if(dma_hask && dma_addr == DESC_BASE_ADDR)begin
                    DESC_BASE_reg <= dma_data;
                end
            end else if (cs == MOVE_DATA && ns == READ_DECR)begin
                DESC_BASE_reg <= descriptor_reg.NEXT_DESC;
            end
        end
    end
    assign dma_ready = (cs == IDLE || cs == FINISH);
    assign dma_state = cs;

    // -----------------------------------
    //                  READ_DECR
    // -----------------------------------
    always_ff @(posedge clk) begin
        if(!rstn)begin
            cnt_decr <= 5'b0;
        end else begin
          if(cs == READ_DECR && ns != READ_DECR)begin
            cnt_decr <= 5'b0;
          end else if (cs == READ_DECR)begin
            if(descr_hask)begin
              cnt_decr <= cnt_decr + 5'b1;
            end
          end
        end
    end
    assign descr_addr = DESC_BASE_reg;
    assign descr_ready = (cs == READ_DECR);
    always_ff @(posedge clk) begin
        if(!rstn)begin
            descriptor_reg <= Descriptor_t'(0);
        end else begin
            if(cs == READ_DECR && descr_hask)begin
                case (cnt_decr)
                    3'd0 : descriptor_reg.DMASRC       <= descr_data;
                    3'd1 : descriptor_reg.DMADST       <= descr_data;
                    3'd2 : descriptor_reg.DMALEN       <= descr_data;
                    3'd3 : descriptor_reg.NEXT_DESC    <= descr_data;
                    3'd4 : descriptor_reg.EOC          <= descr_data;
                endcase
            end
        end
    end

    // -----------------------------------
    //                  MOVE_DATA
    // -----------------------------------
    assign read_addr_start  = descriptor_reg.DMASRC;
    assign read_addr_end  = descriptor_reg.DMASRC + (descriptor_reg.DMALEN << 2);
    assign write_addr_start = descriptor_reg.DMADST;
    assign write_addr_end = descriptor_reg.DMADST + (descriptor_reg.DMALEN << 2);
    always_ff @(posedge clk) begin
        if(!rstn)begin
            cnt_read <= `AXI_DATA_BITS'b0;
            cnt_write <= `AXI_DATA_BITS'b0;
        end else begin
            if(cs == MOVE_DATA && ns != MOVE_DATA)begin
                cnt_read <= `AXI_DATA_BITS'b0;
                cnt_write <= `AXI_DATA_BITS'b0;
            end
            else if(cs == MOVE_DATA)begin
                if(read_da_hask)begin
                    cnt_read <= cnt_read + `AXI_DATA_BITS'd1;
                end

                if(write_da_hask)begin
                    cnt_write <= cnt_write + `AXI_DATA_BITS'd1;
                end
            end
        end
    end
    logic i_valid;
    assign i_valid = read_da_valid;
    logic o_ready;
    logic o_valid;
    logic i_ready;
    assign i_ready = write_da_ready;
    PipelineSkidBuf pip_skid_buf(
        .clk(clk),
        .rstn(rstn),
        .i_valid,
        .o_ready,
        .o_valid,
        .i_ready,
        .i_data(read_da),
        .o_data(write_da)
    );
    assign read_da_ready = (cnt_read <= descriptor_reg.DMALEN) & o_ready;
    assign write_da_valid = (cnt_write <= descriptor_reg.DMALEN) & o_valid;

    assign interrupt = (cs == FINISH);
endmodule
