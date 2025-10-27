module CPU (
    input logic clk,
    input logic rst,

    // IM 
    input  logic [31:0] IM_r_data,
    output logic [15:0] IM_r_addr,
    output logic        IM_ready,

    // DM
    input logic [31:0]  DM_rd_data,
    output logic        DM_c_en,
    output logic        DM_r_en,
    output logic [31:0] DM_w_en,
    output logic [15:0] DM_addr,
    output logic [31:0] DM_w_data
);
    // =========================
    // === Wire Instiantiate ===
    // =========================

    // IF stage output 
    logic [15:0] IF_out_pc;
    logic [31:0] IF_out_inst;
    logic        IF_valid;

    // DC stage output
    logic [15:0] DC_out_pc;
    logic [31:0] DC_out_inst;
    logic [31:0] DC_out_imm;
    logic [4:0]  DC_out_op;
    logic [2:0]  DC_out_f3;
    logic [6:0]  DC_out_f7;
    logic [6:0]  DC_out_rs1;
    logic [6:0]  DC_out_rs2;
    logic        DC_out_rs1_valid;
    logic        DC_out_rs2_valid;
    logic [6:0]  DC_out_P_rd_new;
    logic [6:0]  DC_out_P_rd_old;
    logic [5:0]  DC_out_A_rd;
    logic [2:0]  DC_out_fu_sel;
    logic        DC_valid;
    logic        DC_ready;

    // IS stage output
    logic [6:0]  commit_P_rd_old;
    logic [6:0]  commit_P_rd_new;
    logic [5:0]  commit_A_rd;
    logic        commit_wb_en;
    logic        recovery;
    logic [15:0] IS_out_pc;
    logic [31:0] IS_out_inst;
    logic [31:0] IS_out_imm;
    logic [31:0] IS_out_rs1_data;
    logic [31:0] IS_out_rs2_data;
    logic [4:0]  IS_out_op;
    logic [2:0]  IS_out_f3;
    logic [6:0]  IS_out_f7;
    logic [6:0]  IS_out_rs1;
    logic [6:0]  IS_out_rs2;
    logic [2:0]  IS_out_fu_sel;
    logic [1:0]  IS_out_ld_idx;
    logic [1:0]  IS_out_st_idx;
    logic [2:0]  IS_out_rob_idx;
    logic        ld_commit;
    logic        st_commit;
    logic        IS_valid;
    logic        IS_ready;

    logic [2:0]  ROB_tail;
    logic        commit;
    logic [2:0]  commit_rob_idx;


    // EXE stage output
    logic [15:0] jb_pc;          // JB output
    logic        mispredict;
    logic [2:0]  mis_rob_idx;
    logic        lsu_o_ready;
    logic [31:0] WB_out_data;
    logic [2:0]  WB_out_rob_idx;
    logic        WB_out_valid;
    logic [4:0]  EXE_ready;

    // LSU output
    logic [1:0]  IS_in_ld_idx;
    logic [1:0]  IS_in_st_idx;
    logic [31:0] lsu_ld_data;
    logic [2:0]  lsu_rob_idx;
    logic        lsu_o_valid;
    logic        ld_ready;
    logic        st_ready;
    
    // ===========================
    // === Module Instiantiate ===  
    // ===========================

    IF_stage IF (
        .clk(clk),
        .rst(rst),
        // From IM
        .IM_r_data(IM_r_data),
        // From IS stage
        .mispredict(mispredict),
        // From EXE stage
        .jb_pc(jb_pc),
        // To IM
        .IM_r_addr(IM_r_addr),
        .IM_ready(IM_ready),
        // To DC stage
        .IF_out_pc(IF_out_pc),
        .IF_out_inst(IF_out_inst),
        // Handshake signals
        .IF_valid(IF_valid),
        .DC_ready(DC_ready)
    );

    DC_stage DC (
        .clk(clk),
        .rst(rst),
        // From IF stage
        .DC_in_pc(IF_out_pc),
        .DC_in_inst(IF_out_inst),
        // From IS stage
        .commit_P_rd_old(commit_P_rd_old),
        .commit_P_rd_new(commit_P_rd_new),
        .commit_A_rd(commit_A_rd),
        .commit_wb_en(commit_wb_en),
        .recovery(recovery),
        // From EXE stage
        .mispredict(mispredict),
        // From LSU
        .ld_ready(ld_ready),
        .st_ready(st_ready),
        // To IS stage
        .DC_out_pc(DC_out_pc),
        .DC_out_inst(DC_out_inst),
        .DC_out_imm(DC_out_imm),
        .DC_out_op(DC_out_op),
        .DC_out_f3(DC_out_f3),
        .DC_out_f7(DC_out_f7),
        .DC_out_rs1(DC_out_rs1),
        .DC_out_rs2(DC_out_rs2),
        .DC_out_rs1_valid(DC_out_rs1_valid),
        .DC_out_rs2_valid(DC_out_rs2_valid),
        .DC_out_P_rd_new(DC_out_P_rd_new),
        .DC_out_P_rd_old(DC_out_P_rd_old),
        .DC_out_A_rd(DC_out_A_rd),
        .DC_out_fu_sel(DC_out_fu_sel),
        // Handshake signals
        .DC_ready(DC_ready),
        .IF_valid(IF_valid),
        .DC_valid(DC_valid),
        .IS_ready(IS_ready)
    );

    IS_stage IS (
        .clk(clk),
        .rst(rst),
        // From DC stage
        .IS_in_pc(DC_out_pc),
        .IS_in_inst(DC_out_inst),
        .IS_in_imm(DC_out_imm),
        .IS_in_op(DC_out_op),
        .IS_in_f3(DC_out_f3),
        .IS_in_f7(DC_out_f7),
        .IS_in_rs1(DC_out_rs1),
        .IS_in_rs2(DC_out_rs2),
        .IS_in_rs1_valid(DC_out_rs1_valid),
        .IS_in_rs2_valid(DC_out_rs2_valid),
        .IS_in_P_rd_new(DC_out_P_rd_new),
        .IS_in_P_rd_old(DC_out_P_rd_old),
        .IS_in_A_rd(DC_out_A_rd),
        .IS_in_fu_sel(DC_out_fu_sel),
        // From EXE
        .mispredict(mispredict),
        .mis_rob_idx(mis_rob_idx),
        // From LSU
        .IS_in_ld_idx(IS_in_ld_idx),
        .IS_in_st_idx(IS_in_st_idx),
        // From WB stage
        .WB_valid(WB_out_valid),
        .WB_data(WB_out_data),
        .WB_rob_idx(WB_out_rob_idx),
        // To DC stage
        .commit_wb_en(commit_wb_en),
        .commit_P_rd_old(commit_P_rd_old),
        .commit_P_rd_new(commit_P_rd_new),
        .commit_A_rd(commit_A_rd),
        .recovery(recovery),
        // To EXE stage
        .IS_out_pc(IS_out_pc),
        .IS_out_inst(IS_out_inst),
        .IS_out_rs1_data(IS_out_rs1_data),
        .IS_out_rs2_data(IS_out_rs2_data),
        .IS_out_imm(IS_out_imm),
        .IS_out_op(IS_out_op),
        .IS_out_f3(IS_out_f3),
        .IS_out_f7(IS_out_f7),
        .IS_out_fu_sel(IS_out_fu_sel),
        .IS_out_ld_idx(IS_out_ld_idx),
        .IS_out_st_idx(IS_out_st_idx),
        .IS_out_rob_idx(IS_out_rob_idx),
        // To LSU
        .ld_commit(ld_commit),
        .st_commit(st_commit),
        // Handshake signals
        .IS_ready(IS_ready),
        .DC_valid(DC_valid),
        .IS_valid(IS_valid),
        .EXE_ready(EXE_ready),
        // konata signal
        .ROB_tail(ROB_tail),
        .commit(commit),
        .commit_rob_idx(commit_rob_idx)
    );

    EXE_stage EXE (
        .clk(clk),
        .rst(rst),
        // From IS stage
        .EXE_in_fu_sel(IS_out_fu_sel),
        .EXE_in_inst(IS_out_inst),
        .EXE_in_rs1_data(IS_out_rs1_data),
        .EXE_in_rs2_data(IS_out_rs2_data),
        .EXE_in_imm(IS_out_imm),
        .EXE_in_pc(IS_out_pc),
        .EXE_in_op(IS_out_op),    
        .EXE_in_f3(IS_out_f3),
        .EXE_in_f7(IS_out_f7),
        .EXE_in_rob_idx(IS_out_rob_idx),
        // From LSU
        .lsu_ld_data(lsu_ld_data),
        .lsu_o_valid(lsu_o_valid),
        .lsu_rob_idx(lsu_rob_idx),
        // TO IF stage
        .EXE_out_jb_pc(jb_pc),  
        .mispredict(mispredict), 
        .mis_rob_idx(mis_rob_idx),
        // TO LSU       
        .lsu_o_ready(lsu_o_ready),
        // To WB stage
        .WB_out_data(WB_out_data),
        .WB_out_rob_idx(WB_out_rob_idx),
        .WB_out_valid(WB_out_valid),
        // Handshake signals
        .IS_valid(IS_valid),
        .EXE_ready(EXE_ready)
    );

    LSU LSU (
        .clk(clk),
        .rst(rst),
        // From DC stage
        .DC_out_op(DC_out_op),
        .DC_valid(DC_valid),
        // From IS stage
        .IS_ready(IS_ready),
        .LSU_in_op(IS_out_op),
        .LSU_in_ld_idx(IS_out_ld_idx),
        .LSU_in_st_idx(IS_out_st_idx), 
        .LSU_in_rs1_data(IS_out_rs1_data),
        .LSU_in_rs2_data(IS_out_rs2_data),
        .LSU_in_imm(IS_out_imm),
        .LSU_in_rob_idx(IS_out_rob_idx),   
        .IS_valid(IS_valid),
        // From EXE stage     
        .lsu_o_ready(lsu_o_ready),
        .mispredict(mispredict),
        .EXE_in_ld_idx(IS_out_ld_idx),
        .EXE_in_st_idx(IS_out_st_idx),
        // From Commit
        .ld_commit(ld_commit), // commit LQ head
        .st_commit(st_commit), // commit SQ head
        // From DM
        .DM_rd_data(DM_rd_data),
        // To DM
        .DM_c_en(DM_c_en),
        .DM_r_en(DM_r_en),     
        .DM_w_en(DM_w_en),
        .DM_addr(DM_addr),
        .DM_w_data(DM_w_data),
        // To ROB
        .ld_idx(IS_in_ld_idx),
        .st_idx(IS_in_st_idx),
        // To EXE stage
        .lsu_ld_data(lsu_ld_data),
        .lsu_rob_idx(lsu_rob_idx),
        .lsu_o_valid(lsu_o_valid),
        // DC - LSU handshake
        .ld_ready(ld_ready),
        .st_ready(st_ready)
    );


    // synopsys translate_off
    konata k1(
        .clk(clk),
        .rst(rst),
        
        // IF stage
        .IM_r_addr(IM_r_addr),
        .IF_valid(IF_valid),
        .IF_out_pc(IF_out_pc),
        .IF_out_inst(IF_out_inst),
        
        // DC stage
        .DC_valid(DC_valid),
        .DC_ready(DC_ready),
        .DC_out_pc(DC_out_pc),
        .DC_out_inst(DC_out_inst),
        
        // IS stage
        .ROB_tail(ROB_tail),
        .IS_valid(IS_valid),
        .IS_ready(IS_ready),
        .IS_out_pc(IS_out_pc),
        .IS_out_inst(IS_out_inst),
        .IS_out_rob_idx(IS_out_rob_idx),
        
        // EXE stage
        .EXE_ready(EXE_ready),
        .mispredict(mispredict),
        .mis_rob_idx(mis_rob_idx),
        
        // WB stage
        .WB_out_valid(WB_out_valid),
        .WB_out_rob_idx(WB_out_rob_idx),
        
        // Commit
        .commit(commit),
        .commit_rob_idx(commit_rob_idx),
        .recovery(recovery)
    );

    // synopsys translate_on
endmodule