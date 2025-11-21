module Rename (
    input   logic           clk,
    input   logic           rst,
    // Rename 
    input   logic [5:0]     A_rs1,
    input   logic [5:0]     A_rs2,
    input   logic [5:0]     A_rd,
    input   logic           allocate_rd,
    output  logic [6:0]     P_rs1,
    output  logic [6:0]     P_rs2,
    output  logic [6:0]     P_rd_new,
    output  logic [6:0]     P_rd_old,
    // Dispatch
    input   logic [4:0]     DC_op,    
    input   logic [6:0]     DC_rs1,
    input   logic [6:0]     DC_rs2,
    output  logic           DC_P_rs1_valid,
    output  logic           DC_P_rs2_valid,
    // Write Back
    input   logic           WB_valid,
    input   logic [6:0]     WB_rd,
    // Commit
    input   logic           commit_wb_en,
    input   logic [6:0]     commit_P_rd_new,
    input   logic [6:0]     commit_P_rd_old,
    input   logic [5:0]     commit_A_rd,
    // recovery 
    input   logic           recovery,
    // rollback
    input   logic           rollback_en_0,
    input   logic [5:0]     rollback_A_rd_0,
    input   logic [6:0]     rollback_P_rd_old_0,
    input   logic [6:0]     rollback_P_rd_new_0,
    input   logic           rollback_en_1,
    input   logic [5:0]     rollback_A_rd_1,
    input   logic [6:0]     rollback_P_rd_old_1,
    input   logic [6:0]     rollback_P_rd_new_1
);

logic [6:0]     RAT [0:63];         // Register Alias Table
logic [6:0]     CMT [0:63];         // Commit Map Table
logic [79:0]    valid_map;          // Valid Map
logic [6:0]     freelist [0:15];    // Free List
logic [3:0]     free_h, free_t;     // Free List Head and Tail

assign P_rs1    = RAT[A_rs1];
assign P_rs2    = RAT[A_rs2];
assign P_rd_old = RAT[A_rd];
assign P_rd_new = (allocate_rd) ? freelist[free_t] : 7'd0;

logic use_rs1, use_rs2;

assign use_rs1  = DC_op != `LUI    && DC_op != `AUIPC  && DC_op != `JAL;
assign use_rs2  = DC_op == `R_TYPE || DC_op == `S_TYPE || DC_op == `FSTORE || DC_op == `B_TYPE || DC_op == `F_TYPE;

assign DC_P_rs1_valid   = !use_rs1 || valid_map[DC_rs1] || (DC_rs1 == commit_P_rd_new && commit_wb_en);
assign DC_P_rs2_valid   = !use_rs2 || valid_map[DC_rs2] || (DC_rs2 == commit_P_rd_new && commit_wb_en);

always_ff @(posedge clk) begin
    if (rst) begin
        valid_map       <= 80'hFFFFFFFFFFFFFFFFFFFF;
        free_h          <= 4'd0;
        free_t          <= 4'd0;
        for (int i = 0; i < 16; i = i + 1) begin
            freelist[i]   <= i + 64;
        end
        for (int i = 0; i < 64; i = i + 1) begin
            RAT[i] <= i;
            CMT[i] <= i;
        end
    end
    else begin
        if (rollback_en_0 || rollback_en_1) begin
            free_t <= free_t - (rollback_en_0 && rollback_P_rd_new_0 != 7'd0)
                             - (rollback_en_1 && rollback_P_rd_new_1 != 7'd0);
        end
        else if (allocate_rd) begin
            free_t <= free_t + 4'd1;
        end
        else begin
            free_t <= free_t;
        end

        if(commit_wb_en) begin
            free_h  <= free_h + 4'd1;
        end

        for(int i = 0; i < 80; i = i + 1) begin : valid_map_control
            // recovery
            if(recovery) begin
                valid_map[i] <= 1'b1;
            end
            // write back
            if(WB_rd == i && WB_valid) begin
                valid_map[i] <= 1'b1;
            end
            // rollback
            if ((rollback_en_0 && rollback_P_rd_new_0 == i && rollback_P_rd_new_0 != 7'd0) || 
                (rollback_en_1 && rollback_P_rd_new_1 == i && rollback_P_rd_new_1 != 7'd0)) begin
                valid_map[i] <= 1'b1;
            end
            // dispatch
            if(P_rd_new == i && allocate_rd) begin
                valid_map[i] <= 1'b0;
            end
        end

        for (int i = 0; i < 64; i = i + 1) begin : RAT_update
            // rollback
            if (rollback_en_0 || rollback_en_1) begin
                if (rollback_en_1 && rollback_A_rd_1 == i && rollback_P_rd_new_1 != 7'd0) begin
                    RAT[i] <= rollback_P_rd_old_1;
                end
                else if (rollback_en_0 && rollback_A_rd_0 == i && rollback_P_rd_new_0 != 7'd0) begin
                    RAT[i] <= rollback_P_rd_old_0;
                end
            end
            // rename
            else if (A_rd == i && allocate_rd) begin
                RAT[i] <= P_rd_new;
            end
            // do nothing
            else begin
                RAT[i] <= RAT[i];
            end
        end
    
        if (commit_wb_en) begin
            freelist[free_h]    <= commit_P_rd_old;
            CMT[commit_A_rd]    <= commit_P_rd_new;
        end
    end
end

endmodule