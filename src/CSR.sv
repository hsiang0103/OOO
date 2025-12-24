module CSR(
    input   logic               clk,
    input   logic               rst,
    input   logic   [2:0]       funct3,
    input   logic   [4:0]       uimm,
    input   logic   [31:0]      imm,
    input   logic   [31:0]      rs1_data,
    input   logic               WDT_interrupt,
    input   logic               DMA_interrupt,
    // control
    input   logic                           commit_valid,
    input   logic                           csr_i_valid,
    input   logic   [$clog2(`ROB_LEN)-1:0]  csr_i_rob_idx,
    input   logic   [6:0]                   csr_i_rd,
    output  logic                           csr_o_valid,
    output  logic   [$clog2(`ROB_LEN)-1:0]  csr_o_rob_idx,
    output  logic   [6:0]                   csr_o_rd,
    output  logic   [31:0]                  csr_o_data
);  

    // =============
    //      CSR
    // =============

    localparam logic [31:0] MSTATUS_MASK    = 32'h0000_1888; 
    localparam logic [31:0] MIE_MASK        = 32'h0000_0880; 
    localparam logic [31:0] MEPC_MASK       = 32'hFFFF_FFFC; 
    localparam logic [31:0] MTVEC_MASK      = 32'h0000_0000;
    localparam logic [31:0] MIP_WRITE_MASK  = 32'h0000_0000;
    

    logic [31:0] mstatus;
    logic [31:0] mtvec;
    logic [31:0] mip, mip_r;
    logic [31:0] mie;
    logic [31:0] mepc;

    logic [31:0] csr_w_data;

    logic interrupt_return;
    logic interrupt_pending;

    always_comb begin
        unique case(funct3)
            `CSRRW:  csr_w_data = rs1_data;
            `CSRRS:  csr_w_data = csr_o_data | rs1_data;
            `CSRRC:  csr_w_data = csr_o_data & ~rs1_data;
            `CSRRWI: csr_w_data = {27'b0, uimm};
            `CSRRSI: csr_w_data = csr_o_data | {27'b0, uimm};
            `CSRRCI: csr_w_data = csr_o_data & ~{27'b0, uimm};
            default: csr_w_data = 32'b0;
        endcase

        mip = 32'b0;
        mip[1]          = mip_r[1]; 
        mip[5]          = mip_r[5]; 
        mip[7]          = WDT_interrupt;
        mip[9]          = mip_r[9]; 
        mip[11]         = DMA_interrupt;
        

        interrupt_pending   = ((mie & mip) != 32'b0) && mstatus[3];
        interrupt_return    = (csr_i_valid && imm == `MRET);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            mstatus <= 32'b0; 
            mie     <= 32'b0;
            mepc    <= 32'b0;
            mtvec   <= 32'h00010000;
            mip_r   <= 32'b0;
        end
        else begin
            // mstatus
            priority if(interrupt_pending && commit_valid) begin
                // interrupt taken
                mstatus[3]      <= 1'b0;        // MIE
                mstatus[7]      <= mstatus[3];  // MPIE
                mstatus[12:11]  <= 2'b11;       // MPP
            end
            else if(interrupt_return) begin
                // interrupt return
                mstatus[3]      <= mstatus[7];  // MIE
                mstatus[7]      <= 1'b1;        // MPIE
                mstatus[12:11]  <= 2'b11;       // MPP
            end
            else if(csr_i_valid) begin
                case (imm)
                    `MIE:       mie     <= (csr_w_data & MIE_MASK)       | (mie & ~MIE_MASK);
                    `MEPC:      mepc    <= (csr_w_data & MEPC_MASK)      | (mepc & ~MEPC_MASK);
                    `MSTATUS:   mstatus <= (csr_w_data & MSTATUS_MASK)   | (mstatus & ~MSTATUS_MASK);
                    `MTVEC:     mtvec   <= (csr_w_data & MTVEC_MASK)     | (mtvec & ~MTVEC_MASK);
                    `MIP:       mip_r   <= (csr_w_data & MIP_WRITE_MASK) | (mip_r & ~MIP_WRITE_MASK);
                endcase
            end
            else begin
                mstatus <= mstatus;
                mie     <= mie;
                mepc    <= mepc;
                mtvec   <= mtvec;
                mip_r   <= mip_r;
            end
        end
    end

    always_comb begin
        case (imm)
            `MSTATUS: csr_o_data = mstatus;
            `MTVEC:   csr_o_data = mtvec;
            `MIE:     csr_o_data = mie;
            `MIP:     csr_o_data = mip;
            `MEPC:    csr_o_data = mepc;
            default:  csr_o_data = 32'b0;
        endcase

        csr_o_rd       = csr_i_rd;
        csr_o_rob_idx  = csr_i_rob_idx;
        csr_o_valid    = csr_i_valid;
    end
endmodule