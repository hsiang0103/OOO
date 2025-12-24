module ROB (
    input   logic           clk,
    input   logic           rst,
    // Dispatch
    input   logic           DC_valid,
    input   logic [31:0]    DC_pc,
    input   logic [31:0]    DC_inst,
    input   logic [6:0]     DC_P_rd_new,
    input   logic [6:0]     DC_P_rd_old,
    input   logic [5:0]     DC_A_rd,
    output  logic [$clog2(`ROB_LEN)-1:0] DC_rob_idx,
    output  logic           ROB_ready,
    output  logic           ROB_empty,
    // Issue/Register Read
    input   logic           writeback_free,
    input   logic           RR_valid,
    input   logic [$clog2(`ROB_LEN)-1:0] RR_rob_idx,
    // Write Back
    input   logic           WB_valid,
    input   logic [31:0]    WB_data,
    input   logic [$clog2(`ROB_LEN)-1:0] WB_rob_idx,
    // mispredict
    input   logic           mispredict,
    input   logic [$clog2(`ROB_LEN)-1:0] mis_rob_idx,
    output  logic [`ROB_LEN-1:0] flush_mask,
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
    // rollback
    output logic            rollback_en_0,
    output logic [5:0]      rollback_A_rd_0,
    output logic [6:0]      rollback_P_rd_old_0,
    output logic [6:0]      rollback_P_rd_new_0,
    output logic            rollback_en_1,
    output logic [5:0]      rollback_A_rd_1,
    output logic [6:0]      rollback_P_rd_old_1,
    output logic [6:0]      rollback_P_rd_new_1,
    // konata
    output  logic           commit,
    output  logic [$clog2(`ROB_LEN)-1:0] commit_rob_idx
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

    typedef enum logic {
        normal,
        recover
    } state_t;

    state_t cs, ns;

    ROB_entry ROB [0:`ROB_LEN-1];
    logic [$clog2(`ROB_LEN)-1:0] ROB_h, ROB_t;
    logic [$clog2(`ROB_LEN)-1:0] ROB_t_sub_1;
    logic [$clog2(`ROB_LEN)-1:0] ROB_t_sub_2;
    logic [$clog2(`ROB_LEN)-1:0] ROB_t_add_1;
    logic [$clog2(`ROB_LEN)-1:0] ROB_h_add_1;
    

    logic [$clog2(`ROB_LEN)-1:0] mis_rob_idx_r;
    logic [`ROB_LEN-1:0] flush_mask_r;
    logic [$clog2(`ROB_LEN)-1:0] miss;
    logic [$clog2(`ROB_LEN)-1:0] target_rob_idx;
    

    assign ROB_t_sub_1      = (ROB_t == '0) ? `ROB_LEN-1 : ROB_t - 1;
    assign ROB_t_add_1      = (ROB_t == `ROB_LEN-1) ? '0 : ROB_t + 1;
    assign ROB_h_add_1      = (ROB_h == `ROB_LEN-1) ? '0 : ROB_h + 1;
    assign ROB_t_sub_2      = (ROB_t <= 1) ? ROB_t + `ROB_LEN-2 : ROB_t - 2;
    assign DC_rob_idx       = ROB_t;
    assign ROB_ready        = !((ROB_t == ROB_h) && ROB[ROB_h].dispatched);
    assign ROB_empty        = (ROB_t == ROB_h) && !ROB[ROB_h].dispatched;

    // commit
    assign commit_wb_en     = commit && ROB[ROB_h].P_rd_new != 7'd0;
    assign commit_rob_idx   = ROB_h;
    assign commit_P_rd_old  = ROB[ROB_h].P_rd_old;
    assign commit_P_rd_new  = ROB[ROB_h].P_rd_new;
    assign commit_A_rd      = ROB[ROB_h].A_rd;
    assign commit_data      = ROB[ROB_h].data; // debug
    assign commit_pc        = ROB[ROB_h].pc;   // debug
    assign commit_inst      = ROB[ROB_h].inst; // debug
    assign commit           = ROB[ROB_h].written && ROB[ROB_h].dispatched && (!flush_mask_r[ROB_h] && !flush_mask[ROB_h]);
    assign ld_commit        = commit && (ROB[ROB_h].inst[6:2] == `FLOAD  || ROB[ROB_h].inst[6:2] == `LOAD);
    assign st_commit        = commit && (ROB[ROB_h].inst[6:2] == `FSTORE || ROB[ROB_h].inst[6:2] == `S_TYPE);

    // flush mask generation
    always_comb begin
        for (int i = 0; i < `ROB_LEN; i++) begin
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

    // ====================
    // rollback 
    // ====================

    always_ff @(posedge clk) begin
        if (rst) begin
            cs              <= normal;
            mis_rob_idx_r   <= '0;
            flush_mask_r    <= '0;
        end
        else begin
            cs              <= ns;
            mis_rob_idx_r   <= (mispredict)? mis_rob_idx : mis_rob_idx_r;
            flush_mask_r    <= (mispredict)? flush_mask : (stall)? flush_mask_r : '0;
        end
    end

    assign rollback_en_0        = (cs == recover) && (ROB_t != mis_rob_idx_r);
    assign rollback_A_rd_0      = ROB[ROB_t].A_rd;
    assign rollback_P_rd_old_0  = ROB[ROB_t].P_rd_old;
    assign rollback_P_rd_new_0  = ROB[ROB_t].P_rd_new;

    assign rollback_en_1        = (cs == recover) && (ROB_t != mis_rob_idx_r) && (ROB_t_sub_1 != mis_rob_idx_r);
    assign rollback_A_rd_1      = ROB[ROB_t_sub_1].A_rd;
    assign rollback_P_rd_old_1  = ROB[ROB_t_sub_1].P_rd_old;
    assign rollback_P_rd_new_1  = ROB[ROB_t_sub_1].P_rd_new;

    assign stall                = (cs != normal);

    assign miss                 = (mispredict && !flush_mask_r[mis_rob_idx]) ? mis_rob_idx : mis_rob_idx_r;
    assign target_rob_idx       = miss + 1;

    logic [$clog2(`ROB_LEN)-1:0] next_rob_t;
    assign next_rob_t = (rollback_en_1) ? ROB_t_sub_1 : ROB_t;

    always_comb begin
        case (cs)
            normal:     ns = (mispredict && next_rob_t != target_rob_idx) ? recover : normal;
            recover:    ns = (next_rob_t == target_rob_idx) ? normal : recover;
            default:    ns = normal;
        endcase
    end

    // ====================
    // ROB management
    // ====================

    // ROB pointers
    always_ff @(posedge clk) begin
        if(rst) begin
            ROB_h           <= '0;
            ROB_t           <= '0;
        end
        else begin
            unique case (cs)
                normal: begin
                    if (ns == recover) begin
                        ROB_t <= ROB_t_sub_1;
                    end
                    else if (DC_valid) begin
                        ROB_t <= ROB_t_add_1;
                    end
                end
                recover: begin
                    if(ns == normal) begin
                        ROB_t <= target_rob_idx;
                    end
                    else if (rollback_en_1) begin
                        ROB_t <= ROB_t_sub_2;
                    end
                    else if (rollback_en_0) begin
                        ROB_t <= ROB_t_sub_1;
                    end
                end
            endcase

            if (ROB[ROB_h].written && !flush_mask_r[ROB_h] && !flush_mask[ROB_h]) begin
                ROB_h <= ROB_h_add_1;
            end
        end
    end

    // ROB entries management
    always_ff @(posedge clk) begin
        if(rst) begin
            for (int i = 0; i < `ROB_LEN; i = i + 1) begin : init_ROB
                ROB[i] <= '{default:0};
            end
        end
        else begin
            for(int i = 0; i < `ROB_LEN; i = i + 1) begin : ROB_operations
                // rollback
                if (cs == recover && (
                    (rollback_en_0 && i == ROB_t) || 
                    (rollback_en_1 && i == ROB_t_sub_1)
                )) begin
                    ROB[i] <= '{default:0};
                end
                // commit
                else if (i == ROB_h && ROB[i].written && ROB[i].dispatched && 
                         !flush_mask_r[i] && !flush_mask[i]) begin 
                    ROB[i] <= '{default:0};
                end
                // dispatch
                else if (DC_valid && ROB_ready && i == ROB_t && !ROB[i].dispatched) begin
                    ROB[i].pc          <= DC_pc;
                    ROB[i].inst        <= DC_inst;
                    ROB[i].P_rd_new    <= DC_P_rd_new;
                    ROB[i].P_rd_old    <= DC_P_rd_old;
                    ROB[i].A_rd        <= DC_A_rd;
                    ROB[i].dispatched  <= 1'b1;
                    ROB[i].issued      <= 1'b0;
                    ROB[i].written     <= 1'b0;
                end
                // issue / write back
                else if (ROB[i].dispatched) begin
                    if (RR_valid && RR_rob_idx == i) begin
                        ROB[i].issued  <= 1'b1;
                        ROB[i].written <= writeback_free; 
                    end
                    if (WB_valid && WB_rob_idx == i) begin
                        ROB[i].written <= 1'b1;
                        ROB[i].data    <= WB_data;
                    end
                end
            end
        end
    end
endmodule
