module LSU (
    input logic clk,
    input logic rst,

    // From DC stage
    input logic [4:0]   DC_out_op,   
    input logic         DC_valid, 

    // From IS stage
    input logic         IS_ready,
    input logic [4:0]   LSU_in_op,
    input logic [1:0]   LSU_in_ld_idx,
    input logic [1:0]   LSU_in_st_idx, 
    input logic [31:0]  LSU_in_rs1_data,
    input logic [31:0]  LSU_in_rs2_data,
    input logic [31:0]  LSU_in_imm,
    input logic [2:0]   LSU_in_rob_idx,
    input logic         IS_valid,

    // From EXE stage
    input logic         lsu_o_ready,
    input logic         mispredict,
    input logic [1:0]   EXE_in_ld_idx,
    input logic [1:0]   EXE_in_st_idx,

    // From Commit
    input logic         ld_commit, // commit LQ head
    input logic         st_commit, // commit SQ head

    // From DM
    input logic [31:0]  DM_rd_data,
    
    // To DM
    output logic        DM_c_en,
    output logic        DM_r_en,
    output logic [31:0] DM_w_en,
    output logic [15:0] DM_addr,
    output logic [31:0] DM_w_data,

    // To ROB
    output logic [1:0]  ld_idx,
    output logic [1:0]  st_idx,

    // WB stage
    output logic [31:0] lsu_ld_data,
    output logic [2:0]  lsu_rob_idx,
    output logic        lsu_o_valid,
    
    // DC - LSU handshake
    output logic        ld_ready,
    output logic        st_ready
);
    typedef struct {
        logic [15:0]    addr;
        logic [31:0]    data;
        logic [2:0]     rob_idx;
        logic           valid;
        logic           issued;
    } SQ_entry;

    typedef struct {
        logic [15:0]    addr;
        logic [1:0]     SQ_t;
        logic [6:0]     rd;
        logic [2:0]     rob_idx;
        logic           valid;
        logic           issued;
    } LQ_entry;

    SQ_entry SQ [0:3];
    LQ_entry LQ [0:3];
    logic [1:0] SQ_h, SQ_t;
    logic [1:0] LQ_h, LQ_t;
    logic DC_in_ld, DC_in_st;
    logic EXE_in_ld, EXE_in_st;
    
    logic [3:0] SQ_cmp;
    logic [3:0] age_mask;

    logic load_valid;
    logic ld_from_issue;
    logic [15:0] LQ_h_addr;
    logic [1:0]  LQ_h_SQ_t;

    logic [3:0] flush_mask_ld;
    logic [3:0] flush_mask_st;
     
    assign ld_ready         = !(LQ_t == LQ_h && LQ[LQ_h].valid) && IS_ready; 
    assign st_ready         = !(SQ_t == SQ_h && SQ[SQ_h].valid) && IS_ready; 
    assign DC_in_ld         = (DC_out_op == `LOAD   || DC_out_op == `FLOAD ) && DC_valid && ld_ready; 
    assign DC_in_st         = (DC_out_op == `S_TYPE || DC_out_op == `FSTORE) && DC_valid && st_ready; 
    assign EXE_in_ld        = (LSU_in_op == `LOAD   || LSU_in_op == `FLOAD ) && IS_valid;
    assign EXE_in_st        = (LSU_in_op == `S_TYPE || LSU_in_op == `FSTORE) && IS_valid;

    assign ld_idx           = LQ_h + ld_commit;
    assign st_idx           = SQ_t + st_commit;

    assign ld_from_issue    = LSU_in_ld_idx == LQ_h && LQ[LQ_h].valid && EXE_in_ld;
    assign load_valid       = (ld_from_issue || LQ[LQ_h].issued) && ((SQ_cmp & age_mask) == 4'b0000) && lsu_o_ready;
    assign LQ_h_SQ_t        = LQ[LQ_h].SQ_t;
    assign LQ_h_addr        = ld_from_issue ? (LSU_in_rs1_data[15:0] + LSU_in_imm[15:0]) : LQ[LQ_h].addr;
    
    always_comb begin
        for(int i = 0; i < 4; i = i + 1) begin
            if(LQ_h_SQ_t < SQ_h) begin
                age_mask[i] = (i < LQ_h_SQ_t) || (i >= SQ_h);
            end
            else begin
                age_mask[i] = (i < LQ_h_SQ_t) && (i >= SQ_h);
            end
            SQ_cmp[i] = !SQ[i].valid;
        end

        for(int i = 0; i < 4; i = i + 1) begin
            if(EXE_in_ld_idx < LQ_h) begin
                flush_mask_ld[i] = (i >= EXE_in_ld_idx) && (i < LQ_h);
            end
            else begin
                flush_mask_ld[i] = (i >= EXE_in_ld_idx) || (i < LQ_h);
            end
        end

        for(int i = 0; i < 4; i = i + 1) begin
            if(EXE_in_st_idx < SQ_h) begin
                flush_mask_st[i] = (i >= EXE_in_st_idx) && (i < SQ_h);
            end
            else begin
                flush_mask_st[i] = (i >= EXE_in_st_idx) || (i < SQ_h);
            end
        end
    end

    // DM interface
    assign DM_r_en          = !st_commit;               // read when not commit
    assign DM_w_en          = {32{!st_commit}};         // bit write enable
    assign DM_addr          = DM_r_en ? LQ_h_addr : SQ[SQ_h].addr;
    assign DM_w_data        = SQ[SQ_h].data;
    assign DM_c_en          = !(st_commit || load_valid);  // enable when commit or load

    logic load_done;
    // LSU output to EXE stage
    always_ff @(posedge clk) begin
        load_done <= (load_valid && !DM_r_en);
    end
    assign lsu_ld_data      = (EXE_in_st) ? 32'b0 : DM_rd_data;
    assign lsu_rob_idx      = (EXE_in_st) ? LSU_in_rob_idx : LQ[LQ_h].rob_idx;
    assign lsu_o_valid      = (EXE_in_st) ? 1'b1 : load_done;

    // LQ and SQ management
    always_ff @(posedge clk) begin
        if(rst) begin
            for(int i = 0; i < 4; i = i + 1) begin
                SQ[i].addr      <= 16'b0;
                SQ[i].data      <= 32'b0;
                SQ[i].valid     <= 1'b0;
                SQ[i].issued    <= 1'b0;
                SQ[i].rob_idx   <= 3'b0;

                LQ[i].addr      <= 16'b0;
                LQ[i].SQ_t      <= 2'b0;
                LQ[i].rd        <= 7'b0;
                LQ[i].valid     <= 1'b0;
                LQ[i].issued    <= 1'b0;
                LQ[i].rob_idx   <= 3'b0;
            end
            SQ_h <= 2'b0;
            SQ_t <= 2'b0;
            LQ_h <= 2'b0;
            LQ_t <= 2'b0;
        end
        else begin
            // Dispatch
            if(DC_in_ld) begin
                LQ[LQ_t].SQ_t   <= SQ_t;
                LQ[LQ_t].valid  <= 1'b1;
                LQ_t            <= LQ_t + 1;
            end

            if(DC_in_st) begin
                SQ[SQ_t].valid  <= 1'b1;
                SQ_t            <= SQ_t + 1;
            end

            // Issue
            if(EXE_in_ld) begin
                LQ[LSU_in_ld_idx].issued    <= 1'b1;
                LQ[LSU_in_ld_idx].addr      <= LSU_in_rs1_data[15:0] + LSU_in_imm[15:0];
                LQ[LSU_in_ld_idx].rob_idx   <= LSU_in_rob_idx;
            end

            if(EXE_in_st) begin
                SQ[LSU_in_st_idx].issued    <= 1'b1;
                SQ[LSU_in_st_idx].addr      <= LSU_in_rs1_data[15:0] + LSU_in_imm[15:0];
                SQ[LSU_in_st_idx].data      <= LSU_in_rs2_data;
                SQ[LSU_in_st_idx].rob_idx   <= LSU_in_rob_idx;
            end

            // Commit
            if(ld_commit) begin
                LQ[LQ_h].valid      <= 1'b0;
                LQ[LQ_h].issued     <= 1'b0;
                LQ[LQ_h].addr       <= 16'b0;
                LQ[LQ_h].SQ_t       <= 2'b0;
                LQ[LQ_h].rd         <= 7'b0;
                LQ[LQ_h].rob_idx    <= 3'b0;
                LQ_h                <= LQ_h + 1;
            end 

            if(st_commit) begin 
                SQ[SQ_h].valid      <= 1'b0;
                SQ[SQ_h].issued     <= 1'b0;
                SQ[SQ_h].addr       <= 16'b0;
                SQ[SQ_h].data       <= 32'b0;
                SQ[SQ_h].rob_idx    <= 3'b0;
                SQ_h                <= SQ_h + 1;
            end

            if(mispredict) begin
                LQ_t <= EXE_in_ld_idx;
                SQ_t <= EXE_in_st_idx;
                for(int i = 0; i < 4; i = i + 1) begin
                    if(flush_mask_ld[i]) begin
                        LQ[i].valid      <= 1'b0;
                        LQ[i].issued     <= 1'b0;
                        LQ[i].addr       <= 16'b0;
                        LQ[i].SQ_t       <= 2'b0;
                        LQ[i].rd         <= 7'b0;
                        LQ[i].rob_idx    <= 3'b0;
                    end
                    if(flush_mask_st[i]) begin
                        SQ[i].valid      <= 1'b0;
                        SQ[i].issued     <= 1'b0;
                        SQ[i].addr       <= 16'b0;
                        SQ[i].data       <= 32'b0;
                        SQ[i].rob_idx    <= 3'b0;
                    end
                end
            end
        end
    end
endmodule