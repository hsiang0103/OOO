`include "CPU/IF_stage.sv"
`include "CPU/DC_stage.sv"
`include "CPU/IS_stage.sv"
`include "CPU/EXE_stage.sv"
`include "CPU/RegFile.sv"
`include "CPU/LSU.sv"
`include "CPU/ALU.sv"
`include "CPU/FALU.sv"
`include "CPU/MUL.sv"
`include "CPU/DIV.sv"
`include "CPU/div_func.sv"
`include "CPU/CSR.sv"
`include "CPU/Rename.sv"
`include "CPU/ROB.sv"
`include "CPU/BPU.sv"

module CPU (
    input   logic           clk,
    input   logic           rst,
    // interrupt
    input   logic           WDT_interrupt,
    input   logic           DMA_interrupt,
    // IM 
    input   logic [31:0]    fetch_data,
    input   logic           fetch_data_valid,
    input   logic           fetch_req_ready,
    output  logic [31:0]    fetch_addr,
    output  logic           fetch_req_valid,
    // DM
    output  logic [31:0]    ld_st_req_addr,
    input   logic           store_data_valid,
    output  logic [3:0]     store_strb,
    output  logic [31:0]    store_data,
    output  logic           store_req_valid,
    input   logic           store_req_ready,
    input   logic           load_data_valid,
    input   logic [31:0]    load_data,
    output  logic           load_req_valid,
    input   logic           load_req_ready
    // --------------------------------------------
    //            Connect with Debuger              
    // --------------------------------------------
    `ifdef ENABLE_DEBUG_PORTS
    ,
    output logic        debug_fetch_req_valid,
    output logic        debug_fetch_req_ready,
    output logic [31:0] debug_fetch_addr,
    output logic        debug_IF_valid,
    output logic        debug_DC_ready,
    output logic [31:0] debug_IF_out_pc,
    output logic [31:0] debug_IF_out_inst,
    output logic [$clog2(`ROB_LEN)-1:0] debug_DC_rob_idx,
    output logic        debug_DC_valid,
    output logic        debug_dispatch_valid,
    output logic [31:0] debug_DC_out_pc,
    output logic        debug_IS_valid,
    output logic        debug_RR_ready,
    output logic [$clog2(`ROB_LEN)-1:0] debug_IS_out_rob_idx,
    output logic        debug_RR_valid,
    output logic        debug_EX_ready_selected,
    output logic [$clog2(`ROB_LEN)-1:0] debug_RR_out_rob_idx,
    output logic [31:0] debug_RR_out_pc,
    output logic        debug_WB_out_valid,
    output logic [$clog2(`ROB_LEN)-1:0] debug_WB_out_rob_idx,
    output logic        debug_commit,
    output logic [$clog2(`ROB_LEN)-1:0] debug_commit_rob_idx,
    output logic        debug_mispredict,
    output logic [`ROB_LEN-1:0] debug_flush_mask,
    output logic [31:0] debug_commit_pc,
    output logic [31:0] debug_commit_inst,
    output logic [5:0]  debug_commit_A_rd,
    output logic [31:0] debug_commit_data,
    output logic        debug_st_commit,
    output logic [31:0] debug_st_addr,
    output logic [31:0] debug_st_data
    `endif
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
    logic [$clog2(`ROB_LEN)-1:0]  DC_out_rob_idx;
    logic [$clog2(`LQ_LEN):0]  DC_out_LQ_tail;
    logic [$clog2(`SQ_LEN):0]  DC_out_SQ_tail;
    logic        DC_out_jump;
    logic        DC_valid;
    logic        dispatch_ready;
    logic        dispatch_valid;
    
    // IS stage output (RR = Register Read)
    logic        IS_valid;
    logic        RR_ready;
    logic [$clog2(`ROB_LEN)-1:0]  IS_out_rob_idx;
    logic [31:0] RR_out_pc;
    logic [31:0] RR_out_inst;
    logic [31:0] RR_out_imm;
    logic [31:0] RR_out_rs1_data;
    logic [31:0] RR_out_rs2_data;
    logic [4:0]  RR_out_op;
    logic [2:0]  RR_out_f3;
    logic [6:0]  RR_out_f7;
    logic [2:0]  RR_out_fu_sel;
    logic [$clog2(`LQ_LEN):0]  RR_out_ld_idx;
    logic [$clog2(`SQ_LEN):0]  RR_out_st_idx;
    logic [$clog2(`ROB_LEN)-1:0]  RR_out_rob_idx;
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
    logic        rob_empty;
    logic [31:0] DC_pc;
    logic [31:0] DC_inst;
    logic [6:0]  DC_P_rd_old;
    logic [6:0]  DC_P_rd_new;
    logic [2:0]  DC_fu_sel;
    logic [$clog2(`ROB_LEN)-1:0]  DC_rob_idx;

    // EX forwarding 
    logic [31:0] EX_out_data;
    logic [$clog2(`ROB_LEN)-1:0]  EX_out_rob_idx; 
    logic        EX_out_valid;
    logic [6:0]  EX_out_rd;

    // Write back wires
    logic [31:0] WB_out_data;
    logic [$clog2(`ROB_LEN)-1:0]  WB_out_rob_idx;
    logic        WB_out_valid;
    logic [6:0]  WB_out_rd;
    logic        writeback_free;
    
    // Mispredict/flush wires
    logic [31:0] jb_pc;
    logic        mispredict;
    logic [$clog2(`ROB_LEN)-1:0]  mis_rob_idx;
    logic [`ROB_LEN-1:0]  flush_mask;
    logic        stall;
    logic        recovery;
    
    // LSU wires
    logic [4:0]  DC_op;
    logic        ld_i_valid;
    logic        st_i_valid;
    logic [$clog2(`ROB_LEN)-1:0]  lsu_i_rob_idx;
    logic [31:0] lsu_i_rs1_data;
    logic [31:0] lsu_i_rs2_data;
    logic [31:0] lsu_i_imm;
    logic        ld_o_valid;
    logic [$clog2(`ROB_LEN)-1:0]  ld_o_rob_idx;
    logic [6:0]  ld_o_rd;
    logic [31:0] ld_o_data;
    logic [$clog2(`LQ_LEN):0]  LQ_tail;
    logic [$clog2(`SQ_LEN):0]  SQ_tail;
    logic [$clog2(`LQ_LEN):0]  EX_ld_idx;
    logic [$clog2(`SQ_LEN):0]  EX_st_idx;
    logic        ld_ready;
    logic        st_ready;
    logic        ld_commit;
    logic        st_commit;
    logic [31:0] st_addr;
    logic [31:0] st_data;
    logic [$clog2(`LQ_LEN):0]  mis_ld_idx;
    logic [$clog2(`SQ_LEN):0]  mis_st_idx;
    
    // Commit wires
    logic        commit_wb_en;
    logic [6:0]  commit_P_rd_new;
    logic [6:0]  commit_P_rd_old;
    logic [5:0]  commit_A_rd;
    logic [31:0] commit_data;
    logic [31:0] commit_pc;
    logic [31:0] commit_inst;
    logic        commit;
    logic [$clog2(`ROB_LEN)-1:0]  commit_rob_idx;

    // BPU 
    logic        is_jb;
    logic [31:0] next_pc;
    logic        next_jump;
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

    // interrupt
    logic        waiting_wfi;
    logic        wakeup_wfi;

    // ===========================
    // === Module Instiantiate ===   
    // ===========================

    IF_stage IF (
        .clk(clk),
        .rst(rst),
        // BPU
        .next_pc(next_pc),
        .next_jump(next_jump),
        // IM
        .fetch_data(fetch_data),
        .fetch_data_valid(fetch_data_valid),
        .fetch_req_ready(fetch_req_ready),   
        .fetch_addr(fetch_addr),
        .fetch_req_valid(fetch_req_valid),
        // EXE stage
        .jb_pc(jb_pc),
        .mispredict(mispredict),
        // To DC stage
        .IF_valid(IF_valid),
        .IF_out_pc(IF_out_pc),
        .IF_out_inst(IF_out_inst),
        .IF_out_jump(IF_out_jump),        
        .DC_ready(DC_ready)
    );

    DC_stage DC (
        .clk(clk),
        .rst(rst),
        // IF stage
        .IF_valid(IF_valid),
        .DC_in_pc(IF_out_pc),
        .DC_in_inst(IF_out_inst),
        .DC_in_jump(IF_out_jump),
        .DC_ready(DC_ready),
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
        .rob_empty(rob_empty),
        .DC_rob_idx(DC_rob_idx),
        .DC_pc(DC_pc),
        .DC_inst(DC_inst),
        .DC_op(DC_op),
        .DC_P_rd_old(DC_P_rd_old),
        .DC_P_rd_new(DC_P_rd_new),
        .DC_fu_sel(DC_fu_sel),
        .dispatch_valid(dispatch_valid),
        // IS stage
        .IS_ready(IS_ready),
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
        .DC_valid(DC_valid),
        // mispredict
        .mispredict(mispredict),
        .stall(stall),
        // LSU
        .LQ_tail(LQ_tail),
        .SQ_tail(SQ_tail),
        .ld_ready(ld_ready),
        .st_ready(st_ready),
        // wakeup wfi
        .waiting_wfi(waiting_wfi),
        .wakeup_wfi(wakeup_wfi)
    );

    IS_stage IS (
        .clk(clk),
        .rst(rst),
        // DC stage
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
        .flush_mask(flush_mask),
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
        .EX_ready(EX_ready),
        // interrupt
        .DC_in_pc(IF_out_pc),
        .waiting_wfi(waiting_wfi),
        .WDT_interrupt(WDT_interrupt),
        .DMA_interrupt(DMA_interrupt),
        .wakeup_wfi(wakeup_wfi)
    );

    LSU LSU (
        .clk(clk),
        .rst(rst),
        // dispatch
        .DC_fu_sel(DC_fu_sel),
        .DC_rd(DC_P_rd_new),
        .DC_op(DC_op),
        .DC_rob_idx(DC_rob_idx),
        .decode_valid(dispatch_valid),
        .ld_ready(ld_ready),
        .st_ready(st_ready),
        // data
        .lsu_i_rs1_data(lsu_i_rs1_data),
        .lsu_i_rs2_data(lsu_i_rs2_data),
        .lsu_i_imm(lsu_i_imm),
        .funct3(RR_out_f3),
        // control
        .ld_i_valid(ld_i_valid),
        .st_i_valid(st_i_valid),
        .lsu_i_rob_idx(lsu_i_rob_idx),
        .EX_ld_idx(RR_out_ld_idx),
        .EX_st_idx(RR_out_st_idx),
        .ld_o_valid(ld_o_valid),
        .ld_o_rob_idx(ld_o_rob_idx),
        .ld_o_rd(ld_o_rd),
        .ld_o_data(ld_o_data),
        // commit
        .ld_commit(ld_commit), 
        .st_commit(st_commit), 
        .st_addr(st_addr),
        .st_data(st_data),
        // mispredict
        .mispredict(mispredict),
        .flush_mask(flush_mask),
        .mis_ld_idx(RR_out_ld_idx),
        .mis_st_idx(RR_out_st_idx),
        // load/store interface
        .ld_st_req_addr(ld_st_req_addr),
        .store_data_valid(store_data_valid),
        .store_strb(store_strb),
        .store_data(store_data),
        .store_req_valid(store_req_valid),
        .store_req_ready(store_req_ready),
        .load_data_valid(load_data_valid),
        .load_data(load_data),
        .load_req_valid(load_req_valid),
        .load_req_ready(load_req_ready),
        // interrupt
        .waiting_wfi(waiting_wfi),
        // ROB
        .LQ_tail(LQ_tail),
        .SQ_tail(SQ_tail)
    );

    Rename rename (
        .clk(clk),
        .rst(rst),
        // Rename 
        .A_rs1(A_rs1),
        .A_rs2(A_rs2),
        .A_rd(A_rd),
        .allocate_rd(allocate_rd && dispatch_valid),
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
        .DC_valid(dispatch_valid),
        .DC_pc(DC_pc),
        .DC_inst(DC_inst),
        .DC_P_rd_new(DC_P_rd_new),
        .DC_P_rd_old(DC_P_rd_old),
        .DC_A_rd(A_rd),
        .DC_rob_idx(DC_rob_idx),
        .ROB_ready(rob_ready),
        .ROB_empty(rob_empty),
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
        // interrupt
        .waiting_wfi(waiting_wfi),
        // konata
        .commit(commit),
        .commit_rob_idx(commit_rob_idx)
    );

    // BPU
    BPU BPU (
        .clk(clk),
        .rst(rst),
        .fetch_addr(fetch_addr),
        .RR_valid(RR_valid),
        .EX_ready(EX_ready[0]),
        .RR_out_pc(RR_out_pc),
        .mispredict(mispredict),
        .is_jb(is_jb),
        .jb_pc(jb_pc),
        .jump_out(next_jump),
        .next_pc(next_pc),
        .fetch_req_valid(fetch_req_valid),
        .fetch_req_ready(fetch_req_ready)
    );

    `ifdef ENABLE_DEBUG_PORTS
    assign debug_fetch_req_valid = fetch_req_valid;
    assign debug_fetch_req_ready = fetch_req_ready;
    assign debug_fetch_addr = fetch_addr;
    assign debug_IF_valid = IF_valid;
    assign debug_DC_ready = DC_ready;
    assign debug_IF_out_pc = IF_out_pc;
    assign debug_IF_out_inst = IF_out_inst;
    assign debug_DC_rob_idx = DC_rob_idx;
    assign debug_DC_valid = DC_valid;
    assign debug_dispatch_valid = dispatch_valid;
    assign debug_DC_out_pc = DC_out_pc;
    assign debug_IS_valid = IS_valid;
    assign debug_RR_ready = RR_ready;
    assign debug_IS_out_rob_idx = IS_out_rob_idx;
    assign debug_RR_valid = RR_valid;
    assign debug_EX_ready_selected = EX_ready[RR_out_fu_sel];
    assign debug_RR_out_rob_idx = RR_out_rob_idx;
    assign debug_RR_out_pc = RR_out_pc;
    assign debug_WB_out_valid = WB_out_valid;
    assign debug_WB_out_rob_idx = WB_out_rob_idx;
    assign debug_commit = commit;
    assign debug_commit_rob_idx = commit_rob_idx;
    assign debug_mispredict = mispredict;
    assign debug_flush_mask = flush_mask;
    assign debug_commit_pc = commit_pc;
    assign debug_commit_inst = commit_inst;
    assign debug_commit_A_rd = commit_A_rd;
    assign debug_commit_data = commit_data;
    assign debug_st_commit = st_commit;
    assign debug_st_addr = st_addr;
    assign debug_st_data = st_data;
    `endif

endmodule