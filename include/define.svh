// opcode
`define LUI     5'b01101
`define AUIPC   5'b00101
`define JAL     5'b11011
`define JALR    5'b11001
`define LOAD    5'b00000
`define FLOAD   5'b00001
`define FSTORE  5'b01001
`define CSR     5'b11100
`define F_TYPE  5'b10100
`define B_TYPE  5'b11000
`define S_TYPE  5'b01000
`define I_TYPE  5'b00100
`define R_TYPE  5'b01100

// funct3
// R-TYPE
`define ADD     3'b000
`define SUB     3'b000
`define SLL     3'b001
`define SLT     3'b010
`define SLTU    3'b011
`define XOR     3'b100
`define SRL     3'b101
`define SRA     3'b101
`define OR      3'b110
`define AND     3'b111
`define MUL     3'b000
`define MULH    3'b001
`define MULHSU  3'b010
`define MULHU   3'b011
// I-TYPE
`define ADDI    3'b000
`define SLLI    3'b001
`define SLTI    3'b010
`define SLTIU   3'b011
`define XORI    3'b100
`define SRLI    3'b101
`define SRAI    3'b101
`define ORI     3'b110
`define ANDI    3'b111
// B-TYPE
`define BEQ     3'b000
`define BNE     3'b001
`define BLT     3'b100
`define BGE     3'b101
`define BLTU    3'b110
`define BGEU    3'b111
// LOAD
`define LB      3'b000
`define LH      3'b001
`define LW      3'b010
`define LBU     3'b100
`define LHU     3'b101
// S-TYPE
`define SB      3'b000
`define SH      3'b001
`define SW      3'b010
// F-TYPE (funct5)
`define FADDS  5'b00000
`define FSUBS  5'b00001



