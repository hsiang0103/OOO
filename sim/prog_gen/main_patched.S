.globl init
.include "user_define.h"

.section .text
.option norvc;
_rv_gen_start:           
                  .include "user_init.s"
                  csrr x5, 0xf14
                  li x6, 0
                  beq x5, x6, 0f

0: nop
nop
h0_rv_gen_start:
                  li x13, 0x40000100
                  csrw 0x301, x13
kernel_sp:        
                  la x21, kernel_stack_end

trap_vec_init:    
                  la x13, mtvec_handler
                  ori x13, x13, 0
                  csrw 0x305, x13 # MTVEC

mepc_setup:       
                  la x13, init
                  csrw 0x341, x13

custom_csr_setup: 
                  nop

init_machine_mode:
                  li x13, 0x1800
                  csrw 0x300, x13 # MSTATUS
                  li x13, 0x0
                  csrw 0x304, x13 # MIE
                  mret
init:             
                  li x0, 0xf2f5e6d6
                  li x1, 0xf
                  li x2, 0xf
                  li x3, 0xf075f496
                  li x4, 0x9164c2d4
                  li x5, 0x4a46ed64
                  li x6, 0x2
                  li x7, 0x0
                  li x8, 0x0
                  li x9, 0x0
                  li x10, 0x80000000
                  li x11, 0x80000000
                  li x12, 0x80000000
                  li x13, 0xfdbff12e
                  li x14, 0xf6f97154
                  li x16, 0x9d611c8c
                  li x17, 0xfe4fd3b3
                  li x18, 0xfa94c63f
                  li x19, 0x80000000
                  li x20, 0x8
                  li x22, 0x504bb4b3
                  li x23, 0xae3186c2
                  li x24, 0xf6fffd98
                  li x25, 0x6
                  li x26, 0x80000000
                  li x27, 0xd
                  li x28, 0x0
                  li x29, 0x80000000
                  li x30, 0xe18eef13
                  li x31, 0x604871f4
                  la x15, user_stack_end
main:             la           s7, sub_1
                  and          s4, gp, ra
                  srl          t3, a2, t3
                  slt          tp, s8, s11
                  nop
                  xor          a2, s10, a5
                  or           t4, zero, s1
                  add          sp, s7, a2
                  addi         s7, s7, -167
                  sra          a6, tp, s11
                  sltiu        s6, s10, -1002
                  slli         a4, s5, 23
main_j2:          jalr         t1, s7, 168 #jump main -> sub_1
                  la           tp, sub_2
                  and          zero, ra, s10
                  slt          a4, t3, a7
                  nop
                  addi         tp, tp, 74
                  beq          s6, t6, main_j3 #branch to jump instr
                  sub          t0, t0, zero
                  nop
main_j3:          jalr         t1, tp, -73 #jump main -> sub_2
                  li           a2, 0x91c1bc72 #start riscv_int_numeric_corner_stream_0
                  li           s3, 0x4ce6b637
                  li           t0, 0x0
                  li           s4, 0x80000000
                  li           t3, 0x13645dde
                  li           s10, 0x0
                  li           a4, 0x80000000
                  li           t5, 0x80000000
                  li           a6, 0x80000000
                  li           s0, 0xffffffff
                  sub          s0, a2, t0
                  sub          s4, s4, a2
                  auipc        s0, 969597
                  addi         s4, t5, -704
                  addi         s3, s3, -860
                  addi         a6, s4, 1361
                  lui          t3, 460048
                  nop
                  sub          s3, a2, a6
                  add          a6, s10, s4
                  auipc        t3, 669501
                  nop
                  add          s0, a6, s10
                  lui          a4, 267919
                  auipc        t3, 688802
                  auipc        s10, 12680
                  lui          t0, 71101 #end riscv_int_numeric_corner_stream_0
                  sltiu        t1, a6, 1227
                  or           t3, t0, a0
                  slt          a1, a1, t6
                  xori         a2, sp, -1789
                  and          gp, t6, s2
                  slti         a6, t2, 678
                  lui          t3, 353480
                  xor          s4, s3, s4
                  srli         sp, a5, 21
                  la           s10, sub_1
                  sll          s2, a0, s5
                  sltu         s0, a2, s10
                  addi         s10, s10, -415
                  nop
                  slt          sp, s11, gp
                  xor          zero, s10, t2
main_j1:          jalr         t1, s10, 415 #jump main -> sub_1
                  and          tp, s11, s7
                  or           s6, s5, t2
                  ori          s6, a3, -1827
                  slt          t3, a2, t3
                  la x31, test_done
                  nop
test_done:        
                  li gp, 1
                  j SystemExit
sub_5:            addi         a5, a5, -36
                  sll          s8, s7, s9
                  sw           t1, 4(a5)
                  slli         a0, s4, 28
                  sub          t3, s2, t5
                  auipc        a0, 427537
                  auipc        s10, 15724
                  ori          s8, s6, 321
                  xori         s4, t0, 1243
                  srl          t5, s5, gp
                  sub          s1, t4, t3
                  or           s2, a1, t1
                  add          a6, a1, t2
                  nop
                  add          s11, ra, t5
                  xor          s2, s0, t3
                  addi         t4, s10, -1333
                  sll          a0, a4, gp
                  ori          a4, a2, -301
                  and          gp, gp, s9
                  ori          t3, a3, -1014
                  xori         s8, a5, -1811
                  sltiu        t3, a7, -1504
                  sltu         sp, t2, s10
                  xori         gp, a0, 373
                  xori         a2, s6, 1947
                  or           a3, t4, s9
                  and          s6, a3, a3
                  slli         t0, t0, 4
                  sltiu        zero, s2, -865
                  lw           t1, 4(a5)
                  sub          s3, gp, t4
                  auipc        s0, 284758
                  addi         a5, a5, 36
                  sltiu        a4, a6, 631
                  xori         zero, t3, 754
                  srai         zero, s0, 0
                  or           s1, sp, a5
38:               addi x5, x6, 0
38:               jalr x5, x5, 0
sub_2:            xori         s0, a3, -1689
                  sltu         s8, s0, s10
                  srai         t5, a4, 15
                  sub          a6, s11, sp
                  nop
                  addi         a5, a5, -36
                  nop
                  sw           t1, 4(a5)
                  slt          gp, s9, t0
                  xori         t2, s1, 1915
                  lui          a3, 493860
                  auipc        s3, 249624
                  add          ra, t6, s10
                  xori         t5, t1, -2014
                  sll          s9, a5, s9
                  srai         s8, t2, 10
                  lui          s10, 758333
                  srai         a1, a1, 8
                  srli         t1, s8, 8
                  auipc        t1, 457267
                  or           s9, t5, t1
                  nop
                  sra          t5, t2, zero
                  lw           t1, 4(a5)
                  ori          s6, a0, -1627
                  xor          a1, sp, s11
                  xori         a1, t2, -373
                  lui          s7, 734399
                  addi         a5, a5, 36
                  auipc        a7, 660453
30:               addi x25, x6, 0
30:               jalr x25, x25, 0
sub_1:            srl          s4, s1, a4
                  or           tp, s4, s0
                  addi         a5, a5, -40
                  sw           t1, 4(a5)
                  auipc        t5, 400699
                  auipc        s7, 526940
                  sltu         s2, t6, s0
                  slti         a1, t6, 454
                  add          s0, a4, t6
                  nop
                  sub          sp, t2, t0
                  or           s8, gp, s8
                  sltu         t4, a0, s5
                  srl          t3, s2, gp
                  slt          a0, s2, s4
                  srl          s3, s10, sp
sub_1_j4:         jal          t1, sub_3 #jump sub_1 -> sub_3
                  srai         zero, s11, 31
                  la           s2, sub_3
                  addi         s2, s2, -251
                  sltiu        a7, zero, -1412
                  sll          t5, s1, a5
                  and          a0, a3, tp
                  beq          a0, s0, sub_1_j5 #branch to jump instr
                  andi         a7, t2, -394
                  srl          t3, s7, s9
                  ori          gp, gp, 1195
                  auipc        a2, 1015128
sub_1_j5:         jalr         t1, s2, 252 #jump sub_1 -> sub_3
                  or           s3, s10, sp
                  add          s7, a3, tp
                  srai         t4, sp, 17
                  or           t3, a4, s0
                  sltiu        s10, s9, 1292
                  xor          t5, a2, s8
                  auipc        s0, 254979
                  ori          t2, a7, 1104
                  sra          t4, s7, t6
                  sra          t0, s10, a2
                  slt          t5, a7, a4
                  nop
                  add          a4, t3, zero
                  sub          ra, t3, ra
                  srai         s7, gp, 3
                  xor          s1, a1, s9
                  or           s7, t2, a7
                  lw           t1, 4(a5)
                  and          s2, s2, a6
                  sub          s3, s8, a6
                  slt          s6, ra, gp
                  slti         s11, t4, -1123
                  sra          tp, s8, a6
                  xor          a4, gp, t2
                  addi         a5, a5, 40
                  add          a7, a2, a2
55:               addi x30, x6, 1
55:               jalr x30, x30, 0
sub_3:            auipc        t4, 606417
                  addi         a5, a5, -64
                  sll          t0, a7, t2
                  sw           t1, 4(a5)
                  srai         s3, a2, 21
                  nop
                  slt          t5, a4, t0
                  auipc        t3, 796418
                  srai         s8, a5, 8
                  srli         a2, a1, 22
                  srai         s8, s7, 3
                  slti         s0, zero, 2022
                  sub          a7, t4, a5
sub_3_j6:         jal          t1, sub_4 #jump sub_3 -> sub_4
                  sll          a4, s11, a2
                  lui          s9, 884866
                  lui          s10, 674220
                  srl          t2, t3, t6
                  srl          a6, s8, t3
                  slti         a4, t6, 1555
                  nop
                  srl          s0, s5, a7
                  and          tp, gp, a7
                  sltu         sp, t6, sp
                  addi         s6, a2, -1135
                  or           t4, a6, s7
                  ori          a7, s3, 150
                  lui          t0, 744081
                  slt          s2, a5, s3
                  or           s2, s9, a1
                  xori         s7, s11, 1920
                  or           ra, s0, s6
                  add          s0, t4, s8
                  xor          t4, tp, a5
                  auipc        ra, 313932
                  nop
                  nop
                  auipc        t4, 578194
                  lw           t1, 4(a5)
                  sll          s3, s8, a7
                  slti         a2, t1, 1044
                  nop
                  sra          s3, a1, s11
                  lui          t2, 679185
                  addi         a5, a5, 64
                  srl          s0, t1, t4
46:               addi x30, x6, 1
46:               jalr x30, x30, 0
sub_4:            addi         a5, a5, -36
                  xor          s9, ra, s1
                  ori          s6, t4, -679
                  sw           t1, 4(a5)
                  xor          a6, s3, tp
                  ori          gp, s4, -500
                  xori         tp, s6, -167
                  lui          s6, 315841
                  sub          s6, s8, s10
                  xor          a7, a1, t0
                  sub          a7, a5, a4
                  and          t5, a3, s1
                  xori         s4, t1, 372
                  nop
                  sub          s7, a4, t0
                  auipc        a0, 946157
                  xor          sp, a3, a7
                  srl          t5, s2, a4
                  auipc        ra, 217601
                  add          ra, s3, a5
sub_4_j7:         jal          t1, sub_5 #jump sub_4 -> sub_5
                  auipc        s2, 413527
                  auipc        a4, 1038641
                  or           t3, s7, s7
                  srli         s4, gp, 14
                  sub          s1, tp, s3
                  slt          a0, a6, s3
                  and          zero, tp, t1
                  or           tp, a7, t1
                  sll          s9, zero, t5
sub_4_j8:         jal          t1, sub_5 #jump sub_4 -> sub_5
                  srai         gp, s6, 6
                  sltiu        s7, t6, 754
                  slli         s0, t5, 2
                  or           a6, a4, a4
                  slli         s0, gp, 2
                  sub          t2, s4, t3
                  auipc        s2, 44233
                  srli         s8, s6, 14
                  nop
                  xori         s10, t0, -263
                  slti         t5, zero, 250
                  and          sp, s11, t6
                  or           tp, s7, a0
                  xor          zero, t6, s9
                  ori          s0, zero, -1512
                  slli         a3, s8, 19
                  lui          t1, 266121
                  lui          a3, 894063
                  sltiu        t5, t4, 54
                  lw           t1, 4(a5)
                  sltu         a6, tp, t2
                  addi         a5, a5, 36
                  srli         s10, s0, 8
                  xor          ra, t5, a1
                  ori          s0, t4, -1638
56:               addi x2, x6, 0
56:               jalr x2, x2, 0
write_tohost:     
                  sw gp, tohost, t5

_exit:            
                  j write_tohost

instr_end:        
                  nop

.section .data


.section .user_stack,"aw",@progbits;
.align 2
user_stack_rv_gen_start:
.rept 128
.4byte 0x0
.endr
user_stack_end:
.4byte 0x0
.align 2
kernel_instr_rv_gen_start:
.text
.align           2
mtvec_handler:    
                  addi x21, x21, -4
                  sw  x15, (x21)
                  add x15, x21, zero
                  addi x15, x15, -128
                  sw  x1, 4(x15)
                  sw  x2, 8(x15)
                  sw  x3, 12(x15)
                  sw  x4, 16(x15)
                  sw  x5, 20(x15)
                  sw  x6, 24(x15)
                  sw  x7, 28(x15)
                  sw  x8, 32(x15)
                  sw  x9, 36(x15)
                  sw  x10, 40(x15)
                  sw  x11, 44(x15)
                  sw  x12, 48(x15)
                  sw  x13, 52(x15)
                  sw  x14, 56(x15)
                  sw  x15, 60(x15)
                  sw  x16, 64(x15)
                  sw  x17, 68(x15)
                  sw  x18, 72(x15)
                  sw  x19, 76(x15)
                  sw  x20, 80(x15)
                  sw  x21, 84(x15)
                  sw  x22, 88(x15)
                  sw  x23, 92(x15)
                  sw  x24, 96(x15)
                  sw  x25, 100(x15)
                  sw  x26, 104(x15)
                  sw  x27, 108(x15)
                  sw  x28, 112(x15)
                  sw  x29, 116(x15)
                  sw  x30, 120(x15)
                  sw  x31, 124(x15)
                  add x21, x15, zero
                  csrr x13, 0x300 # MSTATUS
                  csrr x13, 0x342 # MCAUSE
                  srli x13, x13, 31
                  bne x13, x0, mmode_intr_handler

mmode_exception_handler:
                  csrr x13, 0x341 # MEPC
                  csrr x13, 0x342 # MCAUSE
                  li x10, 0x3 # BREAKPOINT
                  beq x13, x10, ebreak_handler
                  li x10, 0x8 # ECALL_UMODE
                  beq x13, x10, ecall_handler
                  li x10, 0x9 # ECALL_SMODE
                  beq x13, x10, ecall_handler
                  li x10, 0xb # ECALL_MMODE
                  beq x13, x10, ecall_handler
                  li x10, 0x1
                  beq x13, x10, instr_fault_handler
                  li x10, 0x5
                  beq x13, x10, load_fault_handler
                  li x10, 0x7
                  beq x13, x10, store_fault_handler
                  li x10, 0xc
                  beq x13, x10, pt_fault_handler
                  li x10, 0xd
                  beq x13, x10, pt_fault_handler
                  li x10, 0xf
                  beq x13, x10, pt_fault_handler
                  li x10, 0x2 # ILLEGAL_INSTRUCTION
                  beq x13, x10, illegal_instr_handler
                  csrr x10, 0x343 # MTVAL
                  1: la x31, test_done
                  jalr x1, x31, 0

ecall_handler:    
                  la x13, _start
                  sw x0, 0(x13)
                  sw x1, 4(x13)
                  sw x2, 8(x13)
                  sw x3, 12(x13)
                  sw x4, 16(x13)
                  sw x5, 20(x13)
                  sw x6, 24(x13)
                  sw x7, 28(x13)
                  sw x8, 32(x13)
                  sw x9, 36(x13)
                  sw x10, 40(x13)
                  sw x11, 44(x13)
                  sw x12, 48(x13)
                  sw x13, 52(x13)
                  sw x14, 56(x13)
                  sw x15, 60(x13)
                  sw x16, 64(x13)
                  sw x17, 68(x13)
                  sw x18, 72(x13)
                  sw x19, 76(x13)
                  sw x20, 80(x13)
                  sw x21, 84(x13)
                  sw x22, 88(x13)
                  sw x23, 92(x13)
                  sw x24, 96(x13)
                  sw x25, 100(x13)
                  sw x26, 104(x13)
                  sw x27, 108(x13)
                  sw x28, 112(x13)
                  sw x29, 116(x13)
                  sw x30, 120(x13)
                  sw x31, 124(x13)
                  la x31, write_tohost
                  nop

instr_fault_handler:
                  add x15, x21, zero
                  lw  x1, 4(x15)
                  lw  x2, 8(x15)
                  lw  x3, 12(x15)
                  lw  x4, 16(x15)
                  lw  x5, 20(x15)
                  lw  x6, 24(x15)
                  lw  x7, 28(x15)
                  lw  x8, 32(x15)
                  lw  x9, 36(x15)
                  lw  x10, 40(x15)
                  lw  x11, 44(x15)
                  lw  x12, 48(x15)
                  lw  x13, 52(x15)
                  lw  x14, 56(x15)
                  lw  x15, 60(x15)
                  lw  x16, 64(x15)
                  lw  x17, 68(x15)
                  lw  x18, 72(x15)
                  lw  x19, 76(x15)
                  lw  x20, 80(x15)
                  lw  x21, 84(x15)
                  lw  x22, 88(x15)
                  lw  x23, 92(x15)
                  lw  x24, 96(x15)
                  lw  x25, 100(x15)
                  lw  x26, 104(x15)
                  lw  x27, 108(x15)
                  lw  x28, 112(x15)
                  lw  x29, 116(x15)
                  lw  x30, 120(x15)
                  lw  x31, 124(x15)
                  addi x15, x15, 128
                  add x21, x15, zero
                  lw  x15, (x21)
                  addi x21, x21, 4
                  mret

load_fault_handler:
                  add x15, x21, zero
                  lw  x1, 4(x15)
                  lw  x2, 8(x15)
                  lw  x3, 12(x15)
                  lw  x4, 16(x15)
                  lw  x5, 20(x15)
                  lw  x6, 24(x15)
                  lw  x7, 28(x15)
                  lw  x8, 32(x15)
                  lw  x9, 36(x15)
                  lw  x10, 40(x15)
                  lw  x11, 44(x15)
                  lw  x12, 48(x15)
                  lw  x13, 52(x15)
                  lw  x14, 56(x15)
                  lw  x15, 60(x15)
                  lw  x16, 64(x15)
                  lw  x17, 68(x15)
                  lw  x18, 72(x15)
                  lw  x19, 76(x15)
                  lw  x20, 80(x15)
                  lw  x21, 84(x15)
                  lw  x22, 88(x15)
                  lw  x23, 92(x15)
                  lw  x24, 96(x15)
                  lw  x25, 100(x15)
                  lw  x26, 104(x15)
                  lw  x27, 108(x15)
                  lw  x28, 112(x15)
                  lw  x29, 116(x15)
                  lw  x30, 120(x15)
                  lw  x31, 124(x15)
                  addi x15, x15, 128
                  add x21, x15, zero
                  lw  x15, (x21)
                  addi x21, x21, 4
                  mret

store_fault_handler:
                  add x15, x21, zero
                  lw  x1, 4(x15)
                  lw  x2, 8(x15)
                  lw  x3, 12(x15)
                  lw  x4, 16(x15)
                  lw  x5, 20(x15)
                  lw  x6, 24(x15)
                  lw  x7, 28(x15)
                  lw  x8, 32(x15)
                  lw  x9, 36(x15)
                  lw  x10, 40(x15)
                  lw  x11, 44(x15)
                  lw  x12, 48(x15)
                  lw  x13, 52(x15)
                  lw  x14, 56(x15)
                  lw  x15, 60(x15)
                  lw  x16, 64(x15)
                  lw  x17, 68(x15)
                  lw  x18, 72(x15)
                  lw  x19, 76(x15)
                  lw  x20, 80(x15)
                  lw  x21, 84(x15)
                  lw  x22, 88(x15)
                  lw  x23, 92(x15)
                  lw  x24, 96(x15)
                  lw  x25, 100(x15)
                  lw  x26, 104(x15)
                  lw  x27, 108(x15)
                  lw  x28, 112(x15)
                  lw  x29, 116(x15)
                  lw  x30, 120(x15)
                  lw  x31, 124(x15)
                  addi x15, x15, 128
                  add x21, x15, zero
                  lw  x15, (x21)
                  addi x21, x21, 4
                  mret

ebreak_handler:   
                  csrr  x13, 0x341
                  addi  x13, x13, 4
                  csrw  0x341, x13
                  add x15, x21, zero
                  lw  x1, 4(x15)
                  lw  x2, 8(x15)
                  lw  x3, 12(x15)
                  lw  x4, 16(x15)
                  lw  x5, 20(x15)
                  lw  x6, 24(x15)
                  lw  x7, 28(x15)
                  lw  x8, 32(x15)
                  lw  x9, 36(x15)
                  lw  x10, 40(x15)
                  lw  x11, 44(x15)
                  lw  x12, 48(x15)
                  lw  x13, 52(x15)
                  lw  x14, 56(x15)
                  lw  x15, 60(x15)
                  lw  x16, 64(x15)
                  lw  x17, 68(x15)
                  lw  x18, 72(x15)
                  lw  x19, 76(x15)
                  lw  x20, 80(x15)
                  lw  x21, 84(x15)
                  lw  x22, 88(x15)
                  lw  x23, 92(x15)
                  lw  x24, 96(x15)
                  lw  x25, 100(x15)
                  lw  x26, 104(x15)
                  lw  x27, 108(x15)
                  lw  x28, 112(x15)
                  lw  x29, 116(x15)
                  lw  x30, 120(x15)
                  lw  x31, 124(x15)
                  addi x15, x15, 128
                  add x21, x15, zero
                  lw  x15, (x21)
                  addi x21, x21, 4
                  mret

illegal_instr_handler:
                  csrr  x13, 0x341
                  addi  x13, x13, 4
                  csrw  0x341, x13
                  add x15, x21, zero
                  lw  x1, 4(x15)
                  lw  x2, 8(x15)
                  lw  x3, 12(x15)
                  lw  x4, 16(x15)
                  lw  x5, 20(x15)
                  lw  x6, 24(x15)
                  lw  x7, 28(x15)
                  lw  x8, 32(x15)
                  lw  x9, 36(x15)
                  lw  x10, 40(x15)
                  lw  x11, 44(x15)
                  lw  x12, 48(x15)
                  lw  x13, 52(x15)
                  lw  x14, 56(x15)
                  lw  x15, 60(x15)
                  lw  x16, 64(x15)
                  lw  x17, 68(x15)
                  lw  x18, 72(x15)
                  lw  x19, 76(x15)
                  lw  x20, 80(x15)
                  lw  x21, 84(x15)
                  lw  x22, 88(x15)
                  lw  x23, 92(x15)
                  lw  x24, 96(x15)
                  lw  x25, 100(x15)
                  lw  x26, 104(x15)
                  lw  x27, 108(x15)
                  lw  x28, 112(x15)
                  lw  x29, 116(x15)
                  lw  x30, 120(x15)
                  lw  x31, 124(x15)
                  addi x15, x15, 128
                  add x21, x15, zero
                  lw  x15, (x21)
                  addi x21, x21, 4
                  mret

pt_fault_handler: 
                  nop

.align 2
mmode_intr_handler:
                  csrr  x13, 0x300 # MSTATUS;
                  csrr  x13, 0x304 # MIE;
                  csrr  x13, 0x344 # MIP;
                  csrrc x13, 0x344, x13 # MIP;
                  add x15, x21, zero
                  lw  x1, 4(x15)
                  lw  x2, 8(x15)
                  lw  x3, 12(x15)
                  lw  x4, 16(x15)
                  lw  x5, 20(x15)
                  lw  x6, 24(x15)
                  lw  x7, 28(x15)
                  lw  x8, 32(x15)
                  lw  x9, 36(x15)
                  lw  x10, 40(x15)
                  lw  x11, 44(x15)
                  lw  x12, 48(x15)
                  lw  x13, 52(x15)
                  lw  x14, 56(x15)
                  lw  x15, 60(x15)
                  lw  x16, 64(x15)
                  lw  x17, 68(x15)
                  lw  x18, 72(x15)
                  lw  x19, 76(x15)
                  lw  x20, 80(x15)
                  lw  x21, 84(x15)
                  lw  x22, 88(x15)
                  lw  x23, 92(x15)
                  lw  x24, 96(x15)
                  lw  x25, 100(x15)
                  lw  x26, 104(x15)
                  lw  x27, 108(x15)
                  lw  x28, 112(x15)
                  lw  x29, 116(x15)
                  lw  x30, 120(x15)
                  lw  x31, 124(x15)
                  addi x15, x15, 128
                  add x21, x15, zero
                  lw  x15, (x21)
                  addi x21, x21, 4
                  mret;

kernel_instr_end: nop
.section .kernel_stack,"aw",@progbits;
.align 2
kernel_stack_rv_gen_start:
.rept 128
.4byte 0x0
.endr
kernel_stack_end:
.4byte 0x0
