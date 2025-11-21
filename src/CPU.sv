`include "IF_stage.sv"
`include "DC_stage.sv"
`include "IS_stage.sv"
`include "EXE_stage.sv"
`include "RegFile.sv"
`include "LSU.sv"
`include "ALU.sv"
`include "FALU.sv"
`include "MUL.sv"
`include "CSR.sv"
`include "Rename.sv"
`include "ROB.sv"
`include "BPU.sv"
// synopsys translate_off
`include "konata.sv"
`include "commit_tracker.sv"
// synopsys translate_on

module CPU (
    input logic clk,
    input logic rst,
    // IM 
    input  logic [31:0] IM_r_data,
    output logic [31:0] IM_r_addr,
    output logic        IM_ready,
    // DM
    input  logic [31:0] DM_rd_data,
    output logic        DM_c_en,
    output logic        DM_r_en,
    output logic [31:0] DM_w_en,
    output logic [31:0] DM_addr,
    output logic [31:0] DM_w_data
);
    // =========================
    // === Wire Instiantiate ===
    // =========================

    // IF stage output 
    logic [31:0] IF_out_pc;
    logic [31:0] IF_out_inst;
    logic        IF_out_jump;
    logic        IF_valid;
    
    // DC stage output
    logic [31:0] DC_out_pc;
    logic [31:0] DC_out_inst;
    logic [31:0] DC_out_imm;
    logic [4:0]  DC_out_op;
    logic [2:0]  DC_out_f3;
    logic [6:0]  DC_out_f7;
    logic [6:0]  DC_out_P_rs1;
    logic [6:0]  DC_out_P_rs2;
    logic [6:0]  DC_out_P_rd;
    logic [2:0]  DC_out_fu_sel;
    logic [2:0]  DC_out_rob_idx;
    logic [1:0]  DC_out_LQ_tail;
    logic [1:0]  DC_out_SQ_tail;
    logic        DC_out_jump;
    logic        DC_valid;
    logic        dispatch_ready;
    
    // IS stage output (RR = Register Read)
    logic        IS_valid;
    logic        RR_ready;
    logic [2:0]  IS_out_rob_idx;
    logic [31:0] RR_out_pc;
    logic [31:0] RR_out_inst;
    logic [31:0] RR_out_imm;
    logic [31:0] RR_out_rs1_data;
    logic [31:0] RR_out_rs2_data;
    logic [4:0]  RR_out_op;
    logic [2:0]  RR_out_f3;
    logic [6:0]  RR_out_f7;
    logic [2:0]  RR_out_fu_sel;
    logic [1:0]  RR_out_ld_idx;
    logic [1:0]  RR_out_st_idx;
    logic [2:0]  RR_out_rob_idx;
    logic [6:0]  RR_out_rd;
    logic        RR_out_jump;
    logic        RR_valid;
    
    // Rename stage wires
    logic [6:0]  P_rs1;
    logic [6:0]  P_rs2;
    logic [6:0]  P_rd_new;
    logic [6:0]  P_rd_old;
    logic [5:0]  A_rs1;
    logic [5:0]  A_rs2;
    logic [5:0]  A_rd;
    logic        allocate_rd;
    logic        DC_P_rs1_valid;
    logic        DC_P_rs2_valid;
    
    // ROB wires
    logic        rob_ready;
    logic [31:0] DC_pc;
    logic [31:0] DC_inst;
    logic [6:0]  DC_P_rd_old;
    logic [6:0]  DC_P_rd_new;
    logic [2:0]  DC_fu_sel;
    logic        decode_valid;
    logic [2:0]  DC_rob_idx;

    // EX forwarding 
    logic [31:0] EX_out_data;
    logic [2:0]  EX_out_rob_idx; 
    logic        EX_out_valid;
    logic [6:0]  EX_out_rd;

    // Write back wires
    logic [31:0] WB_out_data;
    logic [2:0]  WB_out_rob_idx;
    logic        WB_out_valid;
    logic [6:0]  WB_out_rd;
    logic        writeback_free;
    
    // Mispredict/flush wires
    logic [31:0] jb_pc;
    logic        mispredict;
    logic [2:0]  mis_rob_idx;
    logic [7:0]  flush_mask;
    logic        stall;
    logic        recovery;
    
    // LSU wires
    logic        ld_i_valid;
    logic        st_i_valid;
    logic [2:0]  lsu_i_rob_idx;
    logic [31:0] lsu_i_rs1_data;
    logic [31:0] lsu_i_rs2_data;
    logic [31:0] lsu_i_imm;
    logic        ld_o_valid;
    logic [2:0]  ld_o_rob_idx;
    logic [6:0]  ld_o_rd;
    logic [31:0] ld_o_data;
    logic [1:0]  LQ_tail;
    logic [1:0]  SQ_tail;
    logic [1:0]  EX_ld_idx;
    logic [1:0]  EX_st_idx;
    logic        ld_ready;
    logic        st_ready;
    logic        ld_commit;
    logic        st_commit;
    logic [1:0]  mis_ld_idx;
    logic [1:0]  mis_st_idx;
    
    // Commit wires
    logic        commit_wb_en;
    logic [6:0]  commit_P_rd_new;
    logic [6:0]  commit_P_rd_old;
    logic [5:0]  commit_A_rd;
    logic [31:0] commit_data;
    logic [31:0] commit_pc;
    logic [31:0] commit_inst;
    logic        commit;
    logic [2:0]  commit_rob_idx;

    // BPU 
    logic        is_jb;
    logic [31:0] next_pc;
    logic        jump_out;

    // rollback
    logic        rollback_en_0;
    logic [5:0]  rollback_A_rd_0;
    logic [6:0]  rollback_P_rd_old_0;
    logic [6:0]  rollback_P_rd_new_0;
    logic        rollback_en_1;
    logic [5:0]  rollback_A_rd_1;
    logic [6:0]  rollback_P_rd_old_1;
    logic [6:0]  rollback_P_rd_new_1;
    
    // Handshake signals
    logic        DC_ready;
    logic        IS_ready;
    logic [7:0]  EX_ready;

    // ===========================
    // === Module Instiantiate ===   
    // ===========================

    IF_stage IF (
        .clk(clk),
        .rst(rst),
        // BPU
        .next_pc(next_pc),
        .next_jump(next_jump),
        // From IM
        .IM_r_data(IM_r_data),
        // From IS stage
        .mispredict(mispredict),
        .stall(stall),
        // From EXE stage
        .jb_pc(jb_pc),
        // To IM
        .IM_r_addr(IM_r_addr),
        .IM_ready(IM_ready),
        // To DC stage
        .IF_out_pc(IF_out_pc),
        .IF_out_inst(IF_out_inst),
        .IF_out_jump(IF_out_jump),
        // Handshake signals
        .IF_valid(IF_valid),
        .DC_ready(DC_ready)
    );

    DC_stage DC (
        .clk(clk),
        .rst(rst),
        // IF stage
        .DC_in_pc(IF_out_pc),
        .DC_in_inst(IF_out_inst),
        .DC_in_jump(IF_out_jump),
        // rename
        .P_rs1(P_rs1),
        .P_rs2(P_rs2),
        .P_rd_new(P_rd_new),
        .P_rd_old(P_rd_old),
        .A_rs1(A_rs1),
        .A_rs2(A_rs2),
        .A_rd(A_rd),
        .allocate_rd(allocate_rd),
        // ROB
        .rob_ready(rob_ready),
        .DC_rob_idx(DC_rob_idx),
        .DC_pc(DC_pc),
        .DC_inst(DC_inst),
        .DC_P_rd_old(DC_P_rd_old),
        .DC_P_rd_new(DC_P_rd_new),
        .DC_fu_sel(DC_fu_sel),
        .decode_valid(decode_valid),
        .dispatch_ready(dispatch_ready),
        // IS stage
        .DC_out_pc(DC_out_pc),
        .DC_out_inst(DC_out_inst),
        .DC_out_imm(DC_out_imm),
        .DC_out_op(DC_out_op),
        .DC_out_f3(DC_out_f3),
        .DC_out_f7(DC_out_f7),
        .DC_out_P_rs1(DC_out_P_rs1),
        .DC_out_P_rs2(DC_out_P_rs2),
        .DC_out_P_rd(DC_out_P_rd),
        .DC_out_fu_sel(DC_out_fu_sel),
        .DC_out_LQ_tail(DC_out_LQ_tail),
        .DC_out_SQ_tail(DC_out_SQ_tail),
        .DC_out_rob_idx(DC_out_rob_idx),
        .DC_out_jump(DC_out_jump),
        // mispredict
        .mispredict(mispredict),
        .stall(stall),
        // LSU
        .LQ_tail(LQ_tail),
        .SQ_tail(SQ_tail),
        .ld_ready(ld_ready),
        .st_ready(st_ready),
        // Handshake signals
        .DC_ready(DC_ready),
        .IF_valid(IF_valid),
        .DC_valid(DC_valid),
        .IS_ready(IS_ready)
    );

    IS_stage IS (
        .clk(clk),
        .rst(rst),
        // DC stage
        .dispatch_ready(dispatch_ready),
        .IS_in_pc(DC_out_pc),
        .IS_in_inst(DC_out_inst),
        .IS_in_imm(DC_out_imm),
        .IS_in_op(DC_out_op),
        .IS_in_f3(DC_out_f3),
        .IS_in_f7(DC_out_f7),
        .IS_in_rs1(DC_out_P_rs1),
        .IS_in_rs2(DC_out_P_rs2),
        .IS_in_rd(DC_out_P_rd),
        .IS_in_fu_sel(DC_out_fu_sel),
        .IS_in_rob_idx(DC_out_rob_idx),        
        .IS_in_LQ_tail(DC_out_LQ_tail),
        .IS_in_SQ_tail(DC_out_SQ_tail),
        .IS_in_jump(DC_out_jump),
        // rename
        .IS_in_rs1_valid(DC_P_rs1_valid),
        .IS_in_rs2_valid(DC_P_rs2_valid),
        // EXE
        .RR_out_pc(RR_out_pc),
        .RR_out_inst(RR_out_inst), 
        .RR_out_imm(RR_out_imm),
        .RR_out_rs1_data(RR_out_rs1_data),
        .RR_out_rs2_data(RR_out_rs2_data),
        .RR_out_op(RR_out_op),    
        .RR_out_f3(RR_out_f3),
        .RR_out_f7(RR_out_f7),
        .RR_out_fu_sel(RR_out_fu_sel),
        .RR_out_ld_idx(RR_out_ld_idx),
        .RR_out_st_idx(RR_out_st_idx),
        .RR_out_rob_idx(RR_out_rob_idx),
        .RR_out_rd(RR_out_rd),
        .RR_out_jump(RR_out_jump),
        // EX forwarding
        .EX_in_data(EX_out_data),
        .EX_in_valid(EX_out_valid),
        .EX_in_rd(EX_out_rd),
        // write back
        .WB_valid(WB_out_valid),
        .WB_data(WB_out_data),
        .WB_rd(WB_out_rd),
        .writeback_free(writeback_free),
        // mispredict
        .mispredict(mispredict),
        .stall(stall),
        .flush_mask(flush_mask),
        // Handshake signals
        .IS_ready(IS_ready),
        .DC_valid(DC_valid),
        .RR_valid(RR_valid),
        .EX_ready(EX_ready),
        // konata
        .IS_valid(IS_valid),
        .RR_ready(RR_ready),
        .IS_out_rob_idx(IS_out_rob_idx)
    );

    EXE_stage EXE (
        .clk(clk),
        .rst(rst),
        // IS stage
        .EXE_in_fu_sel(RR_out_fu_sel),
        .EXE_in_inst(RR_out_inst),
        .EXE_in_rs1_data(RR_out_rs1_data),
        .EXE_in_rs2_data(RR_out_rs2_data),
        .EXE_in_imm(RR_out_imm),
        .EXE_in_pc(RR_out_pc),
        .EXE_in_rd(RR_out_rd),
        .EXE_in_op(RR_out_op),    
        .EXE_in_f3(RR_out_f3),
        .EXE_in_f7(RR_out_f7),
        .EXE_in_rob_idx(RR_out_rob_idx),
        .EXE_in_jump(RR_out_jump),
        // LSU
        .ld_i_valid(ld_i_valid),
        .st_i_valid(st_i_valid),
        .lsu_i_rob_idx(lsu_i_rob_idx),
        .lsu_i_rs1_data(lsu_i_rs1_data),
        .lsu_i_rs2_data(lsu_i_rs2_data),
        .lsu_i_imm(lsu_i_imm),
        .ld_o_valid(ld_o_valid),
        .ld_o_rob_idx(ld_o_rob_idx),
        .ld_o_rd(ld_o_rd),
        .ld_o_data(ld_o_data),
        // mispredict
        .DC_in_jump(IF_out_jump),
        .IF_valid(IF_valid),
        .DC_ready(DC_ready),
        .is_jb(is_jb),
        .jb_pc(jb_pc),  
        .mispredict(mispredict), 
        .mis_rob_idx(mis_rob_idx),
        // EX forwarding
        .EX_out_data(EX_out_data),
        .EX_out_rob_idx(EX_out_rob_idx),
        .EX_out_valid(EX_out_valid),
        .EX_out_rd(EX_out_rd),
        // write back
        .WB_out_data(WB_out_data),
        .WB_out_rob_idx(WB_out_rob_idx),
        .WB_out_valid(WB_out_valid),
        .WB_out_rd(WB_out_rd),
        // Handshake signals
        .RR_valid(RR_valid),
        .EX_ready(EX_ready)
    );

    LSU LSU (
        .clk(clk),
        .rst(rst),
        // From DC stage
        .DC_fu_sel(DC_fu_sel),
        .DC_rd(DC_P_rd_new),
        .DC_rob_idx(DC_rob_idx),
        .decode_valid(IF_valid && dispatch_ready),
        // EX stage
        .ld_i_valid(ld_i_valid),
        .st_i_valid(st_i_valid),
        .lsu_i_rob_idx(lsu_i_rob_idx),
        .lsu_i_rs1_data(lsu_i_rs1_data),
        .lsu_i_rs2_data(lsu_i_rs2_data),
        .lsu_i_imm(lsu_i_imm),
        .RR_valid(RR_valid),
        .EX_ld_idx(RR_out_ld_idx),
        .EX_st_idx(RR_out_st_idx),
        .ld_o_rd(ld_o_rd),
        .ld_o_data(ld_o_data),
        .ld_o_rob_idx(ld_o_rob_idx),
        .ld_o_valid(ld_o_valid),
        // From Commit
        .ld_commit(ld_commit), // commit LQ head
        .st_commit(st_commit), // commit SQ head
        // mispredict
        .mispredict(mispredict),
        .flush_mask(flush_mask),
        .mis_ld_idx(RR_out_ld_idx),
        .mis_st_idx(RR_out_st_idx),
        // DM
        .DM_rd_data(DM_rd_data),
        .DM_c_en(DM_c_en),
        .DM_r_en(DM_r_en),     
        .DM_w_en(DM_w_en),
        .DM_addr(DM_addr),
        .DM_w_data(DM_w_data),
        // To ROB
        .LQ_tail(LQ_tail),
        .SQ_tail(SQ_tail),
        // DC - LSU handshake
        .ld_ready(ld_ready),
        .st_ready(st_ready)
    );

    Rename rename (
        .clk(clk),
        .rst(rst),
        // Rename 
        .A_rs1(A_rs1),
        .A_rs2(A_rs2),
        .A_rd(A_rd),
        .allocate_rd(allocate_rd && IF_valid && dispatch_ready),
        .P_rs1(P_rs1),
        .P_rs2(P_rs2),
        .P_rd_new(P_rd_new),
        .P_rd_old(P_rd_old),
        // Dispatch
        .DC_op(DC_out_op),
        .DC_rs1(DC_out_P_rs1),
        .DC_rs2(DC_out_P_rs2),
        .DC_P_rs1_valid(DC_P_rs1_valid),
        .DC_P_rs2_valid(DC_P_rs2_valid),
        // Write Back
        .WB_valid(WB_out_valid),
        .WB_rd(WB_out_rd),
        // Commit
        .commit_wb_en(commit_wb_en),
        .commit_P_rd_new(commit_P_rd_new),
        .commit_P_rd_old(commit_P_rd_old),
        .commit_A_rd(commit_A_rd),
        // recovery
        .recovery(recovery),
        // rollback
        .rollback_en_0(rollback_en_0),
        .rollback_A_rd_0(rollback_A_rd_0),
        .rollback_P_rd_old_0(rollback_P_rd_old_0),
        .rollback_P_rd_new_0(rollback_P_rd_new_0),
        .rollback_en_1(rollback_en_1),
        .rollback_A_rd_1(rollback_A_rd_1),
        .rollback_P_rd_old_1(rollback_P_rd_old_1),
        .rollback_P_rd_new_1(rollback_P_rd_new_1)
    );
    

    ROB ROB_inst (
        .clk(clk),
        .rst(rst),
        // Dispatch
        .DC_valid(IF_valid && dispatch_ready),
        .DC_pc(DC_pc),
        .DC_inst(DC_inst),
        .DC_P_rd_new(DC_P_rd_new),
        .DC_P_rd_old(DC_P_rd_old),
        .DC_rob_idx(DC_rob_idx),
        .ROB_ready(rob_ready),
        // Issue/Register Read
        .RR_valid(RR_valid && EX_ready[RR_out_fu_sel]),
        .RR_rob_idx(RR_out_rob_idx),
        // Write Back
        .WB_valid(WB_out_valid),
        .WB_rob_idx(WB_out_rob_idx),
        .WB_data(WB_out_data),
        .writeback_free(writeback_free),
        // mispredict
        .mispredict(mispredict),
        .mis_rob_idx(mis_rob_idx),
        .flush_mask(flush_mask),
        // Commit
        .commit_wb_en(commit_wb_en),
        .commit_P_rd_old(commit_P_rd_old),
        .commit_P_rd_new(commit_P_rd_new),
        .commit_A_rd(commit_A_rd),
        .commit_data(commit_data),
        .commit_pc(commit_pc),
        .commit_inst(commit_inst),
        .ld_commit(ld_commit),
        .st_commit(st_commit),
        // recovery
        .stall(stall),
        .recovery(recovery),
        // rollback
        .rollback_en_0(rollback_en_0),
        .rollback_A_rd_0(rollback_A_rd_0),
        .rollback_P_rd_old_0(rollback_P_rd_old_0),
        .rollback_P_rd_new_0(rollback_P_rd_new_0),
        .rollback_en_1(rollback_en_1),
        .rollback_A_rd_1(rollback_A_rd_1),
        .rollback_P_rd_old_1(rollback_P_rd_old_1),
        .rollback_P_rd_new_1(rollback_P_rd_new_1),
        // konata
        .commit(commit),
        .commit_rob_idx(commit_rob_idx)
    );

    // BPU
    BPU BPU (
        .clk(clk),
        .rst(rst),
        .IM_addr(IM_r_addr),
        .DC_ready(DC_ready),
        .RR_valid(RR_valid),
        .EX_ready(EX_ready[0]),
        .RR_out_pc(RR_out_pc),
        .mispredict(mispredict),
        .is_jb(is_jb),
        .jb_pc(jb_pc),
        .jump_out(next_jump),
        .next_pc(next_pc)
    );

    // synopsys translate_off
    konata k1(
        .clk(clk),
        .rst(rst),
        .IM_r_addr(IM_r_addr),
        .IF_valid(IF_valid),
        .DC_ready(DC_ready),
        .IF_out_pc(IF_out_pc),
        .IF_out_inst(IF_out_inst),
        .ROB_tail(DC_rob_idx),
        .DC_valid(DC_valid),
        .IS_ready(dispatch_ready),
        .DC_out_pc(DC_out_pc),
        .IS_valid(IS_valid),
        .RR_ready(RR_ready),
        .IS_out_rob_idx(IS_out_rob_idx),
        .RR_valid(RR_valid),
        .EX_ready(EX_ready[RR_out_fu_sel]),
        .RR_out_rob_idx(RR_out_rob_idx),
        .RR_out_pc(RR_out_pc),
        .EX_valid(WB_out_valid),
        .EX_out_rob_idx(WB_out_rob_idx),
        .commit(commit),
        .commit_rob_idx(commit_rob_idx),
        .mispredict(mispredict),
        .flush_mask(flush_mask),
        .jb_pc(jb_pc)
    );
    
    commit_tracker ct1(
        .clk(clk),
        .rst(rst),
        .commit_valid(commit),
        .commit_pc(commit_pc),
        .commit_inst(commit_inst),
        .commit_Ard(commit_A_rd),
        .commit_data(commit_data)
    );
    // synopsys translate_on
endmodule