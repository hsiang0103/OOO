module AXI(
    input clk,
    input rstn,

    // AR
    input  logic [`AXI_ID_BITS  -1:0] ARID_M   [`MASTER_NUM],
    input  logic [`AXI_ADDR_BITS-1:0] ARADDR_M [`MASTER_NUM],
    input  logic [`AXI_LEN_BITS -1:0] ARLEN_M  [`MASTER_NUM],
    input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M [`MASTER_NUM],
    input  logic [1:0]                ARBURST_M[`MASTER_NUM],
    input  logic                      ARVALID_M[`MASTER_NUM],
    output logic                      ARREADY_M[`MASTER_NUM],
    // R
    output logic [`AXI_ID_BITS  -1:0] RID_M    [`MASTER_NUM],
    output logic [`AXI_DATA_BITS-1:0] RDATA_M  [`MASTER_NUM],
    output logic [1:0]                RRESP_M  [`MASTER_NUM],
    output logic                      RLAST_M  [`MASTER_NUM],
    output logic                      RVALID_M [`MASTER_NUM],
    input  logic                      RREADY_M [`MASTER_NUM],
    // AW
    input  logic [`AXI_ID_BITS  -1:0] AWID_M   [`MASTER_NUM],
    input  logic [`AXI_ADDR_BITS-1:0] AWADDR_M [`MASTER_NUM],
    input  logic [`AXI_LEN_BITS -1:0] AWLEN_M  [`MASTER_NUM],
    input  logic [`AXI_SIZE_BITS-1:0] AWSIZE_M [`MASTER_NUM],
    input  logic [1:0]                AWBURST_M[`MASTER_NUM],
    input  logic                      AWVALID_M[`MASTER_NUM],
    output logic                      AWREADY_M[`MASTER_NUM],
    // W
    input  logic [`AXI_DATA_BITS-1:0] WDATA_M  [`MASTER_NUM],
    input  logic [`AXI_STRB_BITS-1:0] WSTRB_M  [`MASTER_NUM],
    input  logic                      WLAST_M  [`MASTER_NUM],
    input  logic                      WVALID_M [`MASTER_NUM],
    output logic                      WREADY_M [`MASTER_NUM],
    // B
    output logic [`AXI_ID_BITS  -1:0] BID_M    [`MASTER_NUM],
    output logic [1:0]                BRESP_M  [`MASTER_NUM],
    output logic                      BVALID_M [`MASTER_NUM],
    input  logic                      BREADY_M [`MASTER_NUM],

    // AR
    output logic [`AXI_IDS_BITS -1:0] ARID_S   [`SLAVE_NUM],
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_S [`SLAVE_NUM],
    output logic [`AXI_LEN_BITS -1:0] ARLEN_S  [`SLAVE_NUM],
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S [`SLAVE_NUM],
    output logic [1:0]                ARBURST_S[`SLAVE_NUM],
    output logic                      ARVALID_S[`SLAVE_NUM],
    input  logic                      ARREADY_S[`SLAVE_NUM],
    // R
    input  logic [`AXI_IDS_BITS -1:0] RID_S    [`SLAVE_NUM],
    input  logic [`AXI_DATA_BITS-1:0] RDATA_S  [`SLAVE_NUM],
    input  logic [1:0]                RRESP_S  [`SLAVE_NUM],
    input  logic                      RLAST_S  [`SLAVE_NUM],
    input  logic                      RVALID_S [`SLAVE_NUM],
    output logic                      RREADY_S [`SLAVE_NUM],
    // AW
    output logic [`AXI_IDS_BITS -1:0] AWID_S   [`SLAVE_NUM],
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_S [`SLAVE_NUM],
    output logic [`AXI_LEN_BITS -1:0] AWLEN_S  [`SLAVE_NUM],
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S [`SLAVE_NUM],
    output logic [1:0]                AWBURST_S[`SLAVE_NUM],
    output logic                      AWVALID_S[`SLAVE_NUM],
    input  logic                      AWREADY_S[`SLAVE_NUM],
    // W
    output logic [`AXI_DATA_BITS-1:0] WDATA_S  [`SLAVE_NUM],
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S  [`SLAVE_NUM],
    output logic                      WLAST_S  [`SLAVE_NUM],
    output logic                      WVALID_S [`SLAVE_NUM],
    input  logic                      WREADY_S [`SLAVE_NUM],
    // B
    input  logic [`AXI_IDS_BITS -1:0] BID_S    [`SLAVE_NUM],
    input  logic [1:0]                BRESP_S  [`SLAVE_NUM],
    input  logic                      BVALID_S [`SLAVE_NUM],
    output logic                      BREADY_S [`SLAVE_NUM] 
);
    typedef enum logic [`MASTER_BITS - 1 : 0] {
        CPU_IF  = `MASTER_BITS'(0),
        CPU_MEM = `MASTER_BITS'(1),
        DMA_M   = `MASTER_BITS'(2)
    } MASTER_t;

    typedef enum logic [`SLAVE_BITS - 1 : 0] {
        ROM     = `SLAVE_BITS'(0),
        IM      = `SLAVE_BITS'(1),
        DM      = `SLAVE_BITS'(2),
        DMA_S   = `SLAVE_BITS'(3),
        WDT     = `SLAVE_BITS'(4),
        DRAM    = `SLAVE_BITS'(5)
    } SLAVE_t;

    typedef enum logic {
        READ    = 1'b0,
        WRITE   = 1'b1
    } TRANSFER_t;

    typedef struct packed {
        logic       valid;
        MASTER_t    master;   
        TRANSFER_t  read_or_write;
    } SLAVE_STATUS_t;

    SLAVE_STATUS_t slave_status_q [`SLAVE_NUM];
    SLAVE_STATUS_t slave_status_d [`SLAVE_NUM];

    logic transfer_finish[`SLAVE_NUM];

    SLAVE_t RTARGET_S[`MASTER_NUM];
    SLAVE_t WTARGET_S[`MASTER_NUM];
    always_comb begin
        // Read
        for (int i = 0; i < `MASTER_NUM; i = i + 1) begin
            unique case ({ARADDR_M[i][31:28], ARADDR_M[i][19:16]})
                8'h00:      RTARGET_S[i] = ROM;
                8'h01:      RTARGET_S[i] = IM;
                8'h02:      RTARGET_S[i] = DM;
                8'h12:      RTARGET_S[i] = DMA_S;
                8'h11:      RTARGET_S[i] = WDT;
                default:    RTARGET_S[i] = DRAM;
            endcase
        end

        // Write
        // CPU_IF wouldn't write
        for (int i = 1; i < `MASTER_NUM; i = i + 1) begin
            unique case ({AWADDR_M[i][31:28], AWADDR_M[i][19:16]})
                8'h00:      WTARGET_S[i] = ROM;
                8'h01:      WTARGET_S[i] = IM;
                8'h02:      WTARGET_S[i] = DM;
                8'h12:      WTARGET_S[i] = DMA_S;
                8'h11:      WTARGET_S[i] = WDT;
                default:    WTARGET_S[i] = DRAM;
            endcase
        end
    end

    // slave locks
    always_ff @(posedge clk) begin
        if(!rstn)begin
            for (int i = 0; i < `SLAVE_NUM; i = i + 1) begin
                slave_status_q[i] <= SLAVE_STATUS_t'(0);
            end
        end else begin
            for (int i = 0; i < `SLAVE_NUM; i = i + 1) begin
                slave_status_q[i] <= slave_status_d[i];
            end
        end
    end
    always_comb begin
        // default
        for (int i = 0; i < `SLAVE_NUM; i = i + 1) begin
            slave_status_d[i] = slave_status_q[i];
        end
        
        // release lock
        for (int i = 0; i < `SLAVE_NUM; i = i + 1) begin
            transfer_finish[i] = (BVALID_S[i] & BREADY_S[i]) | (RLAST_S[i] & RREADY_S[i] & RVALID_S[i]);
            slave_status_d[i].valid = (slave_status_q[i].valid)? 
                ~transfer_finish[i]:
                slave_status_q[i].valid;
        end

        // Write
        // lock
        for (int i = 0; i < `MASTER_NUM; i = i + 1) begin
            if(
                AWVALID_M[i] && 
                !slave_status_q[`SLAVE_BITS'(WTARGET_S[i])].valid
            )begin
                slave_status_d[`SLAVE_BITS'(WTARGET_S[i])].valid = 1'b1;
                slave_status_d[`SLAVE_BITS'(WTARGET_S[i])].master = MASTER_t'(i);
                slave_status_d[`SLAVE_BITS'(WTARGET_S[i])].read_or_write = WRITE;
            end
        end

        // Read
        // lock
        for (int i = 0; i < `MASTER_NUM; i = i + 1) begin
            if(
                ARVALID_M[i] &&
                !slave_status_q[`SLAVE_BITS'(RTARGET_S[i])].valid
            )begin
                slave_status_d[`SLAVE_BITS'(RTARGET_S[i])].valid = 1'b1;
                slave_status_d[`SLAVE_BITS'(RTARGET_S[i])].master = MASTER_t'(i);
                slave_status_d[`SLAVE_BITS'(RTARGET_S[i])].read_or_write = READ;
            end
        end
    end

    // assign wires
    always_comb begin
        for (int i = 0; i < `MASTER_NUM; i = i + 1) begin
            ARREADY_M[i] = 1'b0;
            RID_M    [i] = `AXI_ID_BITS'd0;
            RDATA_M  [i] = `AXI_DATA_BITS'd0;
            RRESP_M  [i] = `AXI_RESP_OKAY;
            RLAST_M  [i] = 1'b0;
            RVALID_M [i] = 1'b0;
            AWREADY_M[i] = 1'b0;
            WREADY_M [i] = 1'b0;
            BID_M    [i] = `AXI_ID_BITS'd0;
            BRESP_M  [i] = `AXI_RESP_OKAY;
            BVALID_M [i] = 1'b0;
        end

        for (int i = 0; i < `SLAVE_NUM; i = i + 1) begin
            ARID_S   [i] = `AXI_IDS_BITS'd0;
            ARADDR_S [i] = `AXI_ADDR_BITS'd0;
            ARLEN_S  [i] = `AXI_LEN_ONE;
            ARSIZE_S [i] = `AXI_SIZE_WORD;
            ARBURST_S[i] = `AXI_BURST_INC;
            ARVALID_S[i] = 1'b0;
            RREADY_S [i] = 1'b0;
            AWID_S   [i] = `AXI_IDS_BITS'd0;
            AWADDR_S [i] = `AXI_ADDR_BITS'd0;
            AWLEN_S  [i] = `AXI_LEN_ONE;
            AWSIZE_S [i] = `AXI_SIZE_WORD;
            AWBURST_S[i] = `AXI_BURST_INC;
            AWVALID_S[i] = 1'b0;
            WDATA_S  [i] = `AXI_DATA_BITS'd0;
            WSTRB_S  [i] = `AXI_STRB_WORD;
            WLAST_S  [i] = 1'b0;
            WVALID_S [i] = 1'b0;
            BREADY_S [i] = 1'b0;
        end

        for (int i = 0; i < `SLAVE_NUM; i = i + 1) begin
            if(slave_status_d[i].valid)begin
                if(slave_status_d[i].read_or_write == READ)begin
                    // Output to master
                    // AR
                    ARREADY_M[slave_status_d[i].master] = ARREADY_S[i];

                    // Output to slave
                    // AR
                    ARID_S   [i] = {4'b0, ARID_M[slave_status_d[i].master]};
                    ARADDR_S [i] = ARADDR_M     [slave_status_d[i].master];
                    ARLEN_S  [i] = ARLEN_M      [slave_status_d[i].master];
                    ARSIZE_S [i] = ARSIZE_M     [slave_status_d[i].master];
                    ARBURST_S[i] = ARBURST_M    [slave_status_d[i].master];
                    ARVALID_S[i] = ARVALID_M    [slave_status_d[i].master];
                end else begin
                    // Output to master
                    // AW
                    AWREADY_M[slave_status_d[i].master] = AWREADY_S[i];

                    // W
                    WREADY_M [slave_status_d[i].master] = WREADY_S[i];
                    
                    // Output to slave
                    // AW
                    AWID_S   [i] = {4'b0, AWID_M[slave_status_d[i].master]};
                    AWADDR_S [i] = AWADDR_M     [slave_status_d[i].master];
                    AWLEN_S  [i] = AWLEN_M      [slave_status_d[i].master];
                    AWSIZE_S [i] = AWSIZE_M     [slave_status_d[i].master];
                    AWBURST_S[i] = AWBURST_M    [slave_status_d[i].master];
                    AWVALID_S[i] = AWVALID_M    [slave_status_d[i].master];

                    // W
                    WDATA_S [i] = WDATA_M   [slave_status_d[i].master];
                    WSTRB_S [i] = WSTRB_M   [slave_status_d[i].master];
                    WLAST_S [i] = WLAST_M   [slave_status_d[i].master];
                    WVALID_S[i] = WVALID_M  [slave_status_d[i].master];
                end
            end

            if(slave_status_q[i].valid)begin
                if(slave_status_q[i].read_or_write == READ)begin
                    // Output to master
                    // R
                    RID_M   [slave_status_q[i].master]  = RID_S[i][3:0];
                    RDATA_M [slave_status_q[i].master]  = RDATA_S[i];
                    RRESP_M [slave_status_q[i].master]  = RRESP_S[i];
                    RLAST_M [slave_status_q[i].master]  = RLAST_S[i];
                    RVALID_M[slave_status_q[i].master]  = RVALID_S[i];

                    // R
                    RREADY_S [i] = RREADY_M     [slave_status_q[i].master];
                end else begin
                    // Output to master
                    // W
                    WREADY_M [slave_status_q[i].master] = WREADY_S[i];

                    // WB
                    BID_M   [slave_status_q[i].master] = BID_S[i][3:0];
                    BRESP_M [slave_status_q[i].master] = BRESP_S[i];
                    BVALID_M[slave_status_q[i].master] = BVALID_S[i];

                    // Output to slave
                    // W
                    WDATA_S [i] = WDATA_M   [slave_status_q[i].master];
                    WSTRB_S [i] = WSTRB_M   [slave_status_q[i].master];
                    WLAST_S [i] = WLAST_M   [slave_status_q[i].master];
                    WVALID_S[i] = WVALID_M  [slave_status_q[i].master];

                    // WB
                    BREADY_S[i] = BREADY_M  [slave_status_q[i].master];
                end
            end
        end
    end
endmodule