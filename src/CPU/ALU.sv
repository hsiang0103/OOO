module ALU (
    // data
    input   logic           [4:0]   opcode,
    input   logic           [2:0]   funct3,
    input   logic                   funct7,
    input   logic signed    [31:0]  rs1_data,
    input   logic signed    [31:0]  rs2_data,
    input   logic signed    [31:0]  imm,
    input   logic           [31:0]  pc,
    // control
    input   logic                   alu_i_valid,
    input   logic           [$clog2(`ROB_LEN)-1:0]   alu_i_rob_idx,
    input   logic           [6:0]   alu_i_rd,
    output  logic                   alu_o_valid,
    output  logic           [$clog2(`ROB_LEN)-1:0]   alu_o_rob_idx,
    output  logic           [6:0]   alu_o_rd,
    output  logic           [31:0]  alu_o_data,
    // jump
    output  logic           [31:0]  alu_jb_out,
    output  logic                   jump
);
    // =============
    //      ALU
    // =============

    logic signed [31:0] operand1, operand2;
    logic signed [31:0] alu_out;

    always_comb begin
        operand1 = rs1_data;
        operand2 = (opcode == `I_TYPE)? imm : rs2_data;

        case (opcode)
            `R_TYPE, `I_TYPE: begin
                unique case (funct3)
                    `ADD: begin
                        if(opcode == `I_TYPE) begin
                            alu_out = operand1 + operand2;
                        end
                        else begin
                            alu_out = (funct7)? operand1 - operand2 : operand1 + operand2; 
                        end
                    end
                    `SLL:   alu_out = operand1 << operand2[4:0];
                    `SLT:   alu_out = (operand1 < operand2)? 32'd1 : 32'd0; 
                    `SLTU:  alu_out = ($unsigned(operand1) < $unsigned(operand2))? 32'd1 : 32'd0;
                    `XOR:   alu_out = operand1 ^ operand2;
                    `SRL:   alu_out = (funct7)? $signed(operand1) >>> operand2[4:0] : operand1 >> operand2[4:0]; 
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
            default: alu_out = 32'b0;
        endcase
        
        case(opcode) 
            `JAL:       alu_jb_out = pc + imm;
            `JALR:      alu_jb_out = (rs1_data + imm) & 32'hfffffffe;
            `B_TYPE:    alu_jb_out = alu_out[0] ? pc + imm : pc + 32'd4;
            default:    alu_jb_out = 32'b0;
        endcase

        if(alu_i_valid) begin
            case (opcode)
                `JAL:       jump = 1'b1;
                `JALR:      jump = 1'b1;
                `B_TYPE:    jump = alu_out[0];
                default:    jump = 1'b0;
            endcase
        end
        else begin
            jump = 1'b0;
        end

        alu_o_rob_idx   = alu_i_rob_idx;
        alu_o_valid     = alu_i_valid && opcode != `B_TYPE/* && alu_i_rd != 7'd0*/;
        alu_o_rd        = alu_i_rd;
        alu_o_data      = /*(opcode == `CSR)? CSR_out : */alu_out;
    end
endmodule