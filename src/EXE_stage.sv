module EXE_stage(
    input logic clk,
    input logic rst,

    // From IS stage
    input logic [2:0]   EXE_in_fu_sel,
    input logic [31:0]  EXE_in_inst,
    input logic [31:0]  EXE_in_rs1_data,
    input logic [31:0]  EXE_in_rs2_data,
    input logic [31:0]  EXE_in_imm,
    input logic [15:0]  EXE_in_pc,
    input logic [5:0]   EXE_in_rd,   
    input logic [4:0]   EXE_in_op,    
    input logic [2:0]   EXE_in_f3,
    input logic [6:0]   EXE_in_f7,
    input logic [2:0]   EXE_in_rob_idx,

    // From LSU 
    input logic [31:0]  lsu_ld_data,
    input logic         lsu_o_valid,
    input logic [2:0]   lsu_rob_idx,


    // TO IF stage
    output logic [15:0] EXE_out_jb_pc,  
    output logic        mispredict,  
    output logic [2:0]  mis_rob_idx,

    // To LSU
    output logic        lsu_o_ready,

    // To WB stage
    output logic [31:0] WB_out_data,
    output logic [2:0]  WB_out_rob_idx, 
    output logic        WB_out_valid,

    // Handshake signals
    // IS --- EXE
    input  logic        IS_valid,
    output logic [4:0]  EXE_ready
);  

    typedef struct {
        logic [31:0] data;
        logic [2:0]  rob_idx;
    } fu_out;

    logic [3:0]  out_sel;

    // =========== ALU ===========
    fu_out alu_out, alu_skid, alu_wb;
    logic alu_o_valid;
    logic alu_o_ready;
    logic alu_wb_valid;
    logic alu_start;
    logic alu_bypass;

    ALU ALU1(
        .opcode         (EXE_in_op),
        .funct3         (EXE_in_f3),
        .funct7         (EXE_in_f7[5]),
        .rs1_data       (EXE_in_rs1_data),
        .rs2_data       (EXE_in_rs2_data),
        .imm            (EXE_in_imm),
        .pc             (EXE_in_pc),
        .alu_start      (alu_start),
        .EXE_rob_idx    (EXE_in_rob_idx),
        .alu_out        (alu_out.data),
        .alu_rob_idx    (alu_out.rob_idx),
        .alu_jb_out     (EXE_out_jb_pc),
        .alu_o_valid    (alu_o_valid),
        .mispredict     (mispredict)
    );

    // Skid buffer for ALU output
    always_ff @(posedge clk) begin
        if(rst) begin
            alu_skid.data       <= 32'b0;
            alu_skid.rob_idx    <= 3'b0;
            alu_bypass          <= 1'b1;
        end
        else begin
            if(alu_bypass) begin
                if(!out_sel[0] && alu_o_valid) begin
                    alu_skid.data       <= alu_out.data;
                    alu_skid.rob_idx    <= alu_out.rob_idx;
                    alu_bypass          <= 1'b0;
                end
            end
            else begin
                alu_skid.data       <= alu_skid.data;
                alu_skid.rob_idx    <= alu_skid.rob_idx;
                alu_bypass          <= out_sel[0];
            end
        end
    end       

    always_comb begin
        if(alu_bypass) begin
            alu_wb.data     = alu_out.data;
            alu_wb.rob_idx  = alu_out.rob_idx;
        end
        else begin
            alu_wb.data     = alu_skid.data;
            alu_wb.rob_idx  = alu_skid.rob_idx;
        end
    
        alu_start    = (EXE_in_fu_sel == 3'b000) && IS_valid  && alu_o_ready; // ALU start signal
        alu_wb_valid = alu_bypass ? alu_o_valid : 1'b1;
        alu_o_ready  = alu_bypass;
        mis_rob_idx  = alu_out.rob_idx;
    end

    // =========== MDR ===========
    fu_out mdr_out, mdr_skid, mdr_wb;
    logic mdr_o_valid;
    logic mdr_o_ready;
    logic mdr_wb_valid;
    logic mdr_start;
    logic mdr_bypass;

    MDR mdr1(
        .clk            (clk),
        .rst            (rst),
        .funct3         (EXE_in_f3),
        .rs1_data       (EXE_in_rs1_data),
        .rs2_data       (EXE_in_rs2_data),
        .mdr_start      (mdr_start),
        .EXE_rob_idx    (EXE_in_rob_idx),
        .mdr_out        (mdr_out.data),
        .mdr_rob_idx    (mdr_out.rob_idx),
        .mdr_o_valid    (mdr_o_valid)
    );

    // Skid buffer for mdr output
    always_ff @(posedge clk) begin
        if(rst) begin
            mdr_skid.data       <= 32'b0;
            mdr_skid.rob_idx    <= 3'b0;
            mdr_bypass          <= 1'b1;
        end
        else begin
            if(mdr_bypass) begin
                if(!out_sel[1] && mdr_o_valid) begin
                    mdr_skid.data       <= mdr_out.data;
                    mdr_skid.rob_idx    <= mdr_out.rob_idx;
                    mdr_bypass          <= 1'b0;
                end
            end
            else begin
                mdr_skid.data       <= mdr_skid.data;
                mdr_skid.rob_idx    <= mdr_skid.rob_idx;
                mdr_bypass          <= out_sel[1];
            end
        end
    end       

    always_comb begin
        if(mdr_bypass) begin
            mdr_wb.data     = mdr_out.data;
            mdr_wb.rob_idx  = mdr_out.rob_idx;
        end
        else begin
            mdr_wb.data     = mdr_skid.data;
            mdr_wb.rob_idx  = mdr_skid.rob_idx;
        end

        mdr_start    = (EXE_in_fu_sel == 3'b001) && IS_valid  && mdr_o_ready; // mdr start signal
        mdr_wb_valid = mdr_bypass ? mdr_o_valid : 1'b1;
        mdr_o_ready  = mdr_bypass;
    end

    // =========== LSU ===========
    fu_out lsu_skid, lsu_wb;
    logic lsu_wb_valid;
    logic lsu_bypass;

    // Skid buffer for lsu output
    always_ff @(posedge clk) begin
        if(rst) begin
            lsu_skid.data       <= 32'b0;
            lsu_skid.rob_idx    <= 3'b0;
            lsu_bypass          <= 1'b1;
        end
        else begin
            if(lsu_bypass) begin
                if(!out_sel[2] && lsu_o_valid) begin
                    lsu_skid.data       <= lsu_ld_data;
                    lsu_skid.rob_idx    <= lsu_rob_idx;
                    lsu_bypass          <= 1'b0;
                end
            end
            else begin
                lsu_skid.data       <= lsu_skid.data;
                lsu_skid.rob_idx    <= lsu_skid.rob_idx;
                lsu_bypass          <= out_sel[2];
            end
        end
    end       

    always_comb begin
        if(lsu_bypass) begin
            lsu_wb.data     = lsu_ld_data;
            lsu_wb.rob_idx  = lsu_rob_idx;
        end
        else begin
            lsu_wb.data     = lsu_skid.data;
            lsu_wb.rob_idx  = lsu_skid.rob_idx;
        end

        lsu_wb_valid = lsu_bypass ? lsu_o_valid : 1'b1;
        lsu_o_ready  = lsu_bypass;
    end

    // =========== FPU ===========
    fu_out fpu_out, fpu_skid, fpu_wb;
    logic fpu_o_valid;
    logic fpu_o_ready;
    logic fpu_wb_valid;
    logic fpu_start;
    logic fpu_bypass;

    FPU fpu1(
        .clk            (clk),
        .rst            (rst),
        .funct5         (EXE_in_f7[6:2]),
        .operand1       (EXE_in_rs1_data),
        .operand2       (EXE_in_rs2_data),
        .fpu_start      (fpu_start),
        .EXE_rob_idx    (EXE_in_rob_idx),
        .fpu_out        (fpu_out.data),
        .fpu_rob_idx    (fpu_out.rob_idx),
        .fpu_o_valid    (fpu_o_valid)
    );

    // Skid buffer for fpu output
    always_ff @(posedge clk) begin
        if(rst) begin
            fpu_skid.data       <= 32'b0;
            fpu_skid.rob_idx    <= 3'b0;
            fpu_bypass          <= 1'b1;
        end
        else begin
            if(fpu_bypass) begin
                if(!out_sel[3] && fpu_o_valid) begin
                    fpu_skid.data       <= fpu_out.data;
                    fpu_skid.rob_idx    <= fpu_out.rob_idx;
                    fpu_bypass          <= 1'b0;
                end
            end
            else begin
                fpu_skid.data       <= fpu_skid.data;
                fpu_skid.rob_idx    <= fpu_skid.rob_idx;
                fpu_bypass          <= out_sel[3];
            end
        end
    end       

    always_comb begin
        if(fpu_bypass) begin
            fpu_wb.data     = fpu_out.data;
            fpu_wb.rob_idx  = fpu_out.rob_idx;
        end
        else begin
            fpu_wb.data     = fpu_skid.data;
            fpu_wb.rob_idx  = fpu_skid.rob_idx;
        end

        fpu_start    = (EXE_in_fu_sel == 3'b011) && IS_valid  && fpu_o_ready; // fpu start signal
        fpu_wb_valid = fpu_bypass ? fpu_o_valid : 1'b1;
        fpu_o_ready  = fpu_bypass;
    end

    // =========== WB MUX ===========
    // FU selection
    // 0: ALU
    // 1: MDR 
    // 2: Load 
    // 3: Store 
    // 4: FPU

    always_comb begin
        case(1'b1) 
            mdr_wb_valid: out_sel = 4'b0010;
            lsu_wb_valid: out_sel = 4'b0100;
            fpu_wb_valid: out_sel = 4'b1000;
            alu_wb_valid: out_sel = 4'b0001;
            default:      out_sel = 4'b0000;
        endcase 

        EXE_ready = {fpu_o_ready, 1'b1, lsu_o_ready, mdr_o_ready, alu_o_ready};
    end

    always_comb begin
        unique case(1'b1)
            out_sel[0]: begin
                WB_out_data     = alu_wb.data;
                WB_out_rob_idx  = alu_wb.rob_idx;
                WB_out_valid    = alu_wb_valid;
            end
            out_sel[1]: begin
                WB_out_data     = mdr_wb.data;
                WB_out_rob_idx  = mdr_wb.rob_idx;
                WB_out_valid    = mdr_wb_valid;
            end
            out_sel[2]: begin
                WB_out_data     = lsu_wb.data;
                WB_out_rob_idx  = lsu_wb.rob_idx;
                WB_out_valid    = lsu_wb_valid;
            end
            out_sel[3]: begin
                WB_out_data     = fpu_wb.data;
                WB_out_rob_idx  = fpu_wb.rob_idx;
                WB_out_valid    = fpu_wb_valid;
            end
            default: begin
                WB_out_data     = 32'b0;
                WB_out_rob_idx  = 3'b0;
                WB_out_valid    = 1'b0;
            end
        endcase
    end
endmodule