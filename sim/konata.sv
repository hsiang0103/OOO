`include "../include/config.svh"
`include "../include/define.svh"


module konata(
    input logic clk,
    input logic rst,
    // IF stage signals
    input logic        fetch_request,
    input logic [31:0] fetch_addr,
    
    // DC stage signals
    input logic        IF_valid,
    input logic        DC_ready,
    input logic [31:0] IF_out_pc,
    input logic [31:0] IF_out_inst,
    input logic [$clog2(`ROB_LEN)-1:0]  ROB_tail,
    // IS stage signals
    input logic        DC_valid,
    input logic        IS_ready,
    input logic [31:0] DC_out_pc,
    // RR stage signals
    input logic        IS_valid,
    input logic        RR_ready,
    input logic [$clog2(`ROB_LEN)-1:0]  IS_out_rob_idx,
    // EX stage signals
    input logic        RR_valid,
    input logic        EX_ready,
    input logic [$clog2(`ROB_LEN)-1:0]  RR_out_rob_idx,
    input logic [31:0] RR_out_pc,
    // WB stage signals
    input logic        EX_valid,
    input logic [$clog2(`ROB_LEN)-1:0]  EX_out_rob_idx,
    // Commit signals
    input logic        commit,
    input logic [$clog2(`ROB_LEN)-1:0]  commit_rob_idx,
    // Flush signals
    input logic         mispredict,
    input logic [`ROB_LEN-1:0]  flush_mask
);

    // File descriptor
    integer fd;
    
    // Cycle counter
    logic [63:0] cycle_count;
    
    // Instruction ID counter  
    logic [31:0] insn_id;
    logic [31:0] retire_id;

    logic [$clog2(`ROB_LEN)-1:0]  wb_rob_idx;
    logic        wb_valid_r;

    logic [$clog2(`ROB_LEN)-1:0]  cm_rob_idx;
    logic        cm_valid_r;
    
    // Instruction tracking structure
    typedef struct packed {
        logic        valid;
        logic [31:0] id;           // Instruction ID in file
        logic [31:0] pc;
        logic [31:0] inst;
        logic [$clog2(`ROB_LEN)-1:0]  rob_idx;
        
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
    insn_track_t insn_tracker [0:63];
    logic [6:0] opcode;
    logic [4:0] rd    ;
    logic [2:0] funct3;
    logic [4:0] rs1   ;
    logic [4:0] rs2   ;
    logic [4:0] rs3   ;
    logic [6:0] funct7;

    logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j, imm_csr;
    string opname;

    // =======================================================================
    // Helper Function: Decode Opcode to String (Support RV32IMF + CSR)
    // =======================================================================
    function string get_instr_str(input logic [31:0] inst);
        logic [6:0] opcode; 
        logic [2:0] f3    ; 
        logic [6:0] f7    ; 
        logic [4:0] rs2   ; 

        opcode = inst[6:0];
        f3     = inst[14:12];
        f7     = inst[31:25];
        rs2    = inst[24:20]; // Used for some FP and System ops

        case (opcode)
            // ---------------------------
            // RV32I Base Integer
            // ---------------------------
            7'b0110111: return "lui";
            7'b0010111: return "auipc";
            7'b1101111: return "jal";
            7'b1100111: return "jalr";
            
            7'b1100011: begin // Branch
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

            7'b0000011: begin // Load
                case (f3)
                    3'b000: return "lb";
                    3'b001: return "lh";
                    3'b010: return "lw";
                    3'b100: return "lbu";
                    3'b101: return "lhu";
                    default: return "load";
                endcase
            end

            7'b0100011: begin // Store
                case (f3)
                    3'b000: return "sb";
                    3'b001: return "sh";
                    3'b010: return "sw";
                    default: return "store";
                endcase
            end

            7'b0010011: begin // OP-IMM
                case (f3)
                    3'b000: return "addi";
                    3'b010: return "slti";
                    3'b011: return "sltiu";
                    3'b100: return "xori";
                    3'b110: return "ori";
                    3'b111: return "andi";
                    3'b001: return "slli";
                    3'b101: return (f7[5]) ? "srai" : "srli";
                    default: return "op-imm";
                endcase
            end

            7'b0110011: begin // OP (Integar + M Extension)
                if (f7 == 7'b0000001) begin // RV32M
                    case (f3)
                        3'b000: return "mul";
                        3'b001: return "mulh";
                        3'b010: return "mulhsu";
                        3'b011: return "mulhu";
                        3'b100: return "div";
                        3'b101: return "divu";
                        3'b110: return "rem";
                        3'b111: return "remu";
                        default: return "mul/div";
                    endcase
                end else begin // RV32I
                    case (f3)
                        3'b000: return (f7[5]) ? "sub" : "add";
                        3'b001: return "sll";
                        3'b010: return "slt";
                        3'b011: return "sltu";
                        3'b100: return "xor";
                        3'b101: return (f7[5]) ? "sra" : "srl";
                        3'b110: return "or";
                        3'b111: return "and";
                        default: return "op";
                    endcase
                end
            end

            7'b0001111: return "fence"; // Fence

            // ---------------------------
            // System / CSR
            // ---------------------------
            7'b1110011: begin
                case (f3)
                    3'b000: begin
                        if (inst[31:20] == 12'h000) return "ecall";
                        if (inst[31:20] == 12'h001) return "ebreak";
                        if (inst[31:20] == 12'h302) return "mret";
                        if (inst[31:20] == 12'h102) return "sret";
                        if (inst[31:20] == 12'h002) return "uret";
                        if (inst[31:20] == 12'h105) return "wfi";
                        return "system";
                    end
                    3'b001: return "csrrw";
                    3'b010: return "csrrs";
                    3'b011: return "csrrc";
                    3'b101: return "csrrwi";
                    3'b110: return "csrrsi";
                    3'b111: return "csrrci";
                    default: return "system";
                endcase
            end

            // ---------------------------
            // RV32F Floating Point
            // ---------------------------
            7'b0000111: return "flw";
            7'b0100111: return "fsw";
            
            7'b1000011: return "fmadd.s";
            7'b1000111: return "fmsub.s";
            7'b1001011: return "fnmsub.s";
            7'b1001111: return "fnmadd.s";

            7'b1010011: begin // OP-FP
                case (f7)
                    7'b0000000: return "fadd.s";
                    7'b0000100: return "fsub.s";
                    7'b0001000: return "fmul.s";
                    7'b0001100: return "fdiv.s";
                    7'b0101100: return "fsqrt.s";
                    7'b0010000: begin
                        case (f3)
                            3'b000: return "fsgnj.s";
                            3'b001: return "fsgnjn.s";
                            3'b010: return "fsgnjx.s";
                            default: return "fsgnj";
                        endcase
                    end
                    7'b0010100: return (f3 == 0) ? "fmin.s" : "fmax.s";
                    7'b1100000: begin // FCVT.W.S / FCVT.WU.S
                        return (rs2 == 0) ? "fcvt.w.s" : "fcvt.wu.s";
                    end
                    7'b1101000: begin // FCVT.S.W / FCVT.S.WU
                        return (rs2 == 0) ? "fcvt.s.w" : "fcvt.s.wu";
                    end
                    7'b1010000: begin // FCMP
                        case (f3)
                            3'b010: return "feq.s";
                            3'b001: return "flt.s";
                            3'b000: return "fle.s";
                            default: return "fcmp";
                        endcase
                    end
                    7'b1110000: return (f3 == 0) ? "fmv.x.w" : "fclass.s";
                    7'b1111000: return "fmv.w.x"; 
                    default: return "fop";
                endcase
            end

            default: return "unknown";
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
            for (int i = 0; i < 64; i++) begin
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
                for (int i = 0; i < 64; i++) begin
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
            for (int i = 0; i < 64; i++) begin
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
            for (int i = 0; i < 64; i++) begin
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
                for (int i = 0; i < 64; i++) begin
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
                for (int i = 0; i < 64; i++) begin
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
            if (DC_valid) begin
                for (int i = 0; i < 64; i++) begin
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
                for (int i = 0; i < 64; i++) begin
                    if (insn_tracker[i].valid && 
                        insn_tracker[i].if_started && 
                        !insn_tracker[i].dc_started &&
                        insn_tracker[i].pc == IF_out_pc) begin
                        
                        // 1. Update instruction word in tracker
                        insn_tracker[i].inst = IF_out_inst;

                        // 2. Decode and Log
                        begin
                            // Local variables for decoding fields
                            opcode = IF_out_inst[6:0];
                            rd     = IF_out_inst[11:7];
                            funct3 = IF_out_inst[14:12];
                            rs1    = IF_out_inst[19:15];
                            rs2    = IF_out_inst[24:20];
                            rs3    = IF_out_inst[31:27]; // For R4-type
                            funct7 = IF_out_inst[31:25];
                            

                            // Calculate Immediates
                            imm_i   = {{20{IF_out_inst[31]}}, IF_out_inst[31:20]};
                            imm_s   = {{20{IF_out_inst[31]}}, IF_out_inst[31:25], IF_out_inst[11:7]};
                            imm_b   = {{19{IF_out_inst[31]}}, IF_out_inst[31], IF_out_inst[7], IF_out_inst[30:25], IF_out_inst[11:8], 1'b0};
                            imm_u   = {IF_out_inst[31:12], 12'b0};
                            imm_j   = {{12{IF_out_inst[31]}}, IF_out_inst[19:12], IF_out_inst[20], IF_out_inst[30:21], 1'b0};
                            imm_csr = {20'b0, IF_out_inst[31:20]}; // Zero extended for printing

                            // Get Opcode String
                            opname = get_instr_str(IF_out_inst);

                            // Log Header: "L id 0 pc: hex asm_string"
                            $fwrite(fd, "L\t%0d\t0\t%-3h: %08h ", insn_tracker[i].id, IF_out_pc, IF_out_inst);

                            // Format Arguments based on Opcode Type
                            case (opcode)
                                // --- Integer Register-Register (R-Type) ---
                                7'b0110011: $fwrite(fd, "%-5s x%0d, x%0d, x%0d\n", opname, rd, rs1, rs2);
                                
                                // --- Integer Register-Immediate (I-Type) ---
                                7'b0010011: begin
                                    // Shift instructions use shamt (rs2), others use imm_i
                                    if(funct3 == 3'b001 || funct3 == 3'b101) 
                                        $fwrite(fd, "%-5s x%0d, x%0d, 0x%0h\n", opname, rd, rs1, rs2);
                                    else
                                        $fwrite(fd, "%-5s x%0d, x%0d, %0d\n", opname, rd, rs1, $signed(imm_i));
                                end
                                
                                // --- Loads (I-Type) ---
                                7'b0000011: $fwrite(fd, "%-5s x%0d, %0d(x%0d)\n", opname, rd, $signed(imm_i), rs1);
                                
                                // --- Stores (S-Type) ---
                                7'b0100011: $fwrite(fd, "%-5s x%0d, %0d(x%0d)\n", opname, rs2, $signed(imm_s), rs1);
                                
                                // --- Branch (B-Type) ---
                                7'b1100011: $fwrite(fd, "%-5s x%0d, x%0d, %0h\n", opname, rs1, rs2, $signed(imm_b + IF_out_pc));
                                
                                // --- JAL (J-Type) ---
                                7'b1101111: $fwrite(fd, "%-5s x%0d, %0h\n", opname, rd, $signed(imm_j + IF_out_pc));
                                
                                // --- JALR (I-Type) ---
                                7'b1100111: $fwrite(fd, "%-5s x%0d, %0d(x%0d)\n", opname, rd, $signed(imm_i), rs1);
                                
                                // --- LUI, AUIPC (U-Type) ---
                                7'b0110111, 
                                7'b0010111: $fwrite(fd, "%-5s x%0d, 0x%0h\n", opname, rd, imm_u[31:12]);

                                // --- System / CSR ---
                                7'b1110011: begin
                                    if (funct3 == 0) // ecall, ebreak, mret...
                                        $fwrite(fd, "%-5s\n", opname);
                                    else if (funct3[2] == 0) // csrrw, csrrs, csrrc (Register)
                                        $fwrite(fd, "%-5s x%0d, 0x%03h, x%0d\n", opname, rd, imm_csr[11:0], rs1);
                                    else // csrrwi, csrrsi, csrrci (Immediate)
                                        $fwrite(fd, "%-5s x%0d, 0x%03h, 0x%0h\n", opname, rd, imm_csr[11:0], rs1); // rs1 here holds uimm
                                end

                                // --- FP Load (I-Type) ---
                                7'b0000111: $fwrite(fd, "%-5s f%0d, %0d(x%0d)\n", opname, rd, $signed(imm_i), rs1);
                                
                                // --- FP Store (S-Type) ---
                                7'b0100111: $fwrite(fd, "%-5s f%0d, %0d(x%0d)\n", opname, rs2, $signed(imm_s), rs1);

                                // --- FP Comp/Move (R-Type: F-X or X-F) ---
                                // fmv.x.w, fclass.s, fcmp (rd is Int, rs1/2 are FP)
                                // fmv.w.x (rd is FP, rs1 is Int)
                                
                                // --- FP Arith (R-Type: rd, rs1, rs2 all FP) ---
                                7'b1010011: begin
                                    // Handle Special Cases for FMV/FCVT where src/dst types differ
                                    if (funct7 == 7'b1110000 && funct3 == 0) // fmv.x.w
                                        $fwrite(fd, "%-5s x%0d, f%0d\n", opname, rd, rs1);
                                    else if (funct7 == 7'b1010000) // feq, flt, fle (compare)
                                        $fwrite(fd, "%-5s x%0d, f%0d, f%0d\n", opname, rd, rs1, rs2);
                                    else if (funct7 == 7'b1100000 || funct7 == 7'b1101000) // fcvt.w.s / fcvt.s.w
                                        if (rs2 == 1) // w.s (FP to Int)
                                            $fwrite(fd, "%-5s x%0d, f%0d\n", opname, rd, rs1);
                                        else // s.w (Int to FP)
                                            $fwrite(fd, "%-5s f%0d, x%0d\n", opname, rd, rs1);
                                    else if (funct7 == 7'b1111000) // fmv.w.x
                                        $fwrite(fd, "%-5s f%0d, x%0d\n", opname, rd, rs1);
                                    else // Standard FP ops (fadd, fsub...)
                                        $fwrite(fd, "%-5s f%0d, f%0d, f%0d\n", opname, rd, rs1, rs2);
                                end

                                // --- FP Fused Multiply-Add (R4-Type) ---
                                7'b1000011, 
                                7'b1000111, 
                                7'b1001011, 
                                7'b1001111: $fwrite(fd, "%-5s f%0d, f%0d, f%0d, f%0d\n", opname, rd, rs1, rs2, rs3);

                                default: $fwrite(fd, "unknown op: %h\n", opcode);
                            endcase
                        end // End Decode Block

                        // Log Konata specific stage start commands
                        $fwrite(fd, "S\t%0d\t0\tDD\n", insn_tracker[i].id);
                        insn_tracker[i].dc_started  <= 1'b1;
                        insn_tracker[i].rob_idx     <= ROB_tail;
                        $fwrite(fd, "L\t%0d\t1\tROB[%0d]\n", insn_tracker[i].id, ROB_tail);
                        
                        break;
                    end
                end
            end

            // ========================================
            // Stage 1: Instruction Fetch
            // ========================================
            // Find free slot in tracker
            if(fetch_request) begin
                for (int i = 0; i < 64; i++) begin
                    if (insn_tracker[i].valid == 0) begin
                        // I command: Start new instruction
                        $fwrite(fd, "I\t%0d\t%0d\t0\n", insn_id, insn_id);
                        // S command: Start IF stage
                        $fwrite(fd, "S\t%0d\t0\tIF\n", insn_id);
                        // Initialize tracker entry
                        insn_tracker[i].valid       <= 1'b1;
                        insn_tracker[i].id          <= insn_id;
                        insn_tracker[i].pc          <= fetch_addr;
                        insn_tracker[i].if_started  <= 1'b1;
                        insn_id++;

                        break;
                    end
                end
            end

            // ========================================
            // Handle mispredict flushes
            // ========================================    
            if(mispredict) begin
                for(int i = 0; i < 64; i++) begin
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
                        !insn_tracker[i].dc_started && insn_tracker[i].id < insn_id) begin
                        insn_tracker[i].retired <= 1'b1;
                        insn_tracker[i].flushed <= 1'b1;
                    end
                end
            end

            // ========================================
            // Retired 
            // ========================================
            for (int i = 0; i < 64; i++) begin
                if (insn_tracker[i].valid && insn_tracker[i].retired) begin
                    // R command: 
                    $fwrite(fd, "R\t%0d\t0\t%d\n", insn_tracker[i].id, insn_tracker[i].flushed);
                    insn_tracker[i] <= 'b0;
                    retire_id = retire_id + !insn_tracker[i].flushed;
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
