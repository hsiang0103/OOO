module ALU (
    input logic [4:0] opcode,
    input logic [2:0] funct3,
    input logic funct7,
    input logic signed [31:0] rs1_data,
    input logic signed [31:0] rs2_data,
    input logic signed [31:0] imm,
    input logic        [15:0] pc,

    input logic         alu_start,
    input logic [2:0]   EXE_rob_idx,
    output logic [31:0] alu_out,
    output logic [2:0]  alu_rob_idx,
    output logic [31:0] alu_jb_out, 
    output logic        alu_o_valid,
    output logic        mispredict
);
    logic [31:0] operand1, operand2;

    // ALU operations
    always_comb begin
        case (opcode)
            `I_TYPE: operand2 = imm;
            default: operand2 = rs2_data;
        endcase
        operand1 = rs1_data;

        case (opcode)
            `R_TYPE, `I_TYPE: begin
                unique case (funct3)
                    `ADD: begin
                        if(opcode == `I_TYPE) begin
                            alu_out = rs1_data + imm; // ADDI
                        end
                        else begin
                            alu_out = (funct7)? rs1_data - rs2_data : rs1_data + rs2_data; // SUB ADD
                        end
                    end
                    `SLL:   alu_out = operand1 << operand2[4:0];
                    `SLT:   alu_out = (operand1 < operand2)? 32'd1 : 32'd0; 
                    `SLTU:  alu_out = ($unsigned(operand1) < $unsigned(operand2))? 32'd1 : 32'd0;
                    `XOR:   alu_out = operand1 ^ operand2;
                    `SRL:   alu_out = (funct7)? $signed(operand1) >>> operand2[4:0] : operand1 >> operand2[4:0]; // SRA SRL
                    `OR:    alu_out = operand1 | operand2;
                    `AND:   alu_out = operand1 & operand2;                 
                endcase
            end
            `B_TYPE: begin
                case (funct3)
                    `BEQ:   alu_out = (operand1 == operand2)? 32'd1 : 32'd0;
                    `BNE:   alu_out = (operand1 != operand2)? 32'd1 : 32'd0;
                    `BLT:   alu_out = (operand1 <  operand2)? 32'd1 : 32'd0;
                    `BGE:   alu_out = (operand1 >= operand2)? 32'd1 : 32'd0;
                    `BLTU:  alu_out = ($unsigned(operand1) <  $unsigned(operand2))? 32'd1 : 32'd0;
                    `BGEU:  alu_out = ($unsigned(operand1) >= $unsigned(operand2))? 32'd1 : 32'd0;
                    default: alu_out = 32'b0;
                endcase
            end
            `AUIPC:  alu_out = pc + imm;    // AUIPC
            `JAL:    alu_out = pc + 32'd4;  // JAL
            `JALR:   alu_out = pc + 32'd4;  // JALR
            `LUI:    alu_out = imm;         // LUI
            `CSR:    alu_out = rs1_data;    // CSR
            default: alu_out = 32'b0;
        endcase
        
        case(opcode) 
            `JAL:       alu_jb_out = pc + imm;
            `JALR:      alu_jb_out = (rs1_data + imm) & 16'hfffe;
            `B_TYPE:    alu_jb_out = alu_out ? pc + imm : pc + 32'd4;
            default:    alu_jb_out = 32'b0;
        endcase

        case (opcode)
            `JAL, `JALR:    mispredict = 1'b1;
            `B_TYPE:        mispredict = alu_out ? 1'b1 : 1'b0;
            default:        mispredict = 1'b0;
        endcase

        alu_rob_idx = EXE_rob_idx;
        alu_o_valid = alu_start && opcode != `B_TYPE;
    end
endmodule