module BPU (
    input   logic clk,
    input   logic rst,
    // From IF stage
    input   logic [31:0] IM_addr,
    input   logic DC_ready,
    // From EX stage
    input   logic RR_valid,
    input   logic EX_ready, // alu ready
    input   logic [31:0] RR_out_pc,
    input   logic mispredict,
    input   logic is_jb,
    input   logic [31:0] jb_pc,
    // To IF stage
    output  logic [31:0] next_pc,
    output  logic jump_out,
    // early branch
    input   logic           DC_mispredict,
    input   logic [31:0]    DC_redirect_pc
);

    // Branch Target Buffer
    logic [28:0] BTB_tag [0:1];
    logic [31:0] BTB_target [0:1];
    logic [1:0] BTB_valid;

    integer i;

    logic pc_index, RR_out_pc_index;
    logic [28:0] pc_tag, RR_out_pc_tag; 
    logic [31:0] pc_add_4;

    

    always_comb begin
        pc_add_4        = IM_addr + 32'd4;
        pc_index        = IM_addr[2];
        pc_tag          = IM_addr[31:3];
        RR_out_pc_index = RR_out_pc[2];
        RR_out_pc_tag   = RR_out_pc[31:3];

        if(mispredict) begin
            next_pc     = jb_pc + 32'd4;
            jump_out    = 1'b0;
        end
        else if(DC_mispredict) begin
            next_pc     = DC_redirect_pc + 32'd4;
            jump_out    = 1'b1;
        end
        else if(DC_ready) begin
            if((BTB_valid[pc_index] && (BTB_tag[pc_index] == pc_tag))) begin
                next_pc     = BTB_target[pc_index];
                // next_pc     = pc_add_4;
                jump_out    = BTB_target[pc_index] != pc_add_4;
            end
            else begin
                next_pc     = pc_add_4;
                jump_out    = 1'b0;
            end
        end
        else begin
            next_pc     = IM_addr;
            jump_out    = 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 2; i = i + 1) begin
                BTB_tag[i]      <= 29'b0;
                BTB_target[i]   <= 32'b0;
            end
            BTB_valid <= 2'b0;
        end
        else begin
            if(is_jb && RR_valid && EX_ready) begin
                // Update BTB
                BTB_tag[RR_out_pc_index]    <= RR_out_pc_tag;
                BTB_target[RR_out_pc_index] <= jb_pc;
                BTB_valid[RR_out_pc_index]  <= 1'b1;
            end
        end
    end
endmodule
