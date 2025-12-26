`ifndef RESET_ADDR
    `define RESET_ADDR 32'h0000_2000  // 這是預設值，當 Makefile 沒傳參數時使用
`endif

// Issue Queue
`define IQ_LEN      4

// Load Queue
`define LQ_LEN      4

// Store Queue
`define SQ_LEN      4

// Reorder Buffer
`define ROB_LEN     8

// Inst Queue
`define INST_QUEUE_LEN 8