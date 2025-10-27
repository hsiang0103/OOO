module IS_stage (
    input clk,
    input rst,

    // From DC stage
    input logic [15:0]  IS_in_pc,
    input logic [31:0]  IS_in_inst, 
    input logic [31:0]  IS_in_imm,
    input logic [4:0]   IS_in_op,
    input logic [2:0]   IS_in_f3,
    input logic [6:0]   IS_in_f7,
    input logic [6:0]   IS_in_rs1,  
    input logic [6:0]   IS_in_rs2,
    input logic [1:0]   IS_in_rs1_valid,
    input logic [1:0]   IS_in_rs2_valid,
    input logic [6:0]   IS_in_P_rd_new,
    input logic [6:0]   IS_in_P_rd_old,
    input logic [5:0]   IS_in_A_rd,
    input logic [2:0]   IS_in_fu_sel,

    // From LSU
    input logic [1:0]   IS_in_ld_idx,
    input logic [1:0]   IS_in_st_idx,

    // From EXE stage
    input logic         mispredict,
    input logic [2:0]   mis_rob_idx,

    // From WB stage
    input logic         WB_valid,
    input logic [31:0]  WB_data,
    input logic [2:0]   WB_rob_idx,

    // To DC stage
    output logic        commit_wb_en,
    output logic [6:0]  commit_P_rd_old,
    output logic [6:0]  commit_P_rd_new,
    output logic [5:0]  commit_A_rd,
    output logic        recovery,

    // To EXE stage
    output logic [15:0] IS_out_pc,
    output logic [31:0] IS_out_inst, 
    output logic [31:0] IS_out_rs1_data,  
    output logic [31:0] IS_out_rs2_data,  
    output logic [31:0] IS_out_imm,
    output logic [4:0]  IS_out_op,
    output logic [2:0]  IS_out_f3,
    output logic [6:0]  IS_out_f7,
    output logic [2:0]  IS_out_fu_sel,
    output logic [1:0]  IS_out_ld_idx,
    output logic [1:0]  IS_out_st_idx,
    output logic [2:0]  IS_out_rob_idx, 

    // To LSU
    output logic        ld_commit,
    output logic        st_commit,

    // Handshake signals
    // DC --- IS
    input logic         DC_valid,
    output logic        IS_ready,
    // IS --- EXE
    output logic        IS_valid,
    input logic [4:0]   EXE_ready,

    // lonata
    output logic [2:0]  ROB_tail,
    output logic        commit,
    output logic [2:0]  commit_rob_idx
);
    // =================
    // ===    ROB    ===
    // =================

    typedef struct {
        logic [31:0]    WB_data;
        logic [31:0]    inst; // debug
        logic [31:0]    imm;
        logic [15:0]    pc;
        logic [4:0]     op;
        logic [2:0]     f3;
        logic [6:0]     f7;
        logic [6:0]     rs1;  
        logic [6:0]     rs2;
        logic           rs1_valid;
        logic           rs2_valid;
        logic [6:0]     P_rd_new;
        logic [6:0]     P_rd_old;
        logic [5:0]     A_rd;
        logic [1:0]     ld_idx;
        logic [1:0]     st_idx;
        logic [2:0]     fu_sel;
        logic           valid;  // Dispatched
        logic           busy;   // Issued
        logic           ready;  // Wrote back
    } ROB_entry;

    ROB_entry ROB [0:7];
    logic [2:0] ROB_h, ROB_t;
    logic [2:0] ROB_count [0:7];
    logic [2:0] ROB_num;

    // Issue
    logic [7:0] can_issue;
    logic [2:0] issue_ptr;
    logic [7:0] commit_rs1_match;
    logic [7:0] commit_rs2_match;
    logic       issue_use_rd;

    // commit
    logic [31:0] commit_data;

    // flush
    logic [7:0]  flush_mask;
    logic [7:0]  flush_mask_tmp;

    always_comb begin
        for(int i = 0; i < 8; i = i + 1) begin
            ROB_count[i]        = (ROB_h + i) & 3'b111;
            commit_rs1_match[i] = (commit_P_rd_new == ROB[i].rs1) && commit_wb_en;
            commit_rs2_match[i] = (commit_P_rd_new == ROB[i].rs2) && commit_wb_en;
        end

        if(mispredict) begin
            priority case (1'b1)
                ROB_count[0] == mis_rob_idx: flush_mask_tmp = 8'b11111110;
                ROB_count[1] == mis_rob_idx: flush_mask_tmp = 8'b11111100;
                ROB_count[2] == mis_rob_idx: flush_mask_tmp = 8'b11111000;
                ROB_count[3] == mis_rob_idx: flush_mask_tmp = 8'b11110000;
                ROB_count[4] == mis_rob_idx: flush_mask_tmp = 8'b11100000;
                ROB_count[5] == mis_rob_idx: flush_mask_tmp = 8'b11000000;
                ROB_count[6] == mis_rob_idx: flush_mask_tmp = 8'b10000000;
                ROB_count[7] == mis_rob_idx: flush_mask_tmp = 8'b00000000;
                default:                     flush_mask_tmp = 8'b00000000;
            endcase  

            case (ROB_h)
                3'b000:   flush_mask = flush_mask_tmp;
                3'b001:   flush_mask = {flush_mask_tmp[6:0], flush_mask_tmp[7]};
                3'b010:   flush_mask = {flush_mask_tmp[5:0], flush_mask_tmp[7:6]};
                3'b011:   flush_mask = {flush_mask_tmp[4:0], flush_mask_tmp[7:5]};
                3'b100:   flush_mask = {flush_mask_tmp[3:0], flush_mask_tmp[7:4]};
                3'b101:   flush_mask = {flush_mask_tmp[2:0], flush_mask_tmp[7:3]};
                3'b110:   flush_mask = {flush_mask_tmp[1:0], flush_mask_tmp[7:2]};
                3'b111:   flush_mask = {flush_mask_tmp[0]  , flush_mask_tmp[7:1]};
            endcase
        end
        else begin
            flush_mask = 8'b00000000;
        end

        for(int i = 0; i < 8; i = i + 1) begin
            if( (!ROB[i].busy) && (ROB[i].valid) && (flush_mask[i] != 1'b1) &&
                (ROB[i].rs1_valid || commit_rs1_match[i]) && 
                (ROB[i].rs2_valid || commit_rs2_match[i]) && 
                (EXE_ready[ROB[i].fu_sel]) ) begin
                can_issue[i] = 1'b1;
            end
            else begin
                can_issue[i] = 1'b0;
            end
        end

        priority case (1'b1)
            can_issue[ROB_count[0]]: issue_ptr = ROB_count[0];
            can_issue[ROB_count[1]]: issue_ptr = ROB_count[1];
            can_issue[ROB_count[2]]: issue_ptr = ROB_count[2];
            can_issue[ROB_count[3]]: issue_ptr = ROB_count[3];
            can_issue[ROB_count[4]]: issue_ptr = ROB_count[4];
            can_issue[ROB_count[5]]: issue_ptr = ROB_count[5];
            can_issue[ROB_count[6]]: issue_ptr = ROB_count[6];
            can_issue[ROB_count[7]]: issue_ptr = ROB_count[7];
            default: issue_ptr = 3'b0;
        endcase  

        case(ROB[issue_ptr].op)
            /*`S_TYPE, `FSTORE, */`B_TYPE:  issue_use_rd = 1'b0;
            default:                    issue_use_rd = 1'b1;
        endcase
    end

    always_comb begin
        if(ROB[ROB_h].ready) begin
            case(ROB[ROB_h].op)
                `B_TYPE, `S_TYPE, `FSTORE:  commit_wb_en = 1'b0;
                default:                    commit_wb_en = 1'b1;
            endcase

            case(ROB[ROB_h].op)
                `FSTORE, `S_TYPE:           st_commit = 1'b1;
                default:                    st_commit = 1'b0;
            endcase

            case(ROB[ROB_h].op)
                `LOAD, `FLOAD:              ld_commit = 1'b1;
                default:                    ld_commit = 1'b0;
            endcase
        end
        else begin
            commit_wb_en    = 1'b0;
            ld_commit       = 1'b0;
            st_commit       = 1'b0;
        end        
        commit           = ROB[ROB_h].ready;
        commit_P_rd_old  = ROB[ROB_h].P_rd_old;
        commit_P_rd_new  = ROB[ROB_h].P_rd_new;
        commit_A_rd      = ROB[ROB_h].A_rd;
        commit_data      = ROB[ROB_h].WB_data;
    end

    // ROB
    always_ff @(posedge clk) begin
        if(rst) begin
            for(int i = 0; i < 8; i = i + 1) begin
                clear_ROB_entry(ROB[i]);
            end
            ROB_h   <= 3'b0;
            ROB_t   <= 3'b0;
            ROB_num <= 3'b0;
        end
        else begin
            // Dispatch
            if(DC_valid && IS_ready) begin
                ROB[ROB_t].P_rd_new     <= IS_in_P_rd_new;
                ROB[ROB_t].P_rd_old     <= IS_in_P_rd_old;
                ROB[ROB_t].A_rd         <= IS_in_A_rd;
                ROB[ROB_t].inst         <= IS_in_inst;
                ROB[ROB_t].pc           <= IS_in_pc;
                ROB[ROB_t].imm          <= IS_in_imm;
                ROB[ROB_t].op           <= IS_in_op;
                ROB[ROB_t].f3           <= IS_in_f3;
                ROB[ROB_t].f7           <= IS_in_f7;
                ROB[ROB_t].rs1          <= IS_in_rs1;
                ROB[ROB_t].rs2          <= IS_in_rs2;
                ROB[ROB_t].rs1_valid    <= IS_in_rs1_valid;
                ROB[ROB_t].rs2_valid    <= IS_in_rs2_valid;
                ROB[ROB_t].fu_sel       <= IS_in_fu_sel;
                ROB[ROB_t].ld_idx       <= IS_in_ld_idx;
                ROB[ROB_t].st_idx       <= IS_in_st_idx;
                ROB[ROB_t].valid        <= 1'b1;
                ROB[ROB_t].busy         <= 1'b0;
                ROB[ROB_t].ready        <= 1'b0;
                ROB[ROB_t].WB_data      <= 32'b0;
                ROB_t                   <= ROB_t + 1;
            end

            // Issue
            if(|can_issue) begin
                ROB[issue_ptr].busy     <= 1'b1;
                ROB[issue_ptr].ready    <= !issue_use_rd;
            end

            // Write back
            if(WB_valid) begin
                ROB[WB_rob_idx].ready   <= 1'b1;
                ROB[WB_rob_idx].WB_data <= WB_data;
            end

            // Commit
            if(commit) begin
                clear_ROB_entry(ROB[ROB_h]);
                ROB_h <= ROB_h + 1;

                for(int i = 0; i < 8; i = i + 1) begin
                    if(ROB[i].valid && !flush_mask[i]) begin
                        if(ROB[i].rs1 == commit_P_rd_new) begin
                            ROB[i].rs1_valid <= 1'b1;
                        end
                        if(ROB[i].rs2 == commit_P_rd_new) begin
                            ROB[i].rs2_valid <= 1'b1;
                        end
                    end
                end
            end

            // Flush
            if(mispredict) begin
                ROB_t <= mis_rob_idx + 1;
                for(int i = 0; i < 8; i = i + 1) begin
                    if(flush_mask[i]) begin
                        clear_ROB_entry(ROB[i]);
                    end
                end
            end

            // ROB_num Debug
            priority case (1'b1)
                commit && DC_valid && IS_ready: ROB_num <= ROB_num; // stay
                DC_valid && IS_ready:           ROB_num <= ROB_num + 1;
                commit:                         ROB_num <= ROB_num - 1;
                default:                        ROB_num <= ROB_num;
            endcase

        end
    end

    // =================
    // = Register Read =
    // =================
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    RegFile R1(
        .clk(clk),
        .rst(rst),

        // Register Read
        .rs1_index(ROB[issue_ptr].rs1),
        .rs2_index(ROB[issue_ptr].rs2),
        .rs1_data_out(rs1_data),
        .rs2_data_out(rs2_data),

        // Write back
        .wb_en(commit_wb_en && commit_A_rd != 0),
        .wb_data(commit_data),
        .rd_index(commit_P_rd_new)
    );


    // IS - EXE Pipeline Register
    always_ff @(posedge clk) begin
        if(rst) begin
            IS_out_pc          <= 16'b0;
            IS_out_inst        <= 32'b0;
            IS_out_rs1_data    <= 32'b0;
            IS_out_rs2_data    <= 32'b0;
            IS_out_imm         <= 32'b0;
            IS_out_op          <= 5'b0;
            IS_out_f3          <= 3'b0;
            IS_out_f7          <= 7'b0;
            IS_out_fu_sel      <= 3'b0;
        end
        else begin
            if(|can_issue) begin
                IS_out_inst             <= ROB[issue_ptr].inst;
                IS_out_imm              <= ROB[issue_ptr].imm;
                IS_out_pc               <= ROB[issue_ptr].pc;
                IS_out_rs1_data         <= commit_rs1_match[issue_ptr] ? commit_data : rs1_data;
                IS_out_rs2_data         <= commit_rs2_match[issue_ptr] ? commit_data : rs2_data;
                IS_out_op               <= ROB[issue_ptr].op;
                IS_out_f3               <= ROB[issue_ptr].f3;
                IS_out_f7               <= ROB[issue_ptr].f7;
                IS_out_fu_sel           <= ROB[issue_ptr].fu_sel;
                IS_out_ld_idx           <= ROB[issue_ptr].ld_idx;
                IS_out_st_idx           <= ROB[issue_ptr].st_idx;
                IS_out_rob_idx          <= issue_ptr;
            end
            else begin
                IS_out_pc               <= 16'b0;
                IS_out_inst             <= 32'h00000013; // NOP
                IS_out_rs1_data         <= 32'b0;
                IS_out_rs2_data         <= 32'b0;
                IS_out_imm              <= 32'b0;
                IS_out_op               <= 5'b0;
                IS_out_f3               <= 3'b0;
                IS_out_f7               <= 7'b0;
                IS_out_fu_sel           <= 3'b0;
                IS_out_rob_idx          <= 3'b0;
                IS_out_ld_idx           <= 2'b0;
                IS_out_st_idx           <= 2'b0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if(rst) begin
            IS_valid <= 1'b0;
        end
        else begin
            IS_valid <= |can_issue;
        end
    end

    parameter REGULAR = 2'b00;
    parameter PENDING = 2'b01;
    parameter RECOVER = 2'b10;
    logic [1:0] cs, ns;

    always_ff @(posedge clk) begin
        if(rst) begin
            cs <= REGULAR;
        end
        else begin
            cs <= ns;
        end
    end

    always_comb begin
        case(cs)
            REGULAR: ns = mispredict ? PENDING : REGULAR;
            PENDING: ns = (ROB_h == ROB_t && !ROB[ROB_h].valid) ? RECOVER : PENDING;
            RECOVER: ns = REGULAR;
            default: ns = REGULAR;
        endcase

        case(cs)
            REGULAR: IS_ready = !(ROB_h == ROB_t && ROB[ROB_h].valid); // not full
            PENDING: IS_ready = 1'b0;
            RECOVER: IS_ready = 1'b0;
            default: IS_ready = 1'b0;
        endcase

        recovery = (cs == RECOVER);
    end
    
    task clear_ROB_entry(output ROB_entry entry);
        entry.P_rd_new   = 7'b0;
        entry.P_rd_old   = 7'b0;
        entry.A_rd       = 6'b0;
        entry.inst       = 32'b0;
        entry.pc         = 16'b0;
        entry.imm        = 32'b0;
        entry.op         = 5'b0;
        entry.f3         = 3'b0;
        entry.f7         = 7'b0;
        entry.rs1        = 7'b0;
        entry.rs2        = 7'b0;
        entry.rs1_valid  = 1'b0;
        entry.rs2_valid  = 1'b0;
        entry.fu_sel     = 3'b0; 
        entry.ld_idx     = 2'b0;
        entry.st_idx     = 2'b0;   
        entry.WB_data    = 32'b0;
        entry.valid      = 1'b0;
        entry.busy       = 1'b0;    
        entry.ready      = 1'b0;
    endtask


    assign ROB_tail         = ROB_t;
    assign commit_rob_idx   = ROB_h;

endmodule