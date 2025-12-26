`ifndef RESET_ADDR
    `define RESET_ADDR 32'h0001_0000  // 這是預設值，當 Makefile 沒傳參數時使用
`endif

// Issue Queue
`define IQ_LEN      16

// Load Queue
`define LQ_LEN      16

// Store Queue
`define SQ_LEN      16

// Reorder Buffer
`define ROB_LEN     16

// Inst Queue
`define INST_QUEUE_LEN 16