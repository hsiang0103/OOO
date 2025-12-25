module WDT (
    input clk,
    input rstn,

    input   WDEN_valid,
    output  WDEN_ready,
    input   WDEN,

    input   WDLIVE_valid,
    output  WDLIVE_ready,
    input   WDLIVE,

    input   WTOCNT_valid,
    output  WTOCNT_ready,
    input   [31:0] WTOCNT, 

    output  interrupt_valid,
    input   interrupt_ready,
    output  interrupt
);
    typedef enum logic [1:0] {
        IDLE        = 2'b0,
        COUNTING    = 2'b1,
        INTERRUPT   = 2'd2
    } state_t;
    state_t cs;
    state_t ns;

    logic [31:0] cnt;
    logic [31:0] cnt_limit;

    logic WDEN_hask;
    logic WDLIVE_hask;
    logic WTOCNT_hask;
    logic interrupt_hask;
    logic WDEN_hask_delay;
    logic WDLIVE_hask_delay;
    logic WTOCNT_hask_delay;
    always_ff @(posedge clk) begin
        if (!rstn) begin
            WDEN_hask_delay         <= 1'b0;
            WDLIVE_hask_delay       <= 1'b0;
            WTOCNT_hask_delay       <= 1'b0;
        end else begin
            WDEN_hask_delay         <= WDEN_hask;
            WDLIVE_hask_delay       <= WDLIVE_hask;
            WTOCNT_hask_delay       <= WTOCNT_hask;
        end
    end
    assign WDEN_hask      = WDEN_valid      & WDEN_ready;
    assign WDLIVE_hask    = WDLIVE_valid    & WDLIVE_ready;
    assign WTOCNT_hask    = WTOCNT_valid    & WTOCNT_ready;
    assign interrupt_hask = interrupt_valid & interrupt_ready;

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
                ns = (WDEN_hask_delay && WDEN)? COUNTING : IDLE;
            end
            COUNTING:   begin
                ns = (cnt == cnt_limit)? INTERRUPT :COUNTING;
            end
            INTERRUPT:  begin
                ns = (WDEN_hask_delay && !WDEN)?IDLE:INTERRUPT;
            end
            default: ns = IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if(!rstn)begin
            cnt <= 32'b0;
            cnt_limit <= 32'b0;
        end else begin
            if(cs == IDLE)begin
                cnt <= 32'b0;
            end
            else if(WDLIVE_hask_delay && WDLIVE)begin
                cnt <= 32'b0;
            end
            else if(cs == COUNTING)begin
                cnt <= cnt + 32'b1;
            end

            if(WTOCNT_hask_delay)begin
                cnt_limit <= WTOCNT;
            end
        end
    end

    assign WDEN_ready       = 1'b1;
    assign WDLIVE_ready     = 1'b1;
    assign WTOCNT_ready     = 1'b1;
    logic interrupt_valid_q;
    always_ff @(posedge clk) begin
        if(!rstn)begin
            interrupt_valid_q <= 1'b0;
        end else begin
            if(cs == COUNTING && ns == INTERRUPT)begin
                interrupt_valid_q <= 1'b1;
            end else if(cs == INTERRUPT && interrupt_hask) begin
                interrupt_valid_q <= 1'b0;
            end else if(cs == INTERRUPT && ns == IDLE)begin
                interrupt_valid_q <= 1'b1;
            end else if(interrupt_valid_q && interrupt_hask) begin
                interrupt_valid_q <= 1'b0;
            end
        end
    end
    assign interrupt_valid  = interrupt_valid_q;
    assign interrupt = (cs == INTERRUPT);
endmodule