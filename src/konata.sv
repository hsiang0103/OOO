module konata(
    input logic clk,
    input logic rst,
    // IF stage signals
    input logic [31:0] IM_r_addr,
    // DC stage signals
    input logic        IF_valid,
    input logic        DC_ready,
    input logic [31:0] IF_out_pc,
    input logic [31:0] IF_out_inst,
    input logic [2:0]  ROB_tail,
    // IS stage signals
    input logic        DC_valid,
    input logic        IS_ready,
    input logic [31:0] DC_out_pc,
    // RR stage signals
    input logic        IS_valid,
    input logic        RR_ready,
    input logic [2:0]  IS_out_rob_idx,
    // EX stage signals
    input logic        RR_valid,
    input logic        EX_ready,
    input logic [2:0]  RR_out_rob_idx,
    input logic [31:0] RR_out_pc,
    // WB stage signals
    input logic        EX_valid,
    input logic [2:0]  EX_out_rob_idx,
    // Commit signals
    input logic        commit,
    input logic [2:0]  commit_rob_idx,
    // Flush signals
    input logic        mispredict,
    input logic [31:0] jb_pc,
    input logic [7:0]  flush_mask
);

    // File descriptor
    integer fd;
    
    // Cycle counter
    logic [63:0] cycle_count;
    
    // Instruction ID counter  
    logic [31:0] insn_id;
    logic [31:0] retire_id;
    logic [15:0] IF_pc_r;

    logic [2:0]  wb_rob_idx;
    logic        wb_valid_r;

    logic [2:0]  cm_rob_idx;
    logic        cm_valid_r;
    
    // Instruction tracking structure
    typedef struct packed {
        logic        valid;
        logic [31:0] id;           // Instruction ID in file
        logic [31:0] pc;
        logic [31:0] inst;
        logic [2:0]  rob_idx;
        
        // Stage tracking
        logic        if_started;
        logic        dc_started;
        logic        is_started;
        logic        rr_started;
        logic        ex_started;
        logic        wb_started;
        logic        cm_started;
        
        logic        retired;
        logic        flushed;
    } insn_track_t;

    // ROB tracking array (16 entries)
    insn_track_t insn_tracker [0:15];

    logic [15:0] next_IS;
    
    // Helper function to decode opcode name
    function string decode_opcode(input logic [4:0] op, input logic [2:0] f3, input logic [6:0] f7);
        case (op)
            5'b01100: begin // R-type
                case ({f7[5], f7[0], f3})
                    5'b00000: return "add";
                    5'b10000: return "sub";
                    5'b00111: return "and";
                    5'b00110: return "or";
                    5'b00100: return "xor";
                    5'b00001: return "sll";
                    5'b00101: return "srl";
                    5'b10101: return "sra";
                    5'b00010: return "slt";
                    5'b00011: return "sltu";
                    5'b01000: return "mul";
                    5'b01001: return "mulh";
                    5'b01010: return "mulhsu";
                    5'b01011: return "mulhu";

                    default: return "r-type";
                endcase
            end
            5'b00100: begin // I-type ALU
                case (f3)
                    3'b000: return "addi";
                    3'b111: return "andi";
                    3'b110: return "ori";
                    3'b100: return "xori";
                    3'b001: return "slli";
                    3'b101: return (f7[5]) ? "srai" : "srli";
                    3'b010: return "slti";
                    3'b011: return "sltiu";
                    default: return "i-type";
                endcase
            end
            5'b00000: begin // Load
                case (f3)
                    3'b000: return "lb";
                    3'b001: return "lh";
                    3'b010: return "lw";
                    3'b100: return "lbu";
                    3'b101: return "lhu";
                    default: return "load";
                endcase
            end
            5'b01000: begin // Store
                case (f3)
                    3'b000: return "sb";
                    3'b001: return "sh";
                    3'b010: return "sw";
                    default: return "store";
                endcase
            end
            5'b11000: begin // Branch
                case (f3)
                    3'b000: return "beq";
                    3'b001: return "bne";
                    3'b100: return "blt";
                    3'b101: return "bge";
                    3'b110: return "bltu";
                    3'b111: return "bgeu";
                    default: return "branch";
                endcase
            end
            5'b11011: return "jal";
            5'b11001: return "jalr";
            5'b01101: return "lui";
            5'b00101: return "auipc";
            default:  return "unknown";
        endcase
    endfunction
    
    // Initialize
    initial begin
        fd = $fopen("kanata.log", "w");
        if (fd == 0) begin
            $display("[Konata] Error: Cannot open kanata.log file");
            $finish;
        end
        
        // Write Kanata header (version 4)
        $fwrite(fd, "Kanata\t0004\n");
        
        // Write initial cycle marker
        $fwrite(fd, "C=\t0\n");
        $fflush(fd);
        
        // Initialize tracker
        
        $display("[Konata] Log initialized");
    end
    
    // Cycle counter
    always_ff @(posedge clk) begin
        if (rst) begin
            cycle_count <= 64'd0;
        end else begin
            cycle_count <= cycle_count + 64'd1;
        end
    end
    
    // Main logging logic
    always_ff @(posedge clk) begin
        if(rst) begin 
            insn_id     <= 0;
            retire_id   <= 0;
            IF_pc_r     <= 16'hFFFF;
            next_IS     <= 16'b0;
            for (int i = 0; i < 16; i++) begin
                insn_tracker[i] <= 'b0;
            end
        end
        else begin
            // Output cycle progression (C command)
            $fwrite(fd, "C\t1\n");
            
            // ========================================
            // Stage 8: Retire (Only in konata) 
            // ========================================
            if(commit) begin
                for (int i = 0; i < 16; i++) begin
                    if (insn_tracker[i].valid && insn_tracker[i].wb_started && 
                        insn_tracker[i].rob_idx == commit_rob_idx &&
                        !insn_tracker[i].retired) begin
                        insn_tracker[i].retired <= 1'b1;
                    end
                end
            end

            // ========================================
            // Stage 7: Commit 
            // ========================================
            for (int i = 0; i < 16; i++) begin
                if (insn_tracker[i].valid && insn_tracker[i].wb_started &&
                    !insn_tracker[i].cm_started) begin
                    // S command: Start CM stage
                    $fwrite(fd, "S\t%0d\t0\tCM\n", insn_tracker[i].id);
                    insn_tracker[i].cm_started  <= 1'b1;
                end
            end

            // ========================================
            // Stage 6: Write Back 
            // ========================================
            for (int i = 0; i < 16; i++) begin
                if (insn_tracker[i].valid && insn_tracker[i].rob_idx == EX_out_rob_idx &&
                    insn_tracker[i].ex_started &&
                    !insn_tracker[i].wb_started && EX_valid) begin
                    // S command: Start WB stage
                    $fwrite(fd, "S\t%0d\t0\tWB\n", insn_tracker[i].id);
                    insn_tracker[i].wb_started <= 1'b1;
                    break;
                end
            end

            // ========================================
            // Stage 5: Execute
            // ========================================
            if (RR_valid && EX_ready) begin
                for (int i = 0; i < 16; i++) begin
                    if (insn_tracker[i].valid && insn_tracker[i].rr_started &&
                        !insn_tracker[i].ex_started && 
                        (insn_tracker[i].inst[6:2] == `S_TYPE || 
                        insn_tracker[i].inst[6:2] == `FSTORE ||
                        insn_tracker[i].inst[6:2] == `B_TYPE)) begin
                        // S command: Start EX stage
                        $fwrite(fd, "S\t%0d\t0\tEX\n", insn_tracker[i].id);
                        insn_tracker[i].ex_started <= 1'b1;
                        insn_tracker[i].wb_started <= 1'b1;
                        break;
                    end

                    if (insn_tracker[i].valid && 
                        insn_tracker[i].rr_started &&
                        !insn_tracker[i].ex_started &&
                        insn_tracker[i].rob_idx == RR_out_rob_idx) begin
                        // S command: Start EX stage
                        $fwrite(fd, "S\t%0d\t0\tEX\n", insn_tracker[i].id);
                        insn_tracker[i].ex_started <= 1'b1;
                        break;
                    end
                end
            end

            // ========================================
            // Stage 4: Register Read
            // ========================================
            if (IS_valid && RR_ready) begin
                for (int i = 0; i < 16; i++) begin
                    if (insn_tracker[i].valid && IS_valid && RR_ready &&
                        insn_tracker[i].is_started && 
                        !insn_tracker[i].rr_started &&
                        insn_tracker[i].rob_idx == IS_out_rob_idx) begin
                        // S command: Start RR stage
                        $fwrite(fd, "S\t%0d\t0\tRR\n", insn_tracker[i].id);
                        insn_tracker[i].rr_started <= 1'b1;
                        break;
                    end
                end
            end

            // ========================================
            // Stage 3: Issue
            // ========================================
            if (DC_valid && IS_ready) begin
                for (int i = 0; i < 16; i++) begin
                    if(insn_tracker[i].valid && insn_tracker[i].dc_started && 
                    !insn_tracker[i].is_started &&
                    insn_tracker[i].pc == DC_out_pc) begin
                        // S command: Start IS stage
                        $fwrite(fd, "S\t%0d\t0\tIS\n", insn_tracker[i].id);
                        insn_tracker[i].is_started <= 1'b1;
                        break;
                    end
                end
            end

            // ========================================
            // Stage 2: Decode 
            // ========================================
            if (IF_valid && DC_ready) begin
                for (int i = 0; i < 16; i++) begin
                    if (insn_tracker[i].valid && 
                        insn_tracker[i].if_started && 
                        !insn_tracker[i].dc_started &&
                        insn_tracker[i].pc == IF_out_pc) begin
                        insn_tracker[i].inst = IF_out_inst;
                        // Decode the instruction and write (example: li x0,0 /addi	sp,sp,-4)
                        begin
                            logic [6:0] opcode;
                            logic [4:0] rd, rs1, rs2;
                            logic [2:0] funct3;
                            logic [6:0] funct7;
                            logic [31:0] imm;
                            string opname;
                            
                            // Extract instruction fields
                            opcode = IF_out_inst[6:0];
                            rd     = IF_out_inst[11:7];
                            funct3 = IF_out_inst[14:12];
                            rs1    = IF_out_inst[19:15];
                            rs2    = IF_out_inst[24:20];
                            funct7 = IF_out_inst[31:25];
                            
                            // Decode opcode name
                            opname = decode_opcode(opcode[6:2], funct3, funct7);
                            
                            // Format instruction string based on type
                            $fwrite(fd, "L\t%0d\t0\t%-3h: %08h ", insn_tracker[i].id, IF_out_pc, IF_out_inst);
                            case (opcode[6:2])
                                5'b01100: begin // R-type
                                    $fwrite(fd, "%-5s x%0d,x%0d,x%0d\n", opname, rd, rs1, rs2);
                                end
                                5'b00100: begin // I-type ALU
                                    imm = {{20{IF_out_inst[31]}}, IF_out_inst[31:20]};
                                    $fwrite(fd, "%-5s x%0d,x%0d,%0d\n", opname, rd, rs1, $signed(imm));
                                end
                                5'b00000: begin // Load
                                    imm = {{20{IF_out_inst[31]}}, IF_out_inst[31:20]};
                                    $fwrite(fd, "%-5s x%0d,%0d(x%0d)\n", opname, rd, $signed(imm), rs1);
                                end
                                5'b01000: begin // Store
                                    imm = {{20{IF_out_inst[31]}}, IF_out_inst[31:25], IF_out_inst[11:7]};
                                    $fwrite(fd, "%-5s x%0d,%0d(x%0d)\n", opname, rs2, $signed(imm), rs1);
                                end
                                5'b11000: begin // Branch
                                    imm = {{19{IF_out_inst[31]}}, IF_out_inst[31], IF_out_inst[7], 
                                           IF_out_inst[30:25], IF_out_inst[11:8], 1'b0};
                                    $fwrite(fd, "%-5s x%0d,x%0d,%0h\n", opname, rs1, rs2, $signed(imm + IF_out_pc));
                                end
                                5'b11011: begin // JAL
                                    imm = {{12{IF_out_inst[31]}}, IF_out_inst[19:12], IF_out_inst[20], IF_out_inst[30:21], 1'b0};
                                    $fwrite(fd, "%-5s %0h\n", opname, $signed(imm + IF_out_pc));
                                end
                                5'b11001: begin // JALR
                                    imm = {{20{IF_out_inst[31]}}, IF_out_inst[31:20]};
                                    $fwrite(fd, "%-5s x%0d,%0d(x%0d)\n", opname, rd, $signed(imm), rs1);
                                end
                                5'b01101: begin // LUI
                                    $fwrite(fd, "%-5s x%0d,0x%0h\n", opname, rd, IF_out_inst[31:12]);
                                end
                                5'b00101: begin // AUIPC
                                    $fwrite(fd, "%-5s x%0d,0x%0h\n", opname, rd, IF_out_inst[31:12]);
                                end
                                default: begin
                                    $fwrite(fd, "%-5s ", insn_tracker[i].id, opname);
                                end
                            endcase
                        end
                        // S command: Start DC stage
                        $fwrite(fd, "S\t%0d\t0\tDD\n", insn_tracker[i].id);
                        insn_tracker[i].dc_started  <= 1'b1;
                        insn_tracker[i].rob_idx     <= ROB_tail;
                        // L command: Add ROB allocation info
                        $fwrite(fd, "L\t%0d\t1\tROB[%0d]\n", insn_tracker[i].id, ROB_tail);
                        break;
                    end
                end
            end

            // ========================================
            // Handle mispredict flushes
            // ========================================    
            if(mispredict) begin
                for(int i = 0; i < 16; i++) begin
                    if (insn_tracker[i].valid && insn_tracker[i].dc_started && !insn_tracker[i].retired &&
                        flush_mask[insn_tracker[i].rob_idx]) begin
                        insn_tracker[i].retired <= 1'b1;
                        insn_tracker[i].flushed <= 1'b1;
                    end
                    if (insn_tracker[i].valid && 
                        insn_tracker[i].dc_started &&
                        !insn_tracker[i].is_started) begin
                        insn_tracker[i].retired <= 1'b1;
                        insn_tracker[i].flushed <= 1'b1;
                    end
                    if (insn_tracker[i].valid && 
                        insn_tracker[i].if_started &&
                        !insn_tracker[i].dc_started/* &&
                        insn_tracker[i].pc != jb_pc*/) begin
                        insn_tracker[i].retired <= 1'b1;
                        insn_tracker[i].flushed <= 1'b1;
                    end
                end
            end

            // ========================================
            // Stage 1: Instruction Fetch
            // ========================================
            // Find free slot in tracker
            if(IM_r_addr != IF_pc_r) begin
                for (int i = 0; i < 16; i++) begin
                    if (insn_tracker[i].valid == 0) begin
                        // I command: Start new instruction
                        $fwrite(fd, "I\t%0d\t%0d\t0\n", insn_id, insn_id);
                        // S command: Start IF stage
                        $fwrite(fd, "S\t%0d\t0\tIF\n", insn_id);
                        // Initialize tracker entry
                        insn_tracker[i].valid       <= 1'b1;
                        insn_tracker[i].id          <= insn_id;
                        insn_tracker[i].pc          <= IM_r_addr;
                        insn_tracker[i].if_started  <= 1'b1;
                        insn_id++;
                        break;
                    end
                end
            end
            IF_pc_r     <= IM_r_addr;

            // ========================================
            // Retired 
            // ========================================
            for (int i = 0; i < 16; i++) begin
                if (insn_tracker[i].valid && insn_tracker[i].retired) begin
                    // R command: 
                    $fwrite(fd, "R\t%0d\t0\t%d\n", insn_tracker[i].id, insn_tracker[i].flushed);
                    insn_tracker[i] <= 'b0;
                    retire_id++;
                end
            end
            
            $fflush(fd);
        end
    end
    
    // Close file on finish
    final begin
        if (fd != 0) begin
            $fclose(fd);
            $display("[Konata] Log closed. Cycles: %0d, Instructions: %0d, Retired: %0d", 
                     cycle_count, insn_id, retire_id);
        end
    end

endmodule
