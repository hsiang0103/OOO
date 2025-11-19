module ROB (
    input   logic           clk,
    input   logic           rst,
    // Dispatch     
    input   logic           DC_valid,
    input   logic [31:0]    DC_pc,
    input   logic [31:0]    DC_inst,
    input   logic [6:0]     DC_P_rd_new,
    input   logic [6:0]     DC_P_rd_old,
    output  logic [2:0]     DC_rob_idx,
    output  logic           ROB_ready,
    // Issue/Register Read
    input   logic           writeback_free,
    input   logic           RR_valid,
    input   logic [2:0]     RR_rob_idx,
    // Write Back
    input   logic           WB_valid,
    input   logic [31:0]    WB_data,
    input   logic [2:0]     WB_rob_idx,
    // mispredict
    input   logic           mispredict,
    input   logic [2:0]     mis_rob_idx,
    output  logic [7:0]     flush_mask,
    // Commit
    output  logic           commit_wb_en,
    output  logic [6:0]     commit_P_rd_old,
    output  logic [6:0]     commit_P_rd_new,
    output  logic [5:0]     commit_A_rd,
    output  logic [31:0]    commit_data, // debug
    output  logic [31:0]    commit_pc,   // debug
    output  logic [31:0]    commit_inst, // debug
    output  logic           ld_commit,
    output  logic           st_commit,
    // recovery
    output  logic           stall,
    output  logic           recovery,
    // konata
    output  logic           commit,
    output  logic [2:0]     commit_rob_idx
);

    typedef struct packed{
        logic [31:0]    pc;     // debug
        logic [31:0]    inst;   // debug
        logic [31:0]    data;   // debug
        logic [6:0]     P_rd_new;
        logic [6:0]     P_rd_old;
        logic [5:0]     A_rd;
        logic           dispatched; // Dispatched
        logic           issued;     // Issued
        logic           written;    // Written
    } ROB_entry;

    ROB_entry ROB [0:7];
    logic [2:0] ROB_h, ROB_t;
    logic [31:0] commit_wb_data;

    assign DC_rob_idx       = ROB_t;
    assign ROB_ready        = !((ROB_t == ROB_h) && ROB[ROB_h].dispatched);
    assign commit_wb_en     = ROB[ROB_h].written && ROB[ROB_h].P_rd_new != 7'd0;
    assign commit_P_rd_old  = ROB[ROB_h].P_rd_old;
    assign commit_P_rd_new  = ROB[ROB_h].P_rd_new;
    assign commit_A_rd      = ROB[ROB_h].A_rd;
    assign commit_data      = ROB[ROB_h].data; // debug
    assign commit_pc        = ROB[ROB_h].pc;   // debug
    assign commit_inst      = ROB[ROB_h].inst; // debug
    assign ld_commit        = commit && (ROB[ROB_h].inst[6:2] == `FLOAD  || ROB[ROB_h].inst[6:2] == `LOAD);
    assign st_commit        = commit && (ROB[ROB_h].inst[6:2] == `FSTORE || ROB[ROB_h].inst[6:2] == `S_TYPE);

    assign commit           = ROB[ROB_h].written && ROB[ROB_h].dispatched; 
    assign commit_rob_idx   = ROB_h;

    always_comb begin
        for (int i = 0; i < 8; i++) begin
            if(mispredict) begin
                if(ROB_h <= mis_rob_idx) begin
                    flush_mask[i] = !((i >= ROB_h) && (i <= mis_rob_idx));
                end
                else begin
                    flush_mask[i] = !((i >= ROB_h) || (i <= mis_rob_idx));
                end
            end
            else begin
                flush_mask[i] = 1'b0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if(rst) begin
            ROB_h <= 3'd0;
            ROB_t <= 3'd0;
            for (int i = 0; i < 8; i = i + 1) begin : init_ROB
                ROB[i] <= '{default:0};
            end
        end
        else begin
            if(mispredict) begin
                ROB_t <= mis_rob_idx + 3'd1;
            end
            else begin
                if (DC_valid && ROB_ready) begin
                    ROB_t <= ROB_t + 3'd1;
                end
            end
            

            if (ROB[ROB_h].written) begin 
                ROB_h <= ROB_h + 3'd1;
            end
            
            for(int i = 0; i < 8; i = i + 1) begin : ROB_operations
                if(mispredict && flush_mask[i]) begin
                    ROB[i] <= '{default:0};
                end
                else begin
                    // dispatch
                    if(ROB_t == i && DC_valid && ROB_ready && !ROB[i].dispatched) begin
                        ROB[i].pc           <= DC_pc;
                        ROB[i].inst         <= DC_inst;
                        ROB[i].P_rd_new     <= DC_P_rd_new;
                        ROB[i].P_rd_old     <= DC_P_rd_old;
                        ROB[i].A_rd         <= DC_inst[11:7];
                        ROB[i].dispatched   <= 1'b1;
                    end
                    // issue
                    if(RR_rob_idx == i && RR_valid && ROB[i].dispatched) begin
                        ROB[i].issued       <= 1'b1;
                        ROB[i].written      <= writeback_free;
                    end
                    // write back
                    if(WB_rob_idx == i && WB_valid && ROB[i].dispatched) begin
                        ROB[i].written      <= 1'b1;
                        ROB[i].data         <= WB_data;
                    end
                    // commit
                    if(ROB_h == i && ROB[ROB_h].written && ROB[i].dispatched) begin
                        ROB[i]              <= '{default:0};
                    end
                end
            end
        end
    end

    typedef enum logic [1:0] {
        normal,
        pending,
        recover
    } state_t;

    state_t cs, ns;

    always_ff @(posedge clk) begin
        if (rst) begin
            cs <= normal;
        end
        else begin
            cs <= ns;
        end
    end

    always_comb begin
        unique case (cs)
            normal:     ns = (mispredict) ? pending : normal;
            pending:    ns = (ROB_h == ROB_t && !ROB[ROB_h].dispatched) ? recover : pending;
            recover:    ns = normal;
            default:    ns = normal;
        endcase
        stall       = (cs != normal);
        recovery    = (cs == recover);
    end
endmodule