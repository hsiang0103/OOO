.include "user_define.h"
.globl _start
.section .text
.option norvc;
_start:           
                  .include "user_init.s"
                  csrr x5, 0xf14
                  li x6, 0
                  beq x5, x6, 0f

0: la x22, h0_start
jalr x0, x22, 0
h0_start:
                  li x28, 0x40000100
                  csrw 0x301, x28
kernel_sp:        
                  la x7, kernel_stack_end

trap_vec_init:    
                  la x28, mtvec_handler
                  ori x28, x28, 1
                  csrw 0x305, x28 # MTVEC

mepc_setup:       
                  la x28, init
                  csrw 0x341, x28

custom_csr_setup: 
                  nop

init_machine_mode:
                  li x28, 0x1800
                  csrw 0x300, x28 # MSTATUS
                  li x28, 0x0
                  csrw 0x304, x28 # MIE
                  mret
init:             
                  li x0, 0x44cef0c7
                  li x1, 0x80000000
                  li x2, 0x80000000
                  li x3, 0xf7599b75
                  li x4, 0x6
                  li x5, 0xac4c47bc
                  li x6, 0xb
                  li x8, 0x0
                  li x9, 0x0
                  li x11, 0x4
                  li x12, 0x17a40138
                  li x13, 0xd853da54
                  li x14, 0x6846862e
                  li x15, 0xfb4fdc24
                  li x16, 0xfd4d3c38
                  li x17, 0xd
                  li x18, 0xf386ed2f
                  li x19, 0xf
                  li x20, 0x0
                  li x21, 0x3ae3046f
                  li x22, 0x22b38285
                  li x23, 0xb74d9fd1
                  li x24, 0x716c0c37
                  li x25, 0x42bfb0eb
                  li x26, 0x0
                  li x27, 0x0
                  li x28, 0x9752aeb8
                  li x29, 0x80000000
                  li x30, 0x0
                  li x31, 0xfe94c626
                  la x10, user_stack_end
main:             la           t0, sub_1
                  andi         sp, a7, 1171
                  addi         t0, t0, -64
                  xori         s8, tp, -693
                  nop
                  srai         a2, s10, 22
                  bltu         s9, gp, main_j2 #branch to jump instr
                  xor          s9, t0, t1
                  and          s8, s8, zero
main_j2:          jalr         t1, t0, 65 #jump main -> sub_1
                  addi         gp, zero, 8 #init loop 1 counter
                  and          s5, t1, a6
                  slli         s1, sp, 25
                  slti         a2, s8, -629
                  auipc        zero, 477737
                  and          s1, ra, a7
                  addi         a4, zero, 12 #init loop 1 limit
                  lui          a1, 931226
main_3_1_t:       sltiu        a5, a2, 1145
                  sltiu        a6, a0, -1403
                  xor          a3, s3, s9
                  sltu         s9, s2, a7
                  addi         gp, gp, 3 #update loop 1 counter
                  addi         s4, zero, 7 #init loop 0 counter
                  addi         s9, s7, -10
                  and          s11, a4, t3
                  addi         s3, zero, -1 #init loop 0 limit
                  sltu         a7, t1, s8
main_3_0_t:       sltiu        s10, a4, -381
                  addi         s4, s4, -1 #update loop 0 counter
                  ori          s5, zero, -600
                  ori          t1, s0, -1088
                  bge          s4, s3, main_3_0_t #branch for loop 0
                  ori          t1, a5, 207
                  add          s5, t4, sp
                  sltu         s0, ra, t3
                  blt          gp, a4, main_3_1_t #branch for loop 1
                  andi         s9, zero, 25
main_1:           jal          t1, 2f
0:                jal          t1, 4f
1:                jal          t0, 6f
2:                jal          s9, 0b
3:                jal          t1, 5f
4:                jal          t1, 3b
5:                jal          sp, 13f
6:                jal          a2, 21f
7:                jal          s3, 18f
8:                jal          ra, 11f
9:                jal          s7, 17f
10:               jal          s11, 14f
11:               jal          s8, 7b
12:               jal          ra, 20f
13:               jal          ra, 12b
14:               jal          t1, 8b
15:               jal          ra, 16f
16:               jal          t1, 1b
17:               jal          t1, 15b
18:               jal          ra, 19f
19:               jal          t1, 9b
20:               jal          tp, 10b
21:               sltu         a3, s5, gp
                  la           a2, region_0+3145 #start load_store_instr_stream_0
                  la           s8, region_0+3465 #start load_store_instr_stream_1
                  sb           t2, 12(s8)
                  sb           a4, 54(a2)
                  sh           ra, 13(a2)
                  lb           t0, 2(s8)
                  lbu          s3, -4(s8)
                  sb           a0, -12(s8)
                  lb           ra, -31(a2)
                  lbu          t1, -8(a2)
                  lb           a5, -51(a2)
                  sh           s11, 5(s8)
                  lb           tp, -6(s8) #end load_store_instr_stream_1
                  lb           a7, -8(a2) #end load_store_instr_stream_0
                  la           s2, region_0+386 #start riscv_hazard_instr_stream_0
                  lbu          gp, 909(s2)
                  lh           s10, -192(s2)
                  sub          s10, a3, s10
                  lh           s1, 412(s2)
                  slt          t1, t1, s10
                  lb           t1, 183(s2)
                  lbu          s8, 1295(s2)
                  sltu         s10, gp, s8
                  lb           a3, 417(s2)
                  auipc        s8, 964442
                  sb           s8, -127(s2)
                  auipc        s10, 491513
                  lbu          s10, 1819(s2)
                  xori         s1, s1, -1590
                  sltu         a3, a3, s1
                  lhu          s1, -306(s2)
                  srl          s8, s8, t1
                  sb           s10, 894(s2)
                  add          gp, a3, a3
                  srl          t1, t1, gp
                  sub          gp, t1, s8
                  sub          t1, s8, gp
                  srli         s8, s1, 7
                  srai         s10, a3, 18
                  sb           t1, 39(s2)
                  lbu          s10, -34(s2)
                  lhu          s10, -152(s2)
                  srai         s10, t1, 13
                  add          t1, s10, gp
                  sb           s10, 1763(s2)
                  xor          s8, s10, a3
                  sh           s8, 200(s2)
                  lbu          gp, 1891(s2)
                  srl          s8, a3, s10
                  lb           gp, 279(s2)
                  addi         s1, a3, 866
                  slt          s8, t1, gp
                  srl          a3, s1, s1
                  lui          gp, 596020
                  ori          s1, s10, -381
                  sb           gp, 1128(s2)
                  slti         gp, gp, 1860
                  lbu          a3, 846(s2)
                  andi         t1, s8, -980
                  addi         s1, a3, 1768
                  lh           a3, 1686(s2)
                  lb           a3, 1083(s2)
                  lb           t1, 333(s2)
                  lbu          s10, 1718(s2)
                  lh           a3, 1972(s2)
                  slti         gp, a3, 635
                  lbu          a3, 113(s2)
                  sltiu        t1, gp, -1656
                  sh           s1, 1862(s2)
                  sltiu        a3, s8, -1362
                  lb           s8, 1144(s2) #end riscv_hazard_instr_stream_0
                  la           s3, region_1+1313 #start load_store_instr_stream_1
                  la           a6, region_0+84 #start load_store_instr_stream_0
                  lb           a4, 37(a6)
                  lhu          t1, -3(s3)
                  lb           s0, -8(s3)
                  lbu          a4, 8(s3)
                  sh           s7, 158(a6)
                  sh           a6, -15(s3)
                  lbu          t5, -15(s3)
                  lbu          a7, 39(a6)
                  lb           zero, -10(s3)
                  lbu          t0, -16(s3)
                  sb           t2, 12(a6)
                  sb           a7, -2(s3)
                  sb           a6, -10(s3)
                  lbu          s4, 7(s3) #end load_store_instr_stream_1
                  lbu          gp, 213(a6) #end load_store_instr_stream_0
                  la           s4, region_0+3848 #start riscv_load_store_hazard_instr_stream_0
                  lbu          gp, -40(s4)
                  lui          s10, 915053
                  srai         s3, gp, 16
                  lb           t5, -40(s4)
                  lbu          a7, -40(s4)
                  sw           s4, -40(s4)
                  sh           ra, -40(s4)
                  lbu          a1, -40(s4)
                  sw           tp, -40(s4)
                  sb           t6, -40(s4)
                  lbu          s10, -40(s4)
                  lb           s0, -40(s4)
                  lhu          a4, -40(s4)
                  lw           a6, -40(s4) #end riscv_load_store_hazard_instr_stream_0
                  sltu         a2, tp, t4
                  add          a5, s8, s7
                  xori         a5, sp, 737
                  sub          a4, t6, a3
                  nop
                  slt          a1, s10, s10
                  bne          sp, s2, 22f
                  lui          a6, 545789
                  sltiu        t3, a0, -1669
                  sltu         s10, t1, a1
                  sll          a2, s11, s5
                  xor          sp, sp, t1
                  sra          s4, zero, s11
                  xori         s0, a4, 2029
                  and          s2, s1, a0
                  or           s2, t6, tp
                  ori          s1, a7, -281
                  sra          s3, s11, s2
                  la           a3, sub_1
                  auipc        t5, 74761
                  or           t6, s0, t6
                  srl          sp, s0, a6
                  addi         a3, a3, -241
                  and          s2, a5, gp
                  sltiu        ra, s11, -1357
                  auipc        s10, 426962
main_j1:          jalr         t1, a3, 241 #jump main -> sub_1
                  sltu         s8, a7, s10
                  sub          sp, t0, gp
                  nop
                  ori          s11, tp, 1700
                  slli         a5, s10, 30
                  lui          s9, 921520
                  xori         s4, s10, -1103
22:               lui          t4, 619055
                  or           a4, a0, s2
                  bne          s1, t0, 28f
                  blt          a2, a0, 33f
                  ori          t6, zero, -1352
                  slt          s5, zero, t0
28:               srli         a1, t6, 19
                  blt          s2, a7, 45f
                  andi         s9, t5, -139
                  slti         t5, s2, 523
                  bgeu         gp, s7, 36f
33:               andi         a2, a5, 859
                  bgeu         t4, t4, 48f
                  ori          s0, t5, 1957
36:               beq          t2, a3, 40f
                  and          t6, a5, t2
                  addi         s10, t1, -302
                  bge          t3, t4, 51f
40:               sltu         s2, gp, s9
                  beq          t4, ra, 45f
                  sltiu        s11, s11, 1205
                  addi         s8, a5, -571
                  andi         s2, a7, -495
45:               and          s10, a2, s6
                  slt          s10, zero, t1
                  bge          a1, a1, 51f
48:               bge          s9, s4, 50f
                  addi         s7, a5, 304
50:               bne          a7, t0, 51f
51:               addi         tp, gp, -1939
                  la x22, test_done
                  jalr x0, x22, 0
test_done:        
                  li gp, 1
                  j SystemExit
sub_1:            bne          a1, s2, sub_1_stack_p
                  sltiu        a5, s7, 338
sub_1_stack_p:    addi         a0, a0, -48
                  or           t4, a7, s5
                  sw           t1, 4(a0)
                  srl          s7, a5, sp
                  la           s9, region_0+2001 #start riscv_hazard_instr_stream_2
                  andi         t0, gp, 1485
                  slli         s1, gp, 16
                  slli         t5, t5, 3
                  srl          ra, gp, a5
                  srai         t5, ra, 19
                  sb           t5, -202(s9)
                  andi         s1, ra, 1688
                  lb           t0, 229(s9)
                  xor          gp, ra, gp
                  lbu          s1, -228(s9)
                  sb           t0, 115(s9)
                  lw           gp, 247(s9)
                  lui          ra, 327933
                  slli         s1, s1, 18
                  ori          gp, a5, -44
                  sh           s1, 109(s9)
                  auipc        s1, 1035924
                  sra          ra, gp, gp
                  sll          t0, a5, t5
                  lb           ra, -130(s9)
                  srai         a5, ra, 3
                  lhu          t5, -203(s9)
                  lb           s1, 142(s9)
                  lbu          a5, 132(s9)
                  lh           t0, -61(s9)
                  lh           t5, -13(s9)
                  slti         a5, a5, 2026
                  sll          ra, gp, s1
                  lui          gp, 265280
                  lhu          t5, -21(s9)
                  lw           gp, 235(s9)
                  lbu          t5, -168(s9)
                  nop
                  lb           gp, 44(s9)
                  sb           s1, -16(s9)
                  nop
                  sltu         t0, ra, t0
                  sb           gp, 116(s9)
                  srli         a5, s1, 29
                  sub          gp, ra, a5
                  lb           t5, 120(s9)
                  sb           t5, 129(s9)
                  lb           t0, 174(s9)
                  srli         a5, t5, 27
                  lb           t0, -170(s9) #end riscv_hazard_instr_stream_2
                  la           a3, region_1+2037 #start load_store_instr_stream_0
                  lbu          t6, 908(a3)
                  la           s1, region_0+144 #start load_store_instr_stream_1
                  lbu          a5, -14(a3)
                  lb           s5, 1761(s1)
                  lb           a5, 708(a3)
                  lhu          s3, 212(s1)
                  lbu          t3, 442(a3)
                  lhu          t4, 1142(s1)
                  lh           a4, 1980(s1)
                  lb           a4, -336(a3)
                  sh           s11, 1042(s1)
                  lbu          zero, 633(a3)
                  lb           a6, 1212(a3)
                  sb           t0, 465(s1)
                  lbu          t5, 332(a3)
                  lh           t5, 1522(s1)
                  lhu          s9, 290(s1)
                  lb           s10, -328(a3)
                  sb           a3, 1441(s1) #end load_store_instr_stream_1
                  lw           s2, -1361(a3) #end load_store_instr_stream_0
                  addi         a1, zero, -1 #init loop 1 counter
                  xori         sp, ra, 1828
                  addi         s10, zero, 20 #init loop 1 limit
sub_1_18_1_t:     sltiu        a3, a6, 625
                  addi         a1, a1, 5 #update loop 1 counter
                  addi         ra, zero, 0 #init loop 0 counter
                  addi         s8, zero, 11 #init loop 0 limit
sub_1_18_0_t:     or           s1, ra, s0
                  sltiu        gp, t5, 551
                  lui          t4, 87186
                  addi         ra, ra, 9 #update loop 0 counter
                  blt          ra, s8, sub_1_18_0_t #branch for loop 0
                  bltu         a1, s10, sub_1_18_1_t #branch for loop 1
                  sll          tp, s0, t6
sub_1_9:          jal          t1, 16f
0:                jal          t1, 2f
1:                jal          ra, 15f
2:                jal          a5, 1b
3:                jal          gp, 4f
4:                jal          tp, 19f
5:                jal          ra, 21f
6:                jal          s8, 12f
7:                jal          ra, 9f
8:                jal          ra, 20f
9:                jal          ra, 8b
10:               jal          ra, 7b
11:               jal          ra, 3b
12:               jal          t1, 5b
13:               jal          ra, 0b
14:               jal          t1, 10b
15:               jal          ra, 18f
16:               jal          ra, 13b
17:               jal          ra, 11b
18:               jal          ra, 14b
19:               jal          tp, 6b
20:               jal          ra, 17b
21:               sll          s0, ra, t6
                  la           sp, region_1+3926 #start riscv_hazard_instr_stream_6
                  lb           s5, 58(sp)
                  lw           s1, 46(sp)
                  add          s1, s5, a2
                  sb           a7, -51(sp)
                  sh           a7, -22(sp)
                  or           s1, s1, a7
                  lbu          s1, -7(sp)
                  srai         s5, a7, 12
                  slt          a7, s2, s2
                  lhu          a7, -42(sp)
                  xor          s5, s2, s1
                  slt          s5, s7, s1
                  nop
                  lh           s7, -46(sp)
                  lb           s7, -59(sp)
                  lbu          a7, 51(sp)
                  sb           s7, 37(sp)
                  slt          a2, s5, s1
                  sb           a7, 8(sp)
                  addi         s5, a2, -1326
                  ori          a2, s1, -1638
                  slt          a7, s7, a7
                  lhu          a7, 64(sp)
                  srli         a7, s2, 2
                  sll          s5, s7, s1
                  sb           a7, -60(sp)
                  sw           s2, -30(sp) #end riscv_hazard_instr_stream_6
                  la           s2, region_0+125 #start riscv_hazard_instr_stream_1
                  auipc        a6, 13263
                  lbu          s3, 0(s2)
                  ori          a7, s7, -1272
                  sll          a5, a7, s3
                  lb           a6, 8(s2)
                  slli         a6, a6, 8
                  auipc        a5, 844112
                  sb           s7, 5(s2)
                  sh           t1, -15(s2)
                  slti         a6, t1, 740
                  or           a6, s7, a5
                  sb           a5, 5(s2)
                  lbu          a6, -2(s2)
                  andi         a7, a6, 1549
                  srai         a6, s7, 16
                  nop
                  or           a7, t1, t1
                  lb           a7, 13(s2)
                  sh           t1, 1(s2)
                  slli         a5, t1, 13
                  lbu          s3, -6(s2)
                  srai         s7, a5, 30
                  lb           s3, 4(s2)
                  sb           s3, 10(s2)
                  srai         a6, t1, 21
                  sll          a5, a5, a5
                  xori         a7, s3, -780
                  lh           a5, -3(s2)
                  lbu          a5, 2(s2)
                  sb           s3, -14(s2)
                  lb           t1, 10(s2)
                  lui          t1, 828993
                  lb           a7, 16(s2)
                  and          a5, a5, s7
                  lhu          a7, -13(s2)
                  xor          a7, a6, a6
                  srl          t1, s3, a5
                  sh           t1, 9(s2)
                  lb           a5, -3(s2)
                  sltiu        s7, t1, -571
                  lb           a7, 0(s2)
                  srli         s7, a7, 19
                  sll          a6, a5, s7
                  lbu          s7, 15(s2)
                  lbu          a6, 4(s2)
                  add          t1, s3, s3
                  and          t1, s7, s7
                  sb           t1, 0(s2)
                  lbu          s7, -14(s2)
                  slli         a5, s7, 17
                  lb           s3, 6(s2)
                  lb           s7, 15(s2)
                  nop
                  or           s7, t1, a5
                  lui          s7, 453875
                  and          a7, a7, a5
                  lhu          a5, -13(s2) #end riscv_hazard_instr_stream_1
                  la           a7, region_1+3909 #start riscv_load_store_hazard_instr_stream_0
                  sra          a5, a4, s7
                  lh           t0, 161(a7)
                  lb           a3, 161(a7)
                  lhu          t5, 165(a7)
                  lbu          s1, 165(a7)
                  sb           tp, -23(a7)
                  lbu          t0, -191(a7)
                  sb           t6, -191(a7)
                  lh           a3, -191(a7)
                  lbu          s4, -191(a7)
                  sub          ra, a6, zero
                  sb           gp, -228(a7)
                  sll          s5, gp, a2
                  lb           a6, -228(a7)
                  sb           s7, -228(a7)
                  lb           s9, -228(a7)
                  lhu          ra, 121(a7)
                  lbu          t1, 121(a7)
                  ori          sp, s7, -562
                  lh           gp, 121(a7)
                  or           t6, t4, s1
                  lh           s11, 121(a7) #end riscv_load_store_hazard_instr_stream_0
                  la           tp, region_1+1561 #start load_store_instr_stream_1
                  la           s3, region_1+1684 #start load_store_instr_stream_0
                  la           sp, region_1+3530 #start load_store_instr_stream_2
                  la           a5, region_1+3182 #start load_store_instr_stream_4
                  lb           t5, 0(tp)
                  lb           t4, -296(s3)
                  sb           s3, 391(s3)
                  la           s4, region_1+3933 #start load_store_instr_stream_3
                  lb           t4, 219(sp)
                  lb           a6, -175(s4)
                  sh           ra, 7(tp)
                  lhu          a1, -20(sp)
                  lb           s9, 1(a5)
                  sh           s1, 18(a5)
                  sh           s2, 123(s4)
                  lbu          t1, 331(s3)
                  lhu          s1, 96(sp)
                  lb           t4, 94(s4)
                  sb           a6, -83(sp)
                  lb           t3, 1257(s3)
                  lw           a7, 11(tp)
                  sw           s5, 38(a5)
                  sb           t0, -1103(s3)
                  lb           a1, -82(s4)
                  sb           s2, 8(s3)
                  lbu          t1, 12(tp)
                  sw           ra, -42(a5)
                  sb           s3, 16(tp)
                  lb           s9, 3(sp)
                  lh           s1, -54(sp)
                  sb           s0, -11(a5)
                  lbu          s0, 4(a5) #end load_store_instr_stream_4
                  lb           a6, -1463(s3)
                  sb           a0, -10(tp)
                  lb           s10, -253(sp)
                  lbu          a2, 810(s3)
                  sh           s9, -96(sp)
                  sb           t4, 85(s4) #end load_store_instr_stream_3
                  sb           a3, -119(sp) #end load_store_instr_stream_2
                  lhu          zero, 1(tp) #end load_store_instr_stream_1
                  lbu          a1, -1661(s3)
                  lh           t1, 318(s3) #end load_store_instr_stream_0
                  la           a5, region_0+3786 #start load_store_instr_stream_0
                  sb           a2, -1931(a5)
                  la           tp, region_1+3519 #start load_store_instr_stream_1
                  lbu          sp, 309(a5)
                  lbu          gp, -154(tp)
                  lhu          a1, -528(a5)
                  lb           sp, -345(a5)
                  lw           a7, -127(tp)
                  sh           a5, -946(a5)
                  lh           s9, -964(a5)
                  lw           t0, 137(tp)
                  lb           gp, -593(a5)
                  lb           a4, -1488(a5)
                  sb           s10, -26(tp)
                  sb           gp, -455(a5)
                  lb           s7, 211(tp) #end load_store_instr_stream_1
                  lh           s10, -282(a5) #end load_store_instr_stream_0
                  la           t5, region_0+1445 #start load_store_instr_stream_0
                  la           ra, region_0+3978 #start load_store_instr_stream_1
                  sh           s0, 6(ra)
                  sh           t4, -14(ra)
                  sb           a6, -64(t5)
                  lb           s1, 15(ra)
                  lbu          s2, 8(t5)
                  lb           a4, -5(t5)
                  sb           a5, -4(ra)
                  lbu          t4, 0(t5)
                  lb           s8, -26(t5)
                  lb           t3, 13(ra)
                  lb           t4, -3(ra) #end load_store_instr_stream_1
                  sb           s3, -62(t5)
                  lb           s10, 42(t5) #end load_store_instr_stream_0
                  la           t0, region_1+3228 #start load_store_instr_stream_1
                  sb           s4, -1875(t0)
                  la           s2, region_0+682 #start load_store_instr_stream_0
                  sh           s3, -1956(t0)
                  sb           a5, -1609(t0)
                  sb           s4, 491(t0)
                  lhu          a2, -44(s2)
                  lh           s9, -202(s2)
                  sb           zero, -19(s2)
                  lbu          t3, -1187(t0)
                  sh           ra, -554(t0)
                  lbu          a2, 237(s2)
                  lh           ra, -388(t0)
                  lbu          s7, -8(s2)
                  lbu          ra, 821(t0)
                  sb           s10, 855(t0) #end load_store_instr_stream_1
                  lb           s1, -203(s2) #end load_store_instr_stream_0
                  la           gp, region_1+1195 #start riscv_hazard_instr_stream_3
                  sh           zero, 139(gp)
                  lh           a4, 115(gp)
                  sltiu        a1, a1, -419
                  lbu          a1, -127(gp)
                  sb           zero, -74(gp)
                  and          a4, zero, zero
                  sltu         t5, t5, a4
                  lbu          t1, 226(gp)
                  auipc        t5, 5873
                  and          tp, a4, t5
                  andi         t5, tp, -200
                  xori         tp, zero, 656
                  sltiu        t5, tp, -1631
                  lb           t5, -142(gp)
                  lui          zero, 583041
                  lui          a1, 450048
                  lui          t1, 633335
                  sb           t5, 142(gp)
                  lh           t5, 247(gp)
                  sh           a4, 237(gp)
                  lb           t1, -117(gp)
                  lbu          zero, -94(gp)
                  lh           zero, 51(gp)
                  sub          a1, t1, t5
                  lbu          t1, -205(gp)
                  add          a1, t1, a4
                  xor          zero, zero, zero
                  sb           a1, -204(gp)
                  xor          t5, t5, a1
                  srli         t1, t5, 8
                  slt          a4, t5, a4
                  sh           t1, 239(gp)
                  sll          a4, t5, a4
                  sb           a1, -6(gp)
                  lb           t1, -52(gp)
                  add          a1, tp, t5
                  auipc        a4, 926235
                  lbu          a1, 200(gp)
                  sh           zero, 135(gp)
                  lbu          a1, 236(gp)
                  sw           a4, -59(gp)
                  srli         tp, t5, 1
                  sra          zero, a4, zero
                  lb           zero, 144(gp)
                  lbu          tp, 12(gp)
                  slt          t5, tp, zero
                  xor          a4, a4, zero
                  sb           a1, 171(gp) #end riscv_hazard_instr_stream_3
                  la           t5, region_0+244 #start riscv_load_store_hazard_instr_stream_2
                  lbu          a4, -1(t5)
                  lbu          a3, -1(t5)
                  lb           s0, 10(t5)
                  addi         t3, a5, -154
                  lb           s3, 10(t5)
                  lhu          ra, 10(t5)
                  addi         s10, s6, 69
                  lh           s9, 10(t5)
                  lbu          t4, 10(t5)
                  lbu          zero, 10(t5)
                  lui          sp, 749613
                  sb           s6, -9(t5)
                  lb           t6, 11(t5)
                  lb           a1, 14(t5)
                  lhu          ra, 14(t5)
                  nop
                  lb           tp, -2(t5) #end riscv_load_store_hazard_instr_stream_2
                  la           tp, region_1+538 #start load_store_instr_stream_1
                  lb           s2, 1881(tp)
                  la           gp, region_1+994 #start load_store_instr_stream_0
                  la           s0, region_1+3886 #start load_store_instr_stream_4
                  lb           t3, 27(s0)
                  sb           s6, 430(tp)
                  lb           s8, 1974(tp)
                  lbu          a5, 1135(gp)
                  la           a1, region_1+3908 #start load_store_instr_stream_3
                  sb           t5, 21(s0)
                  la           t4, region_1+2573 #start load_store_instr_stream_2
                  lb           s11, 1247(tp)
                  lbu          a5, 8(a1)
                  lh           a2, 668(tp)
                  sb           t4, 457(gp)
                  lb           a2, -49(a1)
                  lbu          a3, 1626(gp)
                  sb           t1, -41(a1)
                  sb           a1, -1975(t4)
                  lbu          s2, 54(a1)
                  lb           a3, 1279(tp)
                  sb           ra, -1820(t4)
                  sh           a1, 26(a1)
                  lb           t1, 2009(gp)
                  sb           t2, -9(a1)
                  lhu          a7, 513(t4)
                  lbu          t6, -40(t4)
                  lbu          a3, -691(gp)
                  lbu          a4, -1792(t4)
                  sh           sp, -176(tp)
                  lbu          s9, -46(a1)
                  sb           a4, 47(s0)
                  lbu          s7, 31(a1)
                  lw           a3, 763(t4)
                  lb           s4, -161(tp)
                  sh           t4, -989(t4) #end load_store_instr_stream_2
                  lbu          ra, -35(s0)
                  lbu          t6, 1720(gp)
                  sh           a5, 32(s0) #end load_store_instr_stream_4
                  sb           s2, 915(tp)
                  sb           t3, -599(gp)
                  sb           gp, 27(a1) #end load_store_instr_stream_3
                  lb           s1, 1281(tp) #end load_store_instr_stream_1
                  lbu          a6, -468(gp) #end load_store_instr_stream_0
                  la           tp, region_1+3815 #start load_store_instr_stream_1
                  lhu          a4, 141(tp)
                  la           t6, region_0+2312 #start load_store_instr_stream_0
                  lb           s5, 83(tp)
                  lb           ra, 11(t6)
                  lbu          s5, 146(tp)
                  lw           zero, -255(tp)
                  lb           s3, -188(tp)
                  lb           a6, -9(t6)
                  lbu          a1, 222(tp)
                  lbu          t4, -131(tp)
                  sh           t4, -14(t6)
                  sw           a4, 89(tp)
                  lbu          a1, -198(tp)
                  lb           a4, 148(tp) #end load_store_instr_stream_1
                  lbu          s2, -14(t6)
                  lbu          s7, 12(t6)
                  lb           ra, 9(t6) #end load_store_instr_stream_0
sub_1_7:          jal          t1, 8f
0:                jal          a1, 18f
1:                jal          s4, 28f
2:                jal          ra, 22f
3:                jal          t4, 21f
4:                jal          ra, 7f
5:                jal          s1, 4b
6:                jal          ra, 17f
7:                jal          ra, 15f
8:                jal          t1, 14f
9:                jal          ra, 3b
10:               jal          ra, 11f
11:               jal          ra, 16f
12:               jal          ra, 0b
13:               jal          a4, 5b
14:               jal          t1, 26f
15:               jal          t1, 27f
16:               jal          ra, 2b
17:               jal          ra, 25f
18:               jal          ra, 13b
19:               jal          ra, 6b
20:               jal          t1, 12b
21:               jal          ra, 23f
22:               jal          sp, 20b
23:               jal          ra, 24f
24:               jal          ra, 19b
25:               jal          ra, 1b
26:               jal          t1, 10b
27:               jal          ra, 9b
28:               ori          s4, zero, -1376
                  la           a2, region_0+3729 #start load_store_instr_stream_1
                  sb           a3, -1656(a2)
                  la           t6, region_0+3145 #start load_store_instr_stream_0
                  lb           t3, -933(a2)
                  sw           a3, -1553(a2)
                  lb           a7, -2(t6)
                  lw           s3, -1941(a2)
                  lw           s3, -1237(a2)
                  sh           a6, 1(t6)
                  lhu          sp, -323(a2) #end load_store_instr_stream_1
                  sb           ra, -15(t6)
                  sb           a1, 4(t6)
                  lhu          a3, -13(t6)
                  lb           s1, -9(t6) #end load_store_instr_stream_0
                  addi         gp, zero, 3 #init loop 1 counter
                  addi         s0, zero, -3 #init loop 1 limit
                  add          t3, s3, sp
sub_1_17_1_t:     slti         s5, s10, -306
                  slli         s7, sp, 27
                  addi         gp, gp, -3 #update loop 1 counter
                  sub          tp, a3, zero
                  addi         s9, zero, -1 #init loop 0 counter
                  sll          ra, a7, a6
                  addi         t1, zero, 8 #init loop 0 limit
sub_1_17_0_t:     addi         t4, s6, 1283
                  srai         t5, t4, 15
                  srai         s2, s10, 31
                  slti         t3, s10, 2020
                  addi         s9, s9, 9 #update loop 0 counter
                  and          a3, a7, t1
                  beq          s9, t1, sub_1_17_0_t #branch for loop 0
                  bge          gp, s0, sub_1_17_1_t #branch for loop 1
                  andi         a1, a6, 1827
                  la           s11, region_1+573 #start riscv_load_store_hazard_instr_stream_4
                  lb           sp, -10(s11)
                  slti         t6, s10, -1586
                  lb           s8, -10(s11)
                  lbu          s5, -64(s11)
                  sltu         t0, s5, s4
                  lhu          a3, -15(s11)
                  sh           t0, -15(s11)
                  lb           t6, 54(s11)
                  sub          sp, a4, ra
                  lui          a6, 458870
                  sb           a2, 54(s11)
                  lh           s1, -51(s11)
                  lhu          a3, -7(s11)
                  sb           s11, -7(s11)
                  sll          tp, s1, a0
                  lh           t1, -55(s11)
                  sh           t2, -55(s11) #end riscv_load_store_hazard_instr_stream_4
                  la           ra, region_1+2623 #start load_store_instr_stream_2
                  la           t5, region_1+3750 #start load_store_instr_stream_0
                  la           t1, region_1+1545 #start load_store_instr_stream_3
                  lbu          s5, 44(ra)
                  la           a3, region_1+3497 #start load_store_instr_stream_1
                  lh           a4, -16(t5)
                  lhu          s1, -7(ra)
                  lw           zero, -221(a3)
                  sb           a0, -4(ra)
                  lbu          s11, 72(a3)
                  lbu          a2, -144(t1)
                  lhu          s10, -4(t5)
                  lh           zero, -57(a3)
                  sh           s6, -25(ra)
                  lb           s7, 101(a3)
                  sb           t0, 136(t1)
                  lbu          gp, -8(ra)
                  sb           gp, 195(a3)
                  lhu          a5, 12(t5)
                  sb           s8, -36(ra)
                  lhu          tp, -39(ra)
                  lbu          a6, -112(t1)
                  lbu          s11, -3(t5)
                  lbu          a7, 32(ra)
                  lbu          s5, -80(t1)
                  lh           zero, 195(a3)
                  sh           t4, 6(t5)
                  lb           s9, 60(ra)
                  lhu          zero, 121(a3) #end load_store_instr_stream_1
                  lbu          s7, 0(ra) #end load_store_instr_stream_2
                  lb           a7, -246(t1) #end load_store_instr_stream_3
                  lb           a6, -12(t5) #end load_store_instr_stream_0
                  la           s8, region_0+2304 #start load_store_instr_stream_0
                  lbu          s3, 540(s8)
                  la           s5, region_1+326 #start load_store_instr_stream_1
                  lb           a2, 426(s8)
                  sh           a7, 778(s8)
                  sb           a2, 173(s8)
                  sb           s8, -23(s5)
                  lbu          tp, 47(s5)
                  sb           s11, -49(s5)
                  lbu          s9, -596(s8)
                  sb           s6, 11(s5)
                  lbu          s3, -842(s8)
                  sb           a6, -50(s5)
                  lb           t1, -451(s8)
                  lb           zero, -28(s5) #end load_store_instr_stream_1
                  lbu          t6, 679(s8)
                  lbu          a6, 734(s8)
                  lb           s1, -433(s8) #end load_store_instr_stream_0
sub_1_8:          jal          t1, 11f
0:                jal          t1, 13f
1:                jal          sp, 6f
2:                jal          ra, 19f
3:                jal          ra, 25f
4:                jal          t0, 16f
5:                jal          ra, 22f
6:                jal          ra, 20f
7:                jal          t1, 27f
8:                jal          ra, 12f
9:                jal          ra, 29f
10:               jal          ra, 4b
11:               jal          ra, 0b
12:               jal          s2, 28f
13:               jal          s8, 2b
14:               jal          ra, 21f
15:               jal          t1, 9b
16:               jal          ra, 15b
17:               jal          t0, 24f
18:               jal          s3, 8b
19:               jal          t4, 3b
20:               jal          t1, 17b
21:               jal          t1, 5b
22:               jal          ra, 26f
23:               jal          ra, 18b
24:               jal          ra, 10b
25:               jal          t1, 7b
26:               jal          tp, 23b
27:               jal          ra, 14b
28:               jal          ra, 1b
29:               add          a4, t5, a4
                  la           s5, region_0+1290 #start load_store_instr_stream_0
                  lhu          a3, -38(s5)
                  la           s11, region_1+873 #start load_store_instr_stream_1
                  sb           a4, -41(s5)
                  lbu          gp, -14(s11)
                  lbu          t5, 59(s5)
                  sb           s8, -36(s5)
                  lbu          t3, 1(s11)
                  lbu          tp, -59(s5)
                  lh           t6, 15(s11)
                  lhu          a5, 13(s11)
                  sh           t4, -36(s5)
                  lbu          a4, -10(s11)
                  lb           sp, 1(s11)
                  lbu          s4, 45(s5)
                  lbu          a2, 1(s11) #end load_store_instr_stream_1
                  lh           s9, -58(s5) #end load_store_instr_stream_0
                  la           a6, region_0+475 #start riscv_load_store_hazard_instr_stream_1
                  addi         s4, t0, 2041
                  sb           t1, 1640(a6)
                  slt          a3, gp, t0
                  lh           t3, 335(a6)
                  sh           a3, 335(a6)
                  lb           t1, 335(a6)
                  lhu          gp, 335(a6)
                  lb           s11, 343(a6)
                  lh           s8, 343(a6)
                  ori          a1, t6, 1045
                  srai         s2, t6, 12
                  nop
                  lh           gp, 343(a6)
                  lbu          t4, 343(a6)
                  lbu          t0, 343(a6)
                  lbu          ra, 343(a6)
                  lh           tp, 343(a6)
                  sra          s4, tp, t2
                  lbu          s10, 343(a6)
                  sh           t6, 343(a6)
                  lhu          s8, 343(a6) #end riscv_load_store_hazard_instr_stream_1
                  la           s10, region_1+82 #start riscv_load_store_hazard_instr_stream_5
                  srl          s11, s5, t3
                  slti         s4, s10, -220
                  lb           t5, 137(s10)
                  sb           a7, 137(s10)
                  lb           s1, 137(s10)
                  sub          tp, t1, t6
                  sb           a4, 137(s10)
                  sb           a3, 33(s10)
                  lb           a1, 33(s10)
                  lb           s9, 33(s10)
                  sh           t2, -24(s10)
                  lb           a6, 91(s10)
                  lb           tp, 91(s10)
                  sh           a6, 52(s10)
                  xori         a2, ra, -164
                  auipc        t4, 44114
                  lb           t3, 52(s10)
                  lbu          s1, -53(s10) #end riscv_load_store_hazard_instr_stream_5
                  la           ra, region_1+2981 #start load_store_instr_stream_2
                  la           t6, region_1+4091 #start load_store_instr_stream_1
                  sh           t5, -2005(ra)
                  la           s9, region_1+263 #start load_store_instr_stream_0
                  lb           a3, -165(t6)
                  lbu          a1, -356(t6)
                  sb           a6, -1891(ra)
                  sb           s9, 80(s9)
                  lb           s7, -427(t6)
                  lb           s3, 116(s9)
                  lb           s3, -168(ra)
                  lb           a5, 90(s9)
                  lb           a6, 490(ra)
                  lb           gp, -1617(ra)
                  lbu          a5, -148(s9)
                  lw           s11, -651(t6)
                  lb           t4, -1906(t6)
                  lb           t0, -248(s9)
                  lbu          s3, -95(s9)
                  lhu          s10, -421(ra)
                  lbu          s0, 976(ra)
                  sh           a4, -1681(t6)
                  sb           t1, -1794(t6)
                  lb           s0, 105(s9)
                  lb           s11, 216(ra)
                  lh           t1, -1329(t6)
                  lb           s1, -1164(ra)
                  sh           t4, -679(t6) #end load_store_instr_stream_1
                  sb           s6, -868(ra) #end load_store_instr_stream_2
                  sh           a2, 163(s9) #end load_store_instr_stream_0
                  la           gp, region_1+270 #start riscv_hazard_instr_stream_4
                  or           a1, t5, t5
                  lui          a1, 631421
                  xori         a1, tp, 421
                  lbu          a1, -9(gp)
                  srli         a1, t5, 8
                  srli         a1, a2, 29
                  ori          tp, a1, 1223
                  add          a6, a1, t5
                  sb           t5, -9(gp)
                  sltu         a1, a6, a5
                  srai         a5, a6, 2
                  sub          t5, tp, a2
                  srai         a2, a5, 9
                  lbu          a6, 15(gp)
                  sra          tp, a6, a6
                  slt          a5, a1, a6
                  or           t5, a5, a6
                  lbu          a1, 13(gp)
                  srli         t5, tp, 11
                  sltu         a1, a1, a1
                  addi         a5, a6, -1773
                  lb           a5, 10(gp)
                  sb           t5, 1(gp)
                  add          tp, a5, a6
                  slti         tp, a6, -493
                  lb           a6, 15(gp)
                  sll          a5, a5, a6
                  lbu          a1, -3(gp)
                  lb           t5, 13(gp)
                  sh           t5, 8(gp)
                  srai         a1, tp, 22
                  srai         a5, a5, 7
                  ori          a1, t5, -1282
                  sltu         a2, t5, a5
                  sw           a5, -6(gp) #end riscv_hazard_instr_stream_4
                  la           s1, region_1+2809 #start riscv_load_store_hazard_instr_stream_3
                  sb           t3, -14(s1)
                  lb           s4, -16(s1)
                  lbu          s7, 16(s1)
                  sb           a0, 16(s1)
                  lbu          s4, 16(s1)
                  slt          s4, s4, t1
                  lb           a2, 16(s1)
                  lb           t3, 15(s1)
                  sb           s4, 15(s1)
                  sb           s5, 10(s1)
                  lh           a6, -3(s1)
                  lbu          s4, -3(s1)
                  lh           t3, -3(s1)
                  lbu          gp, -3(s1)
                  sb           a4, -3(s1) #end riscv_load_store_hazard_instr_stream_3
                  la           s7, region_0+1662 #start riscv_hazard_instr_stream_0
                  lui          t4, 133496
                  lb           a7, 1546(s7)
                  sub          a5, a7, zero
                  auipc        t4, 875865
                  lhu          zero, -116(s7)
                  sltiu        s9, zero, -1168
                  sb           a7, -1116(s7)
                  lb           t4, 306(s7)
                  xor          a7, a5, a5
                  sra          t4, t4, a5
                  lb           s9, -152(s7)
                  xori         t4, a7, 327
                  sh           a7, -1344(s7)
                  sb           t4, 65(s7)
                  add          zero, t4, zero
                  lui          s9, 389113
                  sb           t4, 452(s7)
                  addi         s9, s9, 712
                  srai         a5, a7, 18
                  sub          zero, a5, s0
                  srl          zero, s9, t4
                  slt          s9, a7, a5
                  srl          s9, a5, a7
                  sh           s0, 1084(s7)
                  sh           s0, -892(s7)
                  add          s9, s9, s9
                  sltu         a7, zero, t4
                  lb           s9, 401(s7)
                  sb           t4, 145(s7)
                  sb           a7, -548(s7)
                  ori          zero, s9, 529
                  auipc        s0, 999126
                  lw           s9, -1166(s7)
                  lb           s0, -1173(s7)
                  sb           a5, -569(s7)
                  lb           t4, -375(s7)
                  lui          a5, 272169
                  lbu          a5, -496(s7) #end riscv_hazard_instr_stream_0
                  la           t6, region_0+3891 #start load_store_instr_stream_2
                  la           s2, region_0+953 #start load_store_instr_stream_3
                  la           t1, region_0+3291 #start load_store_instr_stream_1
                  lb           a2, 1(t6)
                  sb           sp, -17(s2)
                  la           a4, region_0+557 #start load_store_instr_stream_0
                  lhu          s5, -41(s2)
                  lbu          s3, -38(s2)
                  sb           a6, -645(t1)
                  lh           a6, 7(a4)
                  sb           t3, -1350(t1)
                  la           gp, region_0+3367 #start load_store_instr_stream_4
                  lh           a7, 9(s2)
                  sh           zero, -15(t6)
                  lbu          a1, -10(a4)
                  lh           s11, 3(s2)
                  lb           tp, 366(t1)
                  sh           a6, -15(a4)
                  lb           t3, -14(t6)
                  lhu          a7, 13(t6)
                  lb           s7, -1817(t1)
                  lb           t3, -60(gp)
                  lb           t5, -10(a4)
                  lbu          t5, -25(gp)
                  lhu          a5, -1535(t1)
                  lhu          t3, 5(gp)
                  lw           t0, -11(t6)
                  lb           s4, -1030(t1)
                  lb           s1, 166(t1)
                  lbu          zero, 47(gp)
                  lb           s4, 17(s2)
                  lbu          a6, 16(a4)
                  lh           sp, -9(gp)
                  lh           s4, 17(s2)
                  lhu          s0, -5(s2)
                  lbu          s11, 14(gp)
                  sb           t5, 42(s2)
                  lhu          a2, -31(s2) #end load_store_instr_stream_3
                  lb           s5, 10(t6)
                  sb           s10, 314(t1)
                  sb           tp, 8(t6)
                  lb           s0, 768(t1) #end load_store_instr_stream_1
                  lbu          a3, 42(gp)
                  lhu          s7, 41(gp) #end load_store_instr_stream_4
                  sh           s3, -9(t6) #end load_store_instr_stream_2
                  sb           tp, 16(a4) #end load_store_instr_stream_0
                  la           a1, region_1+1557 #start load_store_instr_stream_1
                  sb           s4, -111(a1)
                  la           t1, region_0+2077 #start load_store_instr_stream_0
                  lb           t6, 153(a1)
                  sb           ra, -146(t1)
                  lbu          t3, -55(a1)
                  lbu          a2, 41(t1)
                  lb           s0, -122(a1)
                  lbu          a5, -217(a1)
                  lb           s3, 12(t1)
                  sb           t2, 204(a1)
                  sh           a0, 61(t1)
                  sw           s5, -17(a1)
                  sb           gp, 84(a1)
                  sb           s5, 82(t1)
                  lhu          gp, 57(a1) #end load_store_instr_stream_1
                  lbu          s4, 117(t1) #end load_store_instr_stream_0
                  la           a1, region_1+876 #start riscv_load_store_hazard_instr_stream_6
                  lw           t1, 8(a1)
                  lbu          a7, 8(a1)
                  lbu          s2, 8(a1)
                  lb           a3, 8(a1)
                  lb           s9, 8(a1)
                  sb           s4, 8(a1)
                  lhu          t0, 8(a1)
                  sub          s9, a5, s2
                  andi         ra, s0, 1740
                  sra          a4, s2, s0
                  lbu          zero, 8(a1)
                  lw           s2, 8(a1)
                  sw           s0, 8(a1)
                  lh           a2, 8(a1)
                  lhu          sp, 8(a1)
                  ori          s0, s5, 73
                  lbu          a6, 8(a1)
                  sltu         a7, a3, ra
                  lbu          a2, 5(a1)
                  lb           a3, 5(a1)
                  lbu          a7, -3(a1)
                  lbu          s10, -3(a1)
                  srli         s2, s3, 28
                  lbu          a6, -3(a1)
                  and          t5, t3, a2
                  lb           s10, -3(a1) #end riscv_load_store_hazard_instr_stream_6
                  addi         a7, zero, 5 #init loop 1 counter
                  addi         sp, zero, 13 #init loop 1 limit
                  xor          a5, t0, s9
                  add          s2, sp, a3
                  nop
                  xori         s3, t0, -478
                  sra          t4, ra, a6
                  and          s5, a1, a7
                  addi         s7, s9, -545
sub_1_19_1_t:     add          t3, a5, t6
                  slli         tp, s0, 4
                  addi         a7, a7, 4 #update loop 1 counter
                  andi         a6, s8, 1900
                  addi         s3, s1, -148
                  xori         s1, s8, 1813
                  addi         s10, zero, 3 #init loop 0 counter
                  sltu         s1, gp, s0
                  slli         s11, a5, 28
                  addi         s9, zero, 13 #init loop 0 limit
                  sll          a2, a1, ra
                  slti         a4, a1, 428
                  xor          a3, t6, a5
                  sltu         s2, a0, sp
sub_1_19_0_t:     ori          s4, s7, 99
                  srai         t0, a5, 12
                  auipc        t1, 1009882
                  addi         s10, s10, 5 #update loop 0 counter
                  slt          t6, a7, a7
                  blt          s10, s9, sub_1_19_0_t #branch for loop 0
                  lui          s5, 52560
                  srai         s1, gp, 26
                  beq          a7, sp, sub_1_19_1_t #branch for loop 1
                  sltu         zero, s9, s0
                  la           s2, region_0+4063 #start riscv_hazard_instr_stream_5
                  lb           ra, -7(s2)
                  lb           t1, -52(s2)
                  slt          t5, s1, t1
                  sb           t4, 0(s2)
                  lb           t1, 13(s2)
                  addi         t1, sp, 438
                  sb           sp, 30(s2)
                  sltiu        ra, t1, 1989
                  sh           t1, 11(s2)
                  lb           t1, -24(s2)
                  srai         s1, s1, 12
                  slti         sp, t1, 517
                  sra          t5, t4, t1
                  andi         sp, ra, -344
                  auipc        t5, 637569
                  lbu          t5, -38(s2)
                  slti         s1, sp, -55
                  sll          t4, t1, t5
                  srl          t5, s1, ra
                  lbu          sp, 31(s2)
                  auipc        sp, 612298
                  lbu          t5, -21(s2)
                  lb           t1, -50(s2)
                  sb           sp, -52(s2)
                  lhu          t5, 13(s2)
                  lb           s1, -48(s2)
                  and          t1, t4, s1
                  or           s1, ra, ra
                  srai         sp, s1, 16
                  lb           t1, -4(s2)
                  lb           t4, -22(s2)
                  lui          sp, 510911
                  lbu          s1, -42(s2)
                  auipc        ra, 231682
                  lw           t1, -43(s2)
                  lb           t1, -8(s2)
                  srl          sp, t4, sp
                  auipc        s1, 124727
                  lhu          s1, -59(s2)
                  lb           t5, 2(s2)
                  srl          t4, t4, ra
                  lb           s1, -17(s2)
                  sltiu        s1, sp, -1108
                  sh           ra, 7(s2)
                  srl          sp, ra, ra
                  sb           ra, 24(s2)
                  sltu         sp, t1, sp
                  srli         t4, sp, 21
                  sb           sp, -19(s2)
                  sb           s1, -46(s2) #end riscv_hazard_instr_stream_5
                  sll          s7, s4, s9
                  add          s5, s11, a6
                  blt          tp, a6, 22f
                  sltu         t4, a2, ra
                  andi         s8, s5, -1975
                  slt          a4, s1, a0
                  bne          s11, gp, 19f
                  sra          t6, zero, t5
                  xor          a6, t0, s3
                  sltu         s2, t5, s5
                  addi         ra, t6, -498
                  srai         tp, sp, 27
                  lui          t5, 366144
                  slli         zero, zero, 30
                  andi         t4, a3, -1782
                  srl          t6, a6, s0
                  la           a2, sub_3
                  slt          s3, t4, s8
                  addi         a2, a2, 817
                  or           zero, s9, t6
                  sra          t4, t1, a6
sub_1_j3:         jalr         t1, a2, -816 #jump sub_1 -> sub_3
                  bne          t2, t5, 14f
                  lui          s8, 1013723
14:               andi         s8, t5, -1393
                  bgeu         t0, a2, 33f
                  bltu         a1, a4, 27f
                  slli         t4, tp, 24
                  auipc        t1, 28116
19:               bgeu         s3, t0, 29f
                  blt          s11, s1, 25f
                  sra          s7, t1, t4
22:               sra          a5, t2, a4
                  sltu         a6, a7, s10
                  slt          t4, a5, a0
25:               add          gp, tp, s2
                  sra          s4, sp, a5
27:               addi         a3, tp, -138
                  andi         tp, s10, -804
29:               ori          s9, t4, -416
                  bne          a6, zero, 37f
                  sltu         a7, s6, t3
                  beq          s5, zero, 51f
33:               add          a4, a4, s6
                  slt          a2, t1, t6
                  andi         a2, s4, 284
                  srli         t5, s11, 31
37:               bne          t0, a6, 44f
                  or           ra, t1, t3
                  add          zero, s8, tp
                  addi         a2, t6, 1027
                  nop
                  sltu         s1, t2, s5
                  addi         t6, sp, -1016
44:               lui          a2, 760673
                  and          zero, a4, a5
                  slli         sp, a6, 12
                  srli         s8, s0, 17
                  ori          s3, s2, 1909
                  bge          s2, s6, 58f
                  bne          a0, a4, 58f
51:               andi         a4, s7, -1095
                  addi         t0, s6, 1899
                  blt          s6, s4, 54f
54:               sltu         t0, s4, zero
                  slt          s10, t5, a0
                  slti         gp, ra, 264
                  auipc        s1, 557137
58:               bltu         s9, t4, 72f
                  slt          t0, sp, s7
                  and          s7, a3, s9
                  nop
                  sll          a5, s8, tp
                  srl          s11, t0, a6
                  auipc        a5, 90022
                  sltu         s7, s11, s7
                  slt          t0, t6, s5
                  sub          s5, gp, a4
                  or           s10, a6, s8
                  slli         s1, a3, 2
                  bne          a2, s9, 82f
                  blt          s1, s5, 83f
72:               srai         a7, s11, 16
                  ori          a6, a2, 591
                  sll          tp, s0, s2
                  srl          a4, zero, t6
                  blt          s4, s1, 85f
                  sub          a3, zero, s3
                  add          zero, s3, s2
                  xor          s9, a2, t5
                  bge          s4, a7, 89f
                  slti         a1, s4, 1436
82:               sltiu        a5, t2, -993
83:               slt          s1, t1, s8
                  sltiu        t3, s2, 1929
85:               srli         s7, ra, 23
                  xor          s5, a7, s6
                  addi         a5, t4, 417
                  sll          a7, t2, s5
89:               ori          s8, s10, 319
                  bltu         a5, a5, 100f
                  addi         t4, a3, -513
                  sub          s10, s2, s4
                  sra          a2, t2, a0
                  addi         t1, a6, -717
                  srl          a1, s3, s0
                  nop
                  srl          s3, s0, t5
                  srli         t3, a4, 11
                  slti         a5, a7, -1327
100:              sltu         a1, t2, a0
                  add          s10, a5, a7
                  blt          a1, s4, 106f
                  lui          a5, 722077
                  add          s2, s11, a7
                  lui          t6, 489753
106:              sub          s0, t0, a6
                  beq          sp, sp, 116f
                  bge          gp, gp, 113f
                  ori          zero, a4, -1926
                  sltiu        a3, s3, 1721
                  andi         t0, t0, 1173
                  add          a3, a1, a7
113:              sltiu        s7, s9, 985
                  bge          t2, t4, 117f
                  srl          a6, s8, a6
116:              sltu         gp, a5, t4
117:              srl          a3, a6, a5
                  slti         a2, t5, 850
                  slt          t3, s9, a3
                  slti         s1, t0, -1840
                  bne          s8, t1, 122f
122:              srli         t5, t5, 28
                  sll          s8, tp, t1
                  bne          s9, s5, 144f
                  ori          s5, sp, -1357
                  addi         s8, t2, 191
                  srli         a3, t0, 12
                  or           s11, a2, gp
                  bne          s7, s1, 138f
                  xori         s8, s9, 1035
                  xor          t4, s4, gp
                  xori         sp, s3, 1319
                  or           s7, s4, s0
                  slt          s9, s10, t0
                  beq          s9, s10, 142f
                  bge          a7, s4, 144f
                  andi         t5, t0, -820
138:              ori          a2, s9, 460
                  slti         a2, s8, 1769
                  ori          a1, s6, 581
                  add          t6, s9, a3
142:              ori          t0, s0, -380
                  blt          a5, sp, 150f
144:              and          t0, ra, t0
                  slti         s5, a4, -555
                  srai         a2, s5, 9
                  nop
                  xori         s1, s11, 1446
                  and          s10, t4, s9
150:              xor          a6, s11, a4
                  add          s2, a4, s1
                  xori         s0, ra, -207
                  bge          s8, t5, 160f
                  sltu         s3, t0, ra
                  sub          tp, tp, s10
                  lui          s8, 166248
                  bne          t2, s10, 162f
                  add          s4, sp, s3
                  or           a6, s3, a4
160:              blt          a5, zero, 165f
                  slli         t6, s0, 18
162:              slti         a7, s3, 1047
                  srli         s10, t6, 17
                  bge          s2, s3, 171f
165:              srl          s11, a3, t5
                  xori         s9, a4, 525
                  sltu         s3, ra, ra
                  add          gp, t3, s10
                  sltiu        s11, t3, -1831
                  bne          a5, t4, 180f
171:              slti         s0, t3, 826
                  xori         s0, s9, -142
                  sub          s5, t6, s4
                  and          s1, s2, zero
                  or           gp, t0, s0
                  bne          tp, ra, 184f
                  and          ra, s11, t0
                  auipc        s10, 480274
                  or           s7, a1, s6
180:              srai         a5, s5, 26
                  xori         s8, a2, -1889
                  nop
                  addi         t3, zero, 1399
184:              and          t6, a1, a4
                  bgeu         t3, a1, 194f
                  slli         s9, s7, 27
                  xori         s3, a3, 88
                  sltu         t3, t5, s7
                  xor          s11, s1, a7
                  auipc        ra, 403783
                  sltu         s4, s11, t6
                  or           s4, s6, ra
                  bgeu         s9, a6, 195f
194:              beq          t3, gp, 204f
195:              xor          s2, a1, a6
                  sll          s11, tp, t4
                  sltiu        s2, a3, 908
                  and          a3, s2, a0
                  xor          a4, zero, zero
                  xori         sp, s4, 337
                  ori          ra, t3, 404
                  slt          a6, a6, a0
                  slti         a2, a0, -1647
204:              ori          a2, gp, 304
                  blt          s9, a1, 206f
206:              or           sp, ra, s9
                  beq          s3, gp, 221f
                  xori         t6, t0, 1347
                  bltu         zero, s5, 220f
                  sra          s3, gp, tp
                  slt          a3, tp, a5
                  blt          t3, s8, 232f
                  bne          t3, t1, 222f
                  addi         t5, s7, 1898
                  nop
                  lui          tp, 38843
                  bge          s6, ra, 221f
                  lui          tp, 60072
                  or           t4, s3, a7
220:              or           zero, t2, t4
221:              auipc        s8, 145677
222:              bge          t5, zero, 231f
                  bltu         ra, t3, 230f
                  sub          t3, t0, s9
                  bge          t0, s8, 234f
                  slli         t5, s0, 13
                  srli         s8, s1, 2
                  lui          tp, 1020799
                  xori         a3, t4, 110
230:              srli         s5, a3, 14
231:              sub          t1, tp, s6
232:              andi         s11, s9, 1161
                  slt          s0, s10, sp
234:              srl          t3, a3, s6
                  srai         s11, s7, 11
                  bltu         zero, t6, 243f
                  blt          tp, tp, 249f
                  or           a1, s1, s1
                  xor          zero, s4, s2
                  srai         t6, a7, 29
                  sra          a6, s1, a2
                  lui          sp, 214068
243:              sltu         s7, t4, s10
                  ori          a6, ra, 447
                  srl          s3, t1, s7
                  xori         s9, t1, -1813
                  bge          s3, a1, 256f
                  sltiu        t5, gp, -803
249:              sltiu        zero, a6, -1959
                  and          s4, a0, s6
                  slti         a3, a7, -640
                  bne          a1, zero, 259f
                  bne          s11, sp, 272f
                  and          t0, s1, s3
                  andi         s4, t5, -1325
256:              blt          s4, s10, 276f
                  addi         s10, gp, 280
                  and          s2, s11, s10
259:              slti         s3, t4, -1268
                  nop
                  beq          s3, s4, 264f
                  ori          t0, s7, 1985
                  or           s2, s7, s8
264:              slti         sp, s4, 278
                  bge          a1, sp, 283f
                  bltu         a3, s1, 274f
                  sub          t1, zero, s0
                  add          a7, sp, sp
                  sub          s8, s8, s6
                  xor          s11, s11, t6
                  xori         s4, t5, 1160
272:              sub          s10, s6, s5
                  slti         t5, a0, 1307
274:              xori         s11, ra, -102
                  sltu         s9, a2, s2
276:              srai         a5, a6, 26
                  srai         t3, s5, 22
                  nop
                  ori          a1, t0, 1051
                  sra          tp, s3, s2
                  beq          t4, s6, 293f
                  bgeu         t2, a7, 289f
283:              xor          s4, s2, t6
                  andi         gp, s5, -1445
                  addi         sp, s0, 50
                  beq          t2, sp, 299f
                  sll          s2, t0, zero
                  srli         ra, a1, 3
289:              srl          s3, a3, a5
                  blt          tp, s9, 291f
291:              beq          zero, a4, 298f
                  add          s5, t1, t1
293:              bne          t4, t3, 300f
                  andi         t0, a5, -1423
                  sll          tp, s10, a3
                  bne          a0, s0, 297f
297:              slt          s3, s11, s8
298:              add          s1, zero, t6
299:              bltu         s3, zero, 308f
300:              xor          a5, a1, gp
                  blt          a6, zero, 321f
                  sub          a2, a3, t5
                  andi         a3, s3, -1786
                  srli         t6, t4, 11
                  sra          s5, t5, a0
                  lui          t6, 444554
                  sltiu        a2, s8, 103
308:              srl          tp, t1, t3
                  srli         t3, s4, 8
                  auipc        s10, 1033746
                  nop
                  sltu         sp, s11, a0
                  sltiu        s2, sp, -7
                  slli         s11, a5, 10
                  xori         tp, s1, -297
                  sub          a5, s8, s2
                  bge          a0, a2, 326f
                  bgeu         t4, t5, 326f
                  andi         a3, t6, -1881
                  srai         a6, t0, 14
321:              add          s11, s9, zero
                  srli         s0, a2, 17
                  sub          t5, tp, t1
                  slt          t4, s4, s3
                  sltu         s10, a4, tp
326:              sub          s7, t4, s2
                  slli         ra, s5, 14
                  bltu         s3, a3, 341f
                  bgeu         t6, a3, 339f
                  sltiu        s9, s1, 349
                  and          a4, a1, tp
                  bne          s5, s9, 341f
                  blt          s6, s2, 336f
                  sltiu        a5, s0, -769
                  add          t0, t4, s4
336:              sltiu        sp, s8, -1405
                  sub          a6, s10, t4
                  sub          s9, a3, s2
339:              sub          t5, t2, a2
                  andi         gp, a2, -1135
341:              sra          zero, t3, zero
                  sltiu        s2, s8, -386
                  xor          a5, a6, gp
                  andi         s7, s5, 1722
                  sll          a7, t5, a1
                  srl          s8, a2, s8
                  addi         s10, sp, 682
                  slli         a1, a0, 4
                  ori          ra, ra, 91
                  sll          zero, s9, a3
                  bge          a4, s2, 363f
                  sltiu        s5, s7, -1337
                  and          s3, s9, a5
                  slt          t4, s5, t6
                  ori          s11, t4, -1887
                  xori         t3, a4, 1243
                  sra          s7, t6, s6
                  bgeu         s9, s3, 377f
                  or           s10, s10, a5
                  bgeu         s8, s11, 374f
                  andi         a7, a3, 126
                  blt          a2, a0, 382f
363:              slt          s9, zero, s10
                  andi         a6, sp, 358
                  slti         t5, a6, 17
                  srli         s5, s5, 16
                  add          tp, sp, a6
                  addi         a5, a5, 1845
                  beq          sp, a0, 379f
                  bgeu         s7, a7, 377f
                  and          a1, s6, t2
                  bge          t2, zero, 383f
                  sltu         t5, t3, a4
374:              xori         a2, s3, 380
                  bne          t0, s0, 376f
376:              andi         a2, s11, 951
377:              beq          ra, t6, 389f
                  srai         a5, s5, 23
379:              sltu         zero, s6, t6
                  slt          s9, gp, s1
                  sub          tp, t5, sp
382:              xori         a1, a5, 1821
383:              andi         a2, s6, -1215
                  xor          t3, a5, s2
                  addi         s11, t4, 183
                  lui          t0, 510615
                  sltiu        t6, s5, 1390
                  xori         zero, gp, -760
389:              auipc        a5, 139897
                  srl          s2, s3, sp
                  srai         s1, a2, 28
                  lui          s7, 62339
                  sra          a1, s7, a3
                  slli         s2, t3, 23
                  xor          t1, s6, s0
                  bltu         s7, s11, 405f
                  auipc        s11, 730133
                  sltiu        a2, s8, -215
                  bge          a5, gp, 406f
                  xor          a5, s8, sp
                  addi         s0, s9, 1241
                  lui          a6, 316123
                  srli         t4, a5, 21
                  bltu         a0, gp, 412f
405:              srli         a1, t2, 16
406:              beq          t1, s8, 415f
                  srl          t1, a5, a7
                  srai         s0, t4, 16
                  beq          ra, a0, 414f
                  sltiu        s10, s9, -2045
                  xor          s4, a2, s1
412:              slti         s10, a5, -742
                  sra          t0, s6, a5
414:              xor          ra, s9, a7
415:              xor          t5, a4, t0
                  ori          tp, a4, 993
                  srai         gp, t0, 29
                  bgeu         s9, s1, 436f
                  bge          s0, gp, 423f
                  sltu         s5, a7, a6
                  srl          s5, a0, a4
                  sll          t0, t5, s0
423:              auipc        a1, 682731
                  blt          a2, a7, 426f
                  lui          s8, 219439
426:              sra          tp, t4, s8
                  srl          s4, a1, t2
                  add          s1, a0, t3
                  or           zero, s3, s5
                  ori          zero, t3, -1976
                  blt          a0, t0, 438f
                  slti         s9, t2, -1992
                  sltiu        t3, sp, -1082
                  sll          t1, s2, s3
                  or           ra, s11, t0
436:              sra          s0, a4, s6
                  srai         s4, a5, 28
438:              beq          gp, s1, 443f
                  srli         tp, s1, 20
                  srl          s4, t1, a5
                  andi         t0, a5, 1441
                  srli         a6, s5, 5
443:              slti         a7, s2, -1393
                  slli         t4, s6, 30
                  bltu         a7, s11, 450f
                  sll          s5, s5, s7
                  auipc        a3, 693076
                  lui          t5, 485128
                  beq          s4, s2, 458f
450:              sll          s2, s8, t0
                  addi         s5, s8, 565
                  xori         s1, s4, 787
                  lui          zero, 156492
                  beq          a0, t3, 463f
                  or           s10, a3, s2
                  beq          s10, t3, 470f
                  sltu         a5, a3, s3
458:              xor          s3, t3, s6
                  sra          sp, gp, a6
                  bgeu         a6, s3, 470f
                  srli         zero, s5, 27
                  srl          s2, t0, t4
463:              srai         a1, s11, 5
                  sra          a2, s10, s6
                  srl          t5, s10, s11
                  add          t3, s3, s7
                  bltu         t4, s4, 476f
                  add          a1, t3, t6
                  srli         t1, a5, 3
470:              bge          s2, a5, 490f
                  sltiu        a4, t3, 650
                  bgeu         s7, t6, 491f
                  andi         a3, s2, -298
                  andi         s9, a2, 1325
                  sll          s3, a1, a0
476:              slt          t6, s3, s4
                  srli         s8, s5, 31
                  sll          tp, a2, t1
                  sra          s2, s4, s8
                  srai         s7, a1, 12
                  and          s1, ra, t4
                  addi         s0, s11, -1757
                  bge          a1, t1, 490f
                  srli         zero, s9, 29
                  slt          s10, a4, zero
                  and          a2, a7, sp
                  sltu         gp, s9, a2
                  andi         gp, zero, 1964
                  sll          ra, t1, t1
490:              blt          s5, s5, 497f
491:              bge          s7, t0, 503f
                  slli         a6, s11, 17
                  lui          s10, 861132
                  bne          s3, s1, 505f
                  srl          t6, s11, s2
                  or           a1, ra, a5
497:              xori         gp, a1, -1235
                  sll          s5, s2, s10
                  slli         a3, t5, 5
                  bne          s0, a1, 501f
501:              sub          s2, s3, t4
                  andi         s9, t5, 986
503:              slli         s7, t0, 16
                  bgeu         a7, t3, 514f
505:              bge          s3, a4, 513f
                  sltu         a7, t6, a7
                  slti         s5, s4, -1466
                  lui          s0, 744700
                  and          t4, s2, s5
                  addi         t1, tp, -745
                  bge          t6, s11, 513f
                  sltu         t5, s10, a4
513:              xor          t3, t6, a1
514:              andi         s0, t4, 737
                  srai         sp, zero, 24
                  slli         s7, t4, 27
                  beq          sp, s4, 537f
                  beq          t6, t6, 522f
                  auipc        s1, 959216
                  xor          s4, s10, a3
                  sra          zero, ra, sp
522:              blt          ra, a6, 531f
                  srl          s10, t1, a0
                  bne          a2, s2, 533f
                  blt          gp, s4, 526f
526:              slli         s0, s4, 1
                  blt          tp, a1, 545f
                  and          a5, ra, s11
                  beq          a2, s10, 536f
                  srai         sp, s3, 24
531:              srai         gp, a3, 1
                  slt          s2, s11, t2
533:              bgeu         s0, s11, 540f
                  addi         s9, s1, 211
                  bne          a6, t2, 547f
536:              beq          a3, s10, 539f
537:              sll          a1, a2, sp
                  or           t3, gp, s10
539:              blt          zero, t3, 547f
540:              add          ra, s2, gp
                  sll          s7, s10, t0
                  and          s2, t2, gp
                  sub          s2, s0, gp
                  sltiu        s1, t0, -908
545:              xor          ra, t3, a4
                  lui          s7, 233189
547:              bltu         a1, t1, 554f
                  add          t3, sp, a7
                  sub          a5, a5, s9
                  srli         s7, t1, 10
                  bgeu         s9, t3, 556f
                  bge          t1, t1, 565f
                  sltu         t0, a5, ra
554:              srl          a3, s7, a1
                  srli         t5, t4, 10
556:              bgeu         sp, s0, 576f
                  andi         s10, s0, -47
                  sltu         a5, t3, a2
                  slli         sp, s11, 14
                  sltiu        s7, s5, -799
                  bgeu         s1, t3, 573f
                  bltu         s1, s3, 569f
                  bge          s0, a5, 565f
                  sub          t6, a1, t1
565:              slt          t6, s5, t1
                  slli         a6, s9, 28
                  sra          a2, t1, s5
                  beq          a1, a2, 578f
569:              beq          s11, a2, 570f
570:              lui          s5, 253423
                  blt          a0, s7, 580f
                  andi         t0, t2, 57
573:              xor          t4, t0, sp
                  slli         s9, s6, 2
                  sltiu        ra, a4, -1000
576:              sltu         s8, a0, t6
                  sra          a7, s5, s4
578:              blt          s2, s6, 587f
                  auipc        s4, 134877
580:              xori         t6, gp, 1052
                  slti         a1, zero, -1382
                  bge          a0, a0, 587f
                  addi         s9, gp, 1865
                  srli         gp, sp, 29
                  or           sp, t6, a7
                  bge          s7, t3, 598f
587:              sub          a4, s9, gp
                  lui          t0, 904343
                  sltu         sp, s4, s5
                  nop
                  bltu         a3, s1, 594f
                  blt          t4, s8, 602f
                  or           s2, s9, t0
594:              bltu         a5, t4, 613f
                  add          a5, t4, s9
                  addi         a5, a0, 1076
                  addi         s5, t0, -1870
598:              lui          sp, 185037
                  srai         a4, t3, 23
                  sltiu        gp, t3, -781
                  nop
602:              addi         s10, s10, -1729
                  slt          s1, s11, s10
                  blt          t6, s6, 612f
                  auipc        a4, 1007155
                  add          t4, zero, a0
                  ori          s0, t6, 195
                  lui          s10, 661538
                  srai         s11, a1, 25
                  xori         a5, gp, 1002
                  slt          s5, s11, s4
612:              sltiu        s5, a0, 1062
613:              nop
                  or           a2, t2, t3
                  bne          a1, t3, 623f
                  addi         t5, s2, -664
                  slt          s2, s6, t4
                  sll          s3, s11, a6
                  srli         s3, s10, 17
                  bltu         t4, s0, 627f
                  xori         s2, s9, -1918
                  bge          s0, a2, 642f
623:              srli         s10, t4, 24
                  xori         gp, s5, -1446
                  sub          a6, t4, s8
                  lui          a7, 716214
627:              xor          a4, ra, s3
                  slt          a5, a3, s5
                  and          s10, s0, s2
                  sll          ra, tp, a5
                  sltu         t1, t2, a7
                  andi         zero, s1, -1878
                  bne          t6, a6, 644f
                  sltiu        zero, s3, 767
                  bgeu         a7, t4, 642f
                  bge          t4, a5, 645f
                  sub          zero, a7, zero
                  slti         s10, t2, -726
                  sltiu        t1, a2, -450
                  addi         t6, s5, 1915
                  sll          a2, a2, a0
642:              sra          s2, s7, s11
                  bltu         s6, a1, 656f
644:              auipc        a5, 565766
645:              srai         t4, ra, 2
                  sra          a4, s1, s7
                  or           tp, a6, s3
                  sll          a5, s5, a0
                  andi         ra, ra, -618
                  nop
                  lui          t3, 954823
                  srai         t6, a3, 2
                  beq          sp, s7, 654f
654:              sub          a3, t4, t0
                  sra          a6, t4, s4
656:              sra          t5, a5, t1
                  sltu         ra, s7, a7
                  slt          sp, t3, gp
                  blt          a2, s1, 677f
                  srai         sp, s3, 26
                  sra          s1, a6, a6
                  andi         ra, s4, -1389
                  slli         t3, t4, 11
                  bgeu         s10, s6, 669f
                  sub          a3, t1, a4
                  sltu         a1, t6, a2
                  auipc        t6, 731496
                  auipc        s8, 828649
669:              or           t0, a6, a0
                  sltu         s2, s0, a2
                  srai         ra, s6, 9
                  xori         a1, s2, 57
                  sub          sp, t1, t6
                  xori         s0, s1, -374
                  auipc        ra, 509068
                  auipc        a7, 450117
677:              sltiu        s8, s8, -1118
                  srl          t5, zero, t2
                  slt          a6, t3, a4
                  and          a3, a5, tp
                  nop
                  andi         a4, a6, 716
                  nop
                  bgeu         s7, t3, 693f
                  slt          a6, s2, a5
                  and          t4, a7, s0
                  lui          sp, 235471
                  auipc        t6, 877461
                  sltiu        a4, gp, 1753
                  sub          t4, tp, a3
                  sll          zero, t5, s3
                  lui          zero, 46042
                  slti         t3, s2, -1338
                  srl          s1, ra, a5
                  auipc        a4, 111271
sub_1_j4:         jal          t1, sub_2 #jump sub_1 -> sub_2
                  bge          a7, t3, 694f
                  sltu         sp, t6, t2
                  nop
693:              and          s10, s0, s8
694:              and          s0, zero, a1
                  add          a7, a6, s4
                  sltiu        s11, a2, -1367
                  bltu         t3, s1, 704f
                  sll          gp, a2, t0
                  sltu         s3, t6, t5
                  bne          a2, a4, 709f
                  slt          s3, s10, a5
                  andi         a4, s2, -599
                  srli         a3, t6, 19
704:              srli         t5, t4, 22
                  xor          a1, t2, zero
                  xor          t0, tp, t0
                  srl          a3, t0, t0
                  ori          t0, a7, 762
709:              sltu         a7, t2, gp
                  and          t6, t5, a1
                  auipc        s11, 336253
                  sltu         s11, a3, s8
                  slti         gp, s6, 1281
                  sub          t4, s5, a2
                  ori          sp, s6, -1606
                  srli         ra, a2, 12
                  bgeu         s5, sp, 724f
                  sub          t0, a0, s2
                  sltu         t0, sp, sp
                  add          gp, s9, s1
                  slli         t0, tp, 4
                  and          a3, a3, gp
                  sub          t6, t4, ra
724:              or           t3, s7, t2
                  slli         sp, t1, 18
                  ori          a7, s2, -1786
                  and          t5, t0, a5
                  sra          s11, s11, ra
                  sltiu        s8, a0, 1957
                  srai         s3, zero, 27
                  and          s3, a0, t4
                  sltiu        sp, a6, 664
                  bltu         s8, s3, 747f
                  and          a3, a3, s6
                  slli         t1, a2, 28
                  blt          a4, t6, 748f
                  bgeu         a6, gp, 746f
                  srai         s10, s7, 12
                  srli         zero, s6, 15
                  sll          s3, s4, t4
                  sll          t0, s8, gp
                  srai         t5, s1, 4
                  addi         s4, s4, -1087
                  slti         zero, s0, 975
                  sra          t6, s10, s8
746:              srli         s9, s9, 16
747:              andi         s2, s6, -763
748:              add          ra, sp, s0
                  lui          a4, 58179
                  slt          t0, t6, t6
                  addi         a4, t1, 1240
                  sltiu        ra, t0, 1324
                  bne          s6, zero, 758f
                  auipc        a6, 1032992
                  srli         s4, s3, 10
                  sltu         tp, s8, a5
                  lui          a5, 545170
758:              sra          a3, t1, a4
                  nop
                  slt          a5, a1, s8
                  xori         s11, t1, -1656
                  slti         a3, tp, 171
                  lw           t1, 4(a0)
                  ori          a3, sp, 1792
                  or           s9, t4, a5
                  andi         gp, t4, -1067
                  sll          a6, s6, s5
                  sra          a3, s5, t5
                  addi         a0, a0, 48
                  slt          s2, sp, ra
                  srl          a6, t0, a3
1743:             addi x3, x6, 1
1743:             jalr x3, x3, 0
sub_5:            sltiu        a4, t4, -961
                  xor          t5, zero, t0
                  sra          s7, s9, s0
                  bge          a1, t0, sub_5_stack_p
                  andi         a1, a2, 1757
                  slli         a4, a1, 0
sub_5_stack_p:    addi         a0, a0, -40
                  sw           t1, 4(a0)
                  srai         s3, sp, 20
                  srli         s2, s4, 21
                  or           t0, a2, t3
                  nop
                  la           s10, region_1+4006 #start riscv_load_store_hazard_instr_stream_0
                  sb           s5, -1667(s10)
                  lhu          zero, -1848(s10)
                  lbu          s2, -2009(s10)
                  sb           s2, -1009(s10)
                  sb           s7, -1467(s10)
                  lb           gp, -210(s10)
                  sb           s4, -210(s10)
                  lh           s11, -534(s10)
                  sh           s9, -1726(s10)
                  lh           t5, -1726(s10)
                  lb           a7, -2029(s10)
                  lb           s4, -2029(s10)
                  sh           a4, -1072(s10)
                  sw           s4, -158(s10)
                  lhu          s11, -158(s10)
                  lui          sp, 836627
                  and          t0, s0, s9
                  lbu          a6, -553(s10)
                  lh           s8, -1554(s10) #end riscv_load_store_hazard_instr_stream_0
                  la           t1, region_1+677 #start load_store_instr_stream_1
                  la           a3, region_1+2888 #start load_store_instr_stream_3
                  sb           s11, 2020(t1)
                  la           s4, region_1+892 #start load_store_instr_stream_2
                  lh           gp, -1954(a3)
                  sw           t3, -301(t1)
                  lh           sp, 202(a3)
                  lb           t6, -1789(a3)
                  sb           s2, 13(s4)
                  sb           s3, -830(a3)
                  la           a4, region_1+1434 #start load_store_instr_stream_0
                  sh           a4, -464(a3)
                  lb           s10, 863(a3)
                  lb           s2, 29(a4)
                  lb           sp, 1551(t1)
                  lhu          s5, -1954(a3)
                  lb           s8, -7(s4)
                  sb           t6, -14(s4)
                  sb           s10, -11(a4)
                  lbu          a6, 1162(t1)
                  lw           t3, 16(s4)
                  lhu          s3, -547(t1)
                  sb           gp, -63(a4)
                  sb           t6, 402(t1)
                  lbu          t3, 8(s4)
                  lbu          t6, 1932(t1) #end load_store_instr_stream_1
                  lbu          t0, 24(a4)
                  lb           tp, 315(a3) #end load_store_instr_stream_3
                  sb           s6, -4(s4) #end load_store_instr_stream_2
                  lh           zero, 64(a4) #end load_store_instr_stream_0
                  la           s8, region_0+2907 #start load_store_instr_stream_0
                  sb           s1, -14(s8)
                  la           a7, region_1+2993 #start load_store_instr_stream_1
                  sh           s9, -13(a7)
                  lbu          t0, 0(s8)
                  lbu          sp, 4(s8)
                  lh           a6, -7(a7)
                  lbu          a3, -16(s8)
                  lbu          a1, -7(s8)
                  sb           t2, -6(a7)
                  lhu          s0, -15(a7)
                  lw           t3, -15(s8)
                  lbu          a4, -4(a7) #end load_store_instr_stream_1
                  lbu          gp, 5(s8) #end load_store_instr_stream_0
                  bge          t2, zero, 17f
                  slti         gp, t4, 1635
                  blt          t1, t2, 11f
                  bgeu         gp, a0, 11f
                  sub          sp, a0, a0
                  xor          a7, s6, s5
                  addi         a6, a1, 959
                  bne          a6, s4, 17f
                  slti         t1, s0, -1608
                  auipc        s0, 501514
                  slli         a7, a7, 29
11:               sll          s2, s8, s0
                  nop
                  beq          s2, t6, 25f
                  sll          s4, s11, zero
                  ori          t3, t1, -1910
                  bne          s4, s10, 21f
17:               sll          a3, s8, tp
                  nop
                  bgeu         s0, a4, 35f
                  sub          a6, s10, s2
21:               bltu         t2, gp, 41f
                  slli         a5, s9, 22
                  add          ra, s11, ra
                  srai         ra, s10, 26
25:               xori         t1, a5, 963
                  ori          s2, s4, 172
                  bgeu         s1, a6, 38f
                  sra          s2, a4, a5
                  srai         t5, a5, 8
                  sltiu        s2, s4, 1172
                  xor          a3, a0, s7
                  blt          a4, s2, 37f
                  sltiu        t0, a6, -1133
                  andi         s0, a2, 1978
35:               sll          s4, ra, a0
                  lui          t6, 1015852
37:               lui          a5, 669180
38:               ori          t0, s7, -931
                  addi         s1, tp, 58
                  srli         s9, t4, 29
41:               auipc        s9, 805314
                  sltiu        s9, s10, -542
                  slt          tp, t5, a6
                  auipc        s11, 348843
                  blt          s6, t1, 58f
                  srai         t5, tp, 9
                  srai         ra, s9, 27
                  xori         zero, s5, 363
                  sltiu        s0, ra, 1762
                  bne          s0, a5, 51f
51:               add          s2, s8, t3
                  bgeu         t1, s7, 63f
                  slti         t1, t0, 1367
                  blt          s6, a2, 58f
                  lui          zero, 650882
                  srl          t3, t6, a4
                  xor          t6, t3, t2
58:               sltiu        s4, s9, 912
                  srli         a6, t4, 0
                  bge          a0, a1, 66f
                  slti         ra, s11, -326
                  sll          tp, sp, s5
63:               bltu         s5, t1, 71f
                  xor          s7, s11, a1
                  add          a3, s10, a5
66:               slti         sp, ra, 1205
                  sub          a3, zero, t2
                  lui          t4, 591090
                  xor          a4, a7, t6
                  sub          s3, a1, sp
71:               and          ra, s7, a4
                  sub          s8, ra, s8
                  srai         s2, s10, 7
                  andi         s5, t6, -1644
                  slti         s9, sp, -764
                  xori         a3, s10, -243
                  slti         t6, zero, -1722
                  sra          s4, s3, a5
                  bgeu         s3, s3, 94f
                  nop
                  srli         a5, s5, 6
                  srl          sp, a4, t0
                  slli         t0, s1, 5
                  or           ra, t1, a0
                  srli         a5, s6, 12
                  addi         s3, s0, 1632
                  sltu         ra, gp, s1
                  xori         a7, s9, 1152
                  bne          s11, s2, 97f
                  ori          t3, s4, 1623
                  nop
                  xori         gp, a5, -1784
                  sltiu        s10, sp, 1558
94:               bne          s7, zero, 95f
95:               and          s7, s10, a3
                  bge          a4, tp, 111f
97:               bne          s11, s6, 111f
                  sll          zero, a0, s5
                  sra          s2, a4, s7
                  srai         s10, a1, 5
                  srai         s4, zero, 3
                  ori          a4, gp, -1306
                  or           s4, zero, s6
                  addi         s4, s4, -1979
                  beq          t2, a5, 124f
                  bgeu         a2, tp, 108f
                  add          a4, a0, t0
108:              sub          t3, a3, a1
                  sll          s1, sp, s9
                  sra          t3, tp, t0
111:              xori         a4, t5, -723
                  or           s9, zero, t0
                  auipc        s5, 141483
                  bgeu         a7, t2, 132f
                  sll          t1, s7, s11
                  xor          t4, s0, a7
                  add          t6, s9, s6
                  sll          tp, s2, a5
                  la           s11, region_1+2435 #start riscv_hazard_instr_stream_0
                  sra          zero, a7, t4
                  srl          a2, s8, t4
                  sra          a2, a2, a5
                  or           a2, zero, a7
                  ori          a2, zero, -1085
                  slt          zero, s8, t4
                  lh           t4, 175(s11)
                  sh           a7, 505(s11)
                  srl          a7, a5, a7
                  lbu          a2, 1020(s11)
                  lh           a5, -1427(s11)
                  xori         a7, a7, -2035
                  lb           zero, 156(s11)
                  lw           a5, 893(s11)
                  sltu         a7, t4, a2
                  lh           a2, 239(s11)
                  lbu          a2, -1862(s11)
                  auipc        a7, 130660
                  lh           s8, -991(s11)
                  sb           a5, -562(s11)
                  lhu          a2, -843(s11)
                  sra          s8, zero, t4
                  srl          a5, a7, a7
                  add          a7, a2, a7
                  lbu          s8, 811(s11)
                  lbu          a2, 172(s11)
                  srl          s8, a2, s8
                  lbu          a5, 623(s11)
                  and          t4, s8, a7
                  nop
                  lbu          s8, -1476(s11)
                  slli         a2, a7, 16
                  lbu          zero, 1644(s11) #end riscv_hazard_instr_stream_0
                  lui          a7, 953896
                  bltu         a4, tp, 136f
                  blt          s5, t0, 141f
                  bltu         a6, a5, 134f
                  and          s7, s4, s11
124:              srl          s3, sp, s2
                  andi         s10, t4, 704
                  bltu         a0, s0, 134f
                  and          sp, t3, a3
                  or           ra, a1, s9
                  andi         zero, t6, -44
                  auipc        a3, 583394
                  slti         t5, sp, -626
132:              sll          s11, s11, t4
                  srl          t6, t5, s9
134:              slti         t1, t5, -1828
                  sub          a3, s9, a3
136:              ori          t6, s7, -2027
                  xori         t6, a4, 1765
                  bltu         a2, ra, 147f
                  lui          a1, 128631
                  bge          t4, t6, 150f
141:              sub          s5, s6, t4
                  slti         sp, t3, 1563
                  sltiu        a1, a3, -883
                  xori         s5, s3, -1703
                  or           t5, s2, s0
                  bne          s6, a4, 161f
147:              blt          s8, s10, 155f
                  srli         a7, t1, 28
                  nop
150:              srl          a7, a0, sp
                  slti         s0, s4, -1739
                  sltiu        a2, s2, 2046
                  nop
                  sltiu        tp, a0, 644
155:              xor          s0, tp, zero
                  slli         zero, sp, 30
                  srl          t1, t2, zero
                  bge          s10, t1, 159f
159:              lui          a5, 759251
                  sltu         t5, s7, a3
161:              addi         s9, a6, -1474
                  nop
                  bltu         gp, s7, 179f
                  bne          a2, s11, 169f
                  nop
                  blt          s9, s1, 174f
                  ori          t6, a3, -1798
                  auipc        t4, 814022
169:              bgeu         s11, t4, 183f
                  srl          t6, s1, ra
                  sub          s7, tp, s11
                  ori          s11, ra, -1669
                  slt          s3, ra, t1
174:              sltu         a7, a4, t6
                  slt          t5, a6, a4
                  sll          a3, a4, a3
                  nop
                  add          t4, t2, t6
179:              xori         t5, a3, -2023
                  sltu         t5, a0, t4
                  srli         zero, s6, 30
                  sltu         ra, s8, s6
183:              xor          gp, a6, s8
                  lw           t1, 4(a0)
                  sltiu        a7, sp, 1473
                  xori         t4, a4, -1184
                  addi         s3, s11, -325
                  addi         a0, a0, 40
                  andi         s1, a6, 1552
300:              addi x4, x6, 0
300:              jalr x4, x4, 0
sub_4:            slti         s10, a4, -431
                  and          a5, a6, t5
                  sll          s3, a4, s6
                  addi         a1, s10, 187
                  addi         a0, a0, -28
                  slt          a1, s8, ra
                  sw           t1, 4(a0)
                  sra          s8, s2, s8
                  xor          a4, a7, s2
                  la           s9, sub_5
                  nop
                  addi         s9, s9, 568
                  nop
                  xor          s8, t3, a6
                  slti         a6, s7, 1260
                  andi         zero, s0, -1312
sub_4_j6:         jalr         t1, s9, -568 #jump sub_4 -> sub_5
                  beq          a1, s9, 19f
                  and          zero, a5, gp
                  lui          t6, 123633
                  sll          s0, a1, a5
                  bgeu         a7, t3, 10f
                  lui          a2, 769284
                  sra          sp, t5, a7
                  lui          s2, 742798
                  bltu         a0, s11, 17f
                  srai         s10, a5, 17
10:               sll          s3, a1, s6
                  auipc        s10, 973102
                  sub          a2, s0, t6
                  sltu         a1, a3, t2
                  and          s10, s5, s7
                  xor          gp, s4, s10
                  sra          t5, s8, a3
17:               beq          sp, a6, 31f
                  sra          t4, s1, tp
19:               sub          a3, s7, s5
                  xori         gp, gp, -1165
                  bge          a3, s6, 30f
                  xori         t3, t3, 1106
                  and          s8, s6, s9
                  bne          a0, t1, 30f
                  auipc        zero, 91919
                  andi         a2, zero, -1602
                  beq          t2, sp, 34f
                  and          a7, s10, s0
                  lui          t6, 854163
30:               auipc        s11, 821715
31:               xor          s11, ra, s9
                  srai         s0, s1, 24
                  blt          ra, ra, 46f
34:               addi         zero, sp, 134
                  add          s5, s2, sp
                  slli         s7, a2, 22
                  addi         a3, a3, 951
                  xor          s1, s2, a4
                  sra          a1, gp, a4
                  slt          s2, t3, s6
                  nop
                  ori          a1, t5, -891
                  sra          gp, s10, ra
                  xor          sp, a7, s4
                  sll          gp, a5, s3
46:               sltu         a4, s4, s2
                  slli         s0, s1, 8
                  sra          s1, ra, t0
                  nop
                  nop
                  xor          t6, t0, s7
                  bne          zero, a5, 54f
                  sra          s9, s0, a0
54:               slt          a4, sp, t1
                  auipc        s3, 753517
                  addi         tp, s0, -193
                  lw           t1, 4(a0)
                  addi         a0, a0, 28
                  srl          a6, tp, a0
77:               addi x19, x6, 0
77:               jalr x19, x19, 0
sub_3:            addi         a0, a0, -20
                  slti         a3, a2, -1441
                  sltu         s1, s2, s2
                  add          a2, t4, a2
                  sw           t1, 4(a0)
                  addi         s8, a6, -1888
                  la           sp, region_0+2156 #start riscv_hazard_instr_stream_0
                  addi         t5, s2, -761
                  lui          s0, 624285
                  sh           a2, -112(sp)
                  slli         s0, zero, 18
                  lb           t5, 200(sp)
                  or           t0, t0, s2
                  sra          zero, zero, t5
                  sb           s0, 5(sp)
                  nop
                  srl          s0, s2, s0
                  sltu         zero, t0, a2
                  srli         t0, t0, 13
                  sub          s0, a2, t0
                  sb           s2, -185(sp)
                  nop
                  slli         a2, t5, 1
                  addi         s0, zero, 9
                  sub          t5, a2, s0
                  and          s2, s2, s2
                  andi         a2, t5, -1955
                  and          a2, zero, t5
                  lb           a2, -177(sp)
                  lui          s0, 105170
                  lbu          s0, -219(sp)
                  lbu          t0, -213(sp)
                  sra          s2, zero, zero
                  addi         t5, a2, 453
                  lbu          s2, -110(sp)
                  sh           a2, -206(sp)
                  srli         a2, t0, 5
                  sb           s0, -23(sp) #end riscv_hazard_instr_stream_0
                  la           a5, region_0+3018 #start riscv_load_store_hazard_instr_stream_4
                  lh           s7, -1640(a5)
                  lb           t4, 381(a5)
                  sb           ra, 381(a5)
                  lbu          t0, -909(a5)
                  lbu          a3, -909(a5)
                  lb           s7, -2039(a5)
                  sb           s0, -1495(a5)
                  lbu          t3, -1201(a5)
                  srai         s5, t6, 15
                  andi         s8, s7, -1156
                  lbu          s3, 693(a5)
                  lui          t1, 470427
                  sb           s9, 693(a5)
                  lh           a4, -644(a5)
                  lbu          s1, 796(a5)
                  slt          s11, sp, s11
                  lh           t5, 796(a5)
                  lhu          a7, 594(a5)
                  or           s4, tp, s7
                  lw           ra, 594(a5)
                  sb           s8, -450(a5)
                  sb           a2, 855(a5)
                  and          gp, sp, a6
                  lbu          t4, 855(a5) #end riscv_load_store_hazard_instr_stream_4
                  la           sp, region_0+1819 #start load_store_instr_stream_2
                  la           a2, region_0+1834 #start load_store_instr_stream_0
                  la           s3, region_0+1284 #start load_store_instr_stream_1
                  la           t3, region_0+3689 #start load_store_instr_stream_3
                  lw           a4, 209(sp)
                  sb           t0, 9(t3)
                  lbu          s1, 0(a2)
                  sb           sp, 139(s3)
                  lbu          zero, 39(s3)
                  lbu          gp, 1054(sp)
                  sb           s9, 0(t3)
                  sb           zero, -137(s3)
                  lb           s8, -11(t3)
                  sb           a6, 518(sp)
                  sh           s10, -14(a2)
                  lh           s2, -439(sp)
                  lbu          s0, 5(a2)
                  sb           t6, 0(t3)
                  lb           s10, 1595(sp)
                  lbu          t1, -167(s3)
                  sb           zero, 12(t3)
                  lbu          t6, -3(t3)
                  lb           s0, -241(s3)
                  lb           s0, -190(sp)
                  sb           t6, -6(t3)
                  lbu          s2, -872(sp)
                  sb           s5, 4(a2)
                  sb           s9, 963(sp)
                  lh           t6, -126(s3) #end load_store_instr_stream_1
                  lh           s0, -1135(sp) #end load_store_instr_stream_2
                  sb           s5, -3(t3) #end load_store_instr_stream_3
                  sh           t0, -2(a2) #end load_store_instr_stream_0
                  la           t5, region_1+1251 #start riscv_load_store_hazard_instr_stream_2
                  lb           t3, -213(t5)
                  andi         a5, tp, 1625
                  andi         a2, a3, 1305
                  slt          a4, s6, gp
                  sh           t5, -213(t5)
                  lbu          s1, -213(t5)
                  lh           s8, -213(t5)
                  lhu          s11, -213(t5)
                  ori          t1, t4, -804
                  lh           s1, -213(t5)
                  sb           s11, -213(t5)
                  lb           a5, -213(t5)
                  lb           a2, -248(t5)
                  ori          s10, a2, -994
                  addi         zero, ra, -1304
                  lb           a7, -248(t5) #end riscv_load_store_hazard_instr_stream_2
                  la           s9, region_1+2172 #start riscv_load_store_hazard_instr_stream_0
                  slt          s0, tp, t0
                  lw           a3, 944(s9)
                  xori         s3, s10, -179
                  andi         t6, a5, -1229
                  lbu          s10, -553(s9)
                  lbu          t1, 1809(s9)
                  lbu          a4, 1809(s9)
                  sb           s10, 1809(s9)
                  sra          zero, gp, tp
                  lb           sp, -1731(s9)
                  lb           s10, -1731(s9)
                  lb           a4, -1132(s9)
                  sb           a2, -1132(s9)
                  lb           a6, -1132(s9)
                  lb           t0, -1132(s9)
                  lb           s8, -460(s9)
                  lh           s3, -460(s9)
                  sh           s2, -460(s9)
                  sb           a6, -460(s9) #end riscv_load_store_hazard_instr_stream_0
                  la           a5, region_0+1077 #start load_store_instr_stream_0
                  lbu          a2, -182(a5)
                  la           t6, region_1+880 #start load_store_instr_stream_1
                  sh           t1, -10(t6)
                  lhu          s10, -14(t6)
                  lb           zero, -15(t6)
                  lh           t4, -12(t6)
                  lbu          a4, -9(t6)
                  lhu          sp, -251(a5)
                  lbu          s1, -12(t6)
                  sw           s10, -8(t6)
                  lh           t5, -8(t6)
                  sb           a5, -11(t6)
                  sb           s4, 0(a5)
                  lb           s1, 22(a5)
                  lw           a1, -8(t6) #end load_store_instr_stream_1
                  sh           t0, 3(a5)
                  sb           a7, -214(a5) #end load_store_instr_stream_0
sub_3_6:          jal          t1, 11f
0:                jal          ra, 2f
1:                jal          ra, 8f
2:                jal          ra, 10f
3:                jal          a2, 13f
4:                jal          ra, 6f
5:                jal          ra, 7f
6:                jal          ra, 0b
7:                jal          ra, 1b
8:                jal          ra, 4b
9:                jal          ra, 3b
10:               jal          ra, 15f
11:               jal          tp, 12f
12:               jal          t5, 9b
13:               jal          t1, 5b
14:               jal          s7, 16f
15:               jal          s10, 14b
16:               nop
                  la           a3, region_0+2508 #start load_store_instr_stream_1
                  lw           s0, -4(a3)
                  la           t0, region_1+1967 #start load_store_instr_stream_0
                  lh           gp, 13(t0)
                  sb           zero, 4(t0)
                  sh           t3, 6(a3)
                  sw           tp, 12(a3)
                  lb           gp, 15(t0)
                  lbu          a4, 2(a3)
                  sb           t5, -16(t0)
                  lb           s8, 9(a3)
                  lbu          a2, 14(t0)
                  sb           gp, 11(t0)
                  lbu          s4, -4(a3) #end load_store_instr_stream_1
                  sb           sp, -11(t0) #end load_store_instr_stream_0
                  la           sp, region_1+3832 #start riscv_hazard_instr_stream_2
                  lw           a5, -4(sp)
                  slt          s7, zero, s7
                  or           a5, s3, t4
                  xor          s7, s7, s3
                  sltu         t4, s7, a5
                  lbu          a5, 3(sp)
                  add          s3, zero, s3
                  lbu          s3, 5(sp)
                  slli         ra, zero, 24
                  lh           s7, -6(sp)
                  lh           zero, -16(sp)
                  xor          t4, ra, ra
                  sub          zero, t4, a5
                  lw           zero, 0(sp)
                  lbu          s7, 1(sp)
                  sb           s3, -13(sp)
                  srl          s7, zero, ra
                  xor          ra, ra, t4
                  sub          ra, a5, ra
                  sb           s3, -7(sp)
                  lb           s7, -4(sp)
                  nop
                  lb           t4, 15(sp) #end riscv_hazard_instr_stream_2
                  la           t4, region_1+3685 #start load_store_instr_stream_1
                  la           s2, region_1+351 #start load_store_instr_stream_0
                  sh           t0, -23(t4)
                  lhu          a6, -33(t4)
                  lh           t1, 39(t4)
                  sw           s1, -1(t4)
                  sb           t4, 1120(s2)
                  lb           s0, 1646(s2)
                  lb           s9, -343(s2)
                  lb           sp, 64(t4)
                  sb           s1, -30(t4)
                  lbu          s5, -26(t4)
                  lb           s5, 174(s2)
                  sb           t4, 17(t4)
                  lbu          zero, 26(t4)
                  sb           a0, 1874(s2)
                  sh           s2, -47(t4) #end load_store_instr_stream_1
                  lw           s9, 1529(s2) #end load_store_instr_stream_0
                  la           s0, region_0+3047 #start load_store_instr_stream_2
                  la           t5, region_0+103 #start load_store_instr_stream_1
                  sb           a1, -6(s0)
                  la           s9, region_0+3285 #start load_store_instr_stream_0
                  la           t0, region_0+758 #start load_store_instr_stream_3
                  lb           a5, 120(t5)
                  sh           s7, -1517(s9)
                  lb           sp, 2(s0)
                  lb           a7, 96(t5)
                  lbu          sp, 45(t0)
                  lb           s1, -1844(s9)
                  lh           s7, 32(t0)
                  sb           t2, 192(t5)
                  sb           ra, -9(t0)
                  lh           a4, 9(s0)
                  lb           s3, 7(t0)
                  lh           a1, 53(t5)
                  sb           a2, 63(t0)
                  lbu          a7, -16(s0)
                  lhu          s8, -55(s9)
                  sb           zero, 49(t0)
                  lbu          t4, 238(t5)
                  sh           s1, -1655(s9)
                  sb           a1, 4(s0)
                  lhu          t1, 16(t0)
                  sb           t3, -21(t0)
                  lbu          t6, 10(t5)
                  lbu          s1, 40(t0) #end load_store_instr_stream_3
                  lw           s4, 85(t5)
                  lbu          t3, 62(s9)
                  lb           s1, -4(s0) #end load_store_instr_stream_2
                  lb           s4, -1664(s9)
                  lb           t6, 61(t5) #end load_store_instr_stream_1
                  sb           s10, 584(s9) #end load_store_instr_stream_0
                  addi         t4, zero, 10 #init loop 0 counter
                  srai         s0, s3, 26
                  sll          a1, a4, zero
                  srli         zero, sp, 3
                  auipc        t0, 1032709
                  slt          t3, sp, a0
                  andi         zero, gp, 1370
                  slli         t0, tp, 19
                  auipc        a6, 685527
                  srli         t0, a6, 31
                  or           tp, t5, t2
                  srl          a5, sp, t2
                  addi         t1, zero, -10 #init loop 0 limit
sub_3_12_0_t:     sltu         s1, sp, s1
                  or           a7, s0, s0
                  or           tp, s3, a7
                  lui          t5, 524571
                  srai         t6, a6, 10
                  sll          a7, s9, s5
                  srli         s10, a7, 9
                  addi         t4, t4, -4 #update loop 0 counter
                  addi         s1, gp, -522
                  or           a3, a6, a4
                  sra          t0, s0, t4
                  addi         a5, a0, 1030
                  beq          t4, t1, sub_3_12_0_t #branch for loop 0
                  andi         s7, s6, -572
sub_3_5:          jal          t1, 4f
0:                jal          s0, 3f
1:                jal          ra, 6f
2:                jal          ra, 0b
3:                jal          ra, 5f
4:                jal          ra, 17f
5:                jal          s4, 15f
6:                jal          sp, 11f
7:                jal          ra, 30f
8:                jal          s10, 29f
9:                jal          t1, 27f
10:               jal          t5, 12f
11:               jal          ra, 22f
12:               jal          t1, 19f
13:               jal          t1, 18f
14:               jal          ra, 28f
15:               jal          tp, 9b
16:               jal          ra, 20f
17:               jal          tp, 8b
18:               jal          ra, 16b
19:               jal          ra, 1b
20:               jal          ra, 7b
21:               jal          ra, 24f
22:               jal          ra, 23f
23:               jal          a7, 14b
24:               jal          ra, 25f
25:               jal          ra, 26f
26:               jal          ra, 13b
27:               jal          t1, 10b
28:               jal          ra, 21b
29:               jal          tp, 2b
30:               sra          t4, t3, t6
                  la           s10, region_0+2591 #start riscv_hazard_instr_stream_4
                  slt          s4, a1, s3
                  and          a1, a6, t5
                  srai         s3, s0, 27
                  slli         t5, s0, 8
                  srli         s0, s4, 27
                  lbu          a1, -222(s10)
                  lb           s3, 157(s10)
                  auipc        t5, 313545
                  sra          a6, a6, s3
                  andi         t5, s4, -571
                  sub          s0, a6, s4
                  slli         a1, s3, 27
                  lw           t5, -255(s10)
                  auipc        s4, 680716
                  lbu          a6, 230(s10)
                  ori          s3, a1, 1782
                  lbu          t5, -190(s10)
                  lbu          t5, 222(s10)
                  sb           s4, 63(s10)
                  sb           s4, -30(s10)
                  sb           s4, -144(s10)
                  sltiu        s0, s3, 1819
                  slt          t5, s4, s4
                  andi         s0, a6, 700
                  lhu          t5, -57(s10)
                  lb           s3, 0(s10)
                  sltu         a6, t5, s0
                  nop
                  lbu          a6, 83(s10)
                  lbu          s4, 86(s10)
                  srli         s3, a1, 23
                  lb           a6, 43(s10)
                  sll          s3, s0, s3
                  xor          s4, s0, s4
                  srl          s4, s0, s0
                  andi         a6, s3, -1837
                  lw           t5, -55(s10)
                  sb           t5, 123(s10)
                  xor          t5, s3, a6
                  lbu          s0, -99(s10)
                  xor          a1, t5, a1
                  lb           s0, 136(s10)
                  lb           t5, 154(s10)
                  sub          a1, a1, a1
                  lbu          s0, 149(s10)
                  slli         a1, s3, 29
                  sltiu        t5, a6, 289
                  lb           s0, -100(s10) #end riscv_hazard_instr_stream_4
                  la           t5, region_0+2040 #start load_store_instr_stream_1
                  lbu          t3, -25(t5)
                  la           s9, region_1+3819 #start load_store_instr_stream_0
                  lb           tp, -27(t5)
                  lbu          t4, 0(s9)
                  lb           s2, -39(t5)
                  lb           zero, -7(s9)
                  lbu          a7, 12(s9)
                  sb           s9, -14(t5)
                  lbu          zero, -9(s9)
                  sh           t0, -52(t5)
                  lbu          a4, 3(s9)
                  lbu          a2, 10(s9)
                  lbu          s5, -15(s9)
                  lbu          sp, -23(t5)
                  lhu          a4, -9(s9)
                  sb           sp, -13(s9)
                  sw           s3, -28(t5) #end load_store_instr_stream_1
                  lbu          t0, -10(s9) #end load_store_instr_stream_0
                  la           tp, region_1+858 #start load_store_instr_stream_0
                  la           a1, region_0+1838 #start load_store_instr_stream_1
                  sh           t5, 72(tp)
                  lb           a2, -651(a1)
                  lb           zero, -146(tp)
                  sb           a6, 125(a1)
                  lhu          t5, 1984(a1)
                  lbu          s0, -107(tp)
                  sb           t1, -66(tp)
                  sb           a1, -1639(a1)
                  sh           s7, -430(a1)
                  lb           ra, -207(tp)
                  sw           a4, 950(a1)
                  sb           s7, 1(tp)
                  lbu          sp, -1495(a1)
                  lbu          a6, -1371(a1) #end load_store_instr_stream_1
                  lb           s0, -75(tp) #end load_store_instr_stream_0
                  addi         s0, zero, -4 #init loop 1 counter
                  srai         s10, s11, 9
                  srl          t5, a7, a1
                  addi         s2, zero, -11 #init loop 1 limit
                  or           a7, t5, t5
                  sub          a4, sp, t2
sub_3_13_1_t:     andi         s7, s1, -154
                  sll          a7, s2, s2
                  srli         gp, a6, 10
                  xori         t3, s1, 1339
                  nop
                  addi         s0, s0, -8 #update loop 1 counter
                  srli         s5, s3, 12
                  addi         t4, zero, -10 #init loop 0 counter
                  sll          a1, s3, s11
                  sub          s11, t3, s6
                  addi         s4, zero, 4 #init loop 0 limit
                  and          s7, s5, s4
sub_3_13_0_t:     sltu         t6, a0, s7
                  lui          gp, 487658
                  addi         t4, t4, 9 #update loop 0 counter
                  bltu         t4, s4, sub_3_13_0_t #branch for loop 0
                  xori         s9, s8, 169
                  slti         sp, s9, -2025
                  nop
                  slt          s8, a7, s9
                  bge          s0, s2, sub_3_13_1_t #branch for loop 1
                  nop
                  la           ra, region_1+933 #start riscv_load_store_hazard_instr_stream_1
                  lbu          s7, -155(ra)
                  sb           s11, -175(ra)
                  nop
                  sb           s2, -175(ra)
                  sb           t5, 151(ra)
                  sb           s10, -38(ra)
                  sb           s6, -38(ra)
                  lbu          s11, -38(ra)
                  sb           tp, -38(ra)
                  sb           s10, -38(ra)
                  xor          s8, a6, tp
                  sb           a4, 164(ra)
                  sb           t6, 40(ra)
                  lbu          t0, -199(ra)
                  slt          t1, t4, s7
                  sh           t4, -199(ra)
                  sh           s2, -199(ra)
                  lh           a7, -199(ra) #end riscv_load_store_hazard_instr_stream_1
                  la           a4, region_0+2219 #start load_store_instr_stream_1
                  la           a3, region_1+3563 #start load_store_instr_stream_0
                  lb           s7, -1872(a4)
                  sh           s2, -191(a3)
                  sh           a1, 187(a4)
                  lbu          a5, -256(a3)
                  lb           s5, -1034(a4)
                  sb           s7, 547(a4)
                  lbu          s8, 216(a3)
                  lb           ra, -1028(a4)
                  sh           s7, 1869(a4)
                  lbu          gp, 89(a3)
                  sb           s6, -134(a3)
                  lhu          s3, 1519(a4)
                  sh           t5, 185(a3)
                  sb           t1, 1750(a4)
                  sb           t1, 712(a4) #end load_store_instr_stream_1
                  sb           t5, 145(a3) #end load_store_instr_stream_0
                  la           a6, region_1+1076 #start riscv_load_store_hazard_instr_stream_3
                  sub          s7, a1, t5
                  ori          ra, t5, 1067
                  lb           s9, -15(a6)
                  lbu          t1, -15(a6)
                  lbu          ra, -15(a6)
                  sll          t3, t3, s6
                  lbu          s5, -15(a6)
                  sb           s5, -15(a6)
                  lbu          s5, -15(a6)
                  lbu          a4, -15(a6)
                  lhu          a4, -6(a6)
                  lbu          gp, -6(a6)
                  srai         s0, s8, 29
                  sb           a6, -6(a6) #end riscv_load_store_hazard_instr_stream_3
                  la           a4, region_0+2494 #start load_store_instr_stream_2
                  la           t3, region_0+3370 #start load_store_instr_stream_0
                  lhu          s8, 276(a4)
                  la           a5, region_0+2480 #start load_store_instr_stream_1
                  sb           a1, -611(a4)
                  lb           gp, -37(a5)
                  lbu          a1, 21(a5)
                  lb           t6, -263(t3)
                  sb           a1, -1459(t3)
                  lbu          a6, 47(a5)
                  lb           t6, 811(a4)
                  lbu          s2, -1619(a4)
                  lh           s3, -658(t3)
                  lb           s5, -610(t3)
                  lb           s1, 21(a5)
                  lb           s11, -49(a5)
                  sh           t0, -64(a5)
                  lb           a2, 986(a4) #end load_store_instr_stream_2
                  lhu          t6, -1834(t3)
                  lbu          s0, -23(a5) #end load_store_instr_stream_1
                  sb           a4, 187(t3) #end load_store_instr_stream_0
                  la           s10, region_0+3125 #start riscv_hazard_instr_stream_3
                  andi         t5, t5, -1057
                  sub          s9, tp, s9
                  lbu          a2, -1437(s10)
                  slti         s1, s9, -1187
                  addi         a2, s1, 1173
                  lb           s1, -1808(s10)
                  nop
                  lb           s1, -327(s10)
                  sltu         tp, s1, s1
                  slli         tp, tp, 2
                  slt          s9, s1, t5
                  lb           s1, 868(s10)
                  lbu          s9, -273(s10)
                  slli         a2, s8, 12
                  lb           s1, -303(s10)
                  andi         s9, s9, 169
                  lb           t5, -1551(s10)
                  lbu          tp, 288(s10)
                  lh           s1, 123(s10)
                  andi         s9, s8, 704
                  lbu          s8, 91(s10)
                  andi         s9, s8, 1099
                  lhu          s9, -203(s10)
                  sltiu        s1, t5, -274
                  or           a2, a2, a2
                  lh           s9, -1543(s10)
                  sb           s8, 648(s10)
                  xori         tp, s8, 889
                  lbu          a2, -54(s10)
                  auipc        s9, 649811
                  sb           a2, -484(s10)
                  slti         tp, s9, -1808
                  ori          s8, t5, 1556
                  nop
                  sb           s1, -304(s10)
                  add          s8, t5, a2
                  lb           t5, -1168(s10) #end riscv_hazard_instr_stream_3
                  la           s9, region_1+972 #start load_store_instr_stream_0
                  la           s2, region_1+1561 #start load_store_instr_stream_2
                  la           a2, region_1+702 #start load_store_instr_stream_4
                  la           tp, region_1+172 #start load_store_instr_stream_3
                  sb           t6, 10(s2)
                  lbu          gp, 1(s2)
                  sb           a1, 3(s9)
                  lb           t4, 221(tp)
                  lh           s5, 13(s2)
                  lb           gp, -9(s9)
                  sb           tp, 119(tp)
                  la           t3, region_1+2416 #start load_store_instr_stream_1
                  sb           t5, 13(a2)
                  sh           t3, 4(s9)
                  lb           ra, 203(tp)
                  lb           s11, -7(s2)
                  sb           s8, -42(t3)
                  lh           a1, -2(s9)
                  lbu          s7, 2(s2)
                  sb           t3, -20(a2)
                  lb           a6, 101(tp)
                  lbu          a5, -57(t3)
                  sb           s1, -28(a2)
                  lbu          s11, -8(s2)
                  lhu          s11, 10(s9)
                  lb           a5, -29(a2)
                  lbu          s8, -46(a2)
                  lbu          s1, 53(t3)
                  lb           s11, 14(s2)
                  sb           a1, 184(tp)
                  lb           t1, -11(s9)
                  sh           s8, -11(s2)
                  lhu          s0, 128(tp)
                  sb           tp, -19(t3)
                  lbu          ra, 4(s9)
                  lhu          zero, -50(t3)
                  sb           a3, -29(tp) #end load_store_instr_stream_3
                  sb           a7, -59(a2)
                  lbu          s8, -33(t3) #end load_store_instr_stream_1
                  lb           a4, -20(a2)
                  sh           sp, 9(s2) #end load_store_instr_stream_2
                  lb           s4, 23(a2) #end load_store_instr_stream_4
                  lb           t4, 14(s9) #end load_store_instr_stream_0
                  la           t5, region_1+2978 #start riscv_hazard_instr_stream_1
                  sltu         s3, s5, s1
                  srai         s5, a7, 6
                  sh           s5, -46(t5)
                  xor          s1, s1, a7
                  lbu          a3, -17(t5)
                  lb           a7, 52(t5)
                  slli         s3, a7, 10
                  lb           a7, 53(t5)
                  sra          s1, s3, s1
                  lh           s5, 2(t5)
                  slli         a3, s5, 17
                  sb           s3, 11(t5)
                  sw           a7, -14(t5)
                  sll          a5, a3, s5
                  slti         s5, s3, -497
                  auipc        s3, 913950
                  andi         a5, s3, -1274
                  slli         a7, s3, 15
                  srli         s1, a5, 3
                  sra          s1, a7, a3
                  lh           a7, -2(t5)
                  lb           a5, -31(t5)
                  sra          s5, s5, s3
                  lbu          a7, 36(t5)
                  sra          s5, a3, s5
                  sltu         s3, a3, s5
                  ori          a3, s1, 361
                  add          s5, a3, a5
                  or           a3, s1, s5
                  srli         s1, s1, 3
                  sll          s5, a3, a5
                  srai         a3, a7, 15
                  nop
                  slli         a7, a5, 13
                  lhu          a3, -54(t5)
                  lb           a3, -32(t5)
                  xor          a7, a7, a5
                  xor          a3, a7, a5
                  lbu          a7, -9(t5)
                  addi         a3, a7, -1413
                  lb           s5, -45(t5)
                  nop
                  sb           s3, -7(t5) #end riscv_hazard_instr_stream_1
                  sra          a6, t5, zero
                  srai         s7, s3, 0
                  bltu         s2, t6, 11f
                  add          s0, s7, s4
                  auipc        gp, 705373
                  slli         s5, s8, 28
                  bltu         a1, t3, 20f
                  slli         t1, s8, 16
                  sltiu        zero, t0, 847
                  slt          s9, a4, s1
                  blt          t2, s6, 24f
11:               sub          sp, s1, t1
                  add          a7, s3, t2
                  and          s4, s4, a4
                  slli         t1, a1, 15
                  srli         t6, a1, 8
                  srl          a2, s10, s5
                  bgeu         s1, a0, 18f
18:               sltiu        s10, a7, 1545
                  srai         a6, tp, 20
20:               addi         t4, gp, 1427
                  auipc        t1, 196455
                  slli         ra, s11, 23
                  slt          a2, zero, gp
24:               sltu         s4, a4, a0
                  bgeu         s4, ra, 41f
                  nop
                  bge          a3, sp, 40f
                  slt          gp, a4, a7
                  xori         s4, gp, 1850
                  bne          a7, s5, 49f
                  add          s7, s5, tp
                  slli         tp, t3, 4
                  and          s3, s1, ra
                  xori         a5, a7, 462
                  and          s7, s4, t4
                  lui          a7, 12620
                  slti         a3, s1, 2014
                  nop
sub_3_j5:         jal          t1, sub_4 #jump sub_3 -> sub_4
                  blt          a2, s10, 49f
                  lui          a2, 308253
                  srai         s8, a2, 20
                  sltiu        s3, a7, 1447
                  bne          a5, s1, 41f
                  slli         t6, t2, 21
                  bge          a0, t2, 46f
                  blt          a6, s5, 46f
                  sltiu        s5, t4, 1120
40:               slti         a2, sp, 750
41:               sltu         t0, a5, a5
                  bge          s8, t3, 44f
                  sub          ra, s5, a3
44:               srl          ra, a4, t3
                  sra          t4, s9, s4
46:               andi         zero, s4, 1702
                  addi         s1, t6, -1618
                  lui          t1, 744170
49:               nop
                  bltu         s4, s7, 61f
                  beq          t0, a3, 58f
                  add          tp, zero, tp
                  or           sp, t0, s7
                  beq          s9, zero, 63f
                  bge          tp, a1, 74f
                  xor          a5, t3, a7
                  sltu         s3, sp, tp
58:               sra          s5, s9, s5
                  auipc        s11, 876025
                  blt          sp, zero, 75f
61:               lui          zero, 632433
                  bne          s10, t4, 65f
63:               srai         s5, a3, 12
                  blt          s0, t3, 83f
65:               bltu         s8, s0, 73f
                  sub          ra, s2, t2
                  addi         ra, zero, 293
                  lui          a4, 15703
                  sub          ra, sp, s2
                  lui          a3, 646616
                  auipc        s9, 947410
                  auipc        s1, 553744
73:               bne          a0, t0, 81f
74:               beq          a4, a1, 82f
75:               sltiu        t5, t3, 1206
                  sll          a2, t0, t5
                  bgeu         a3, a3, 80f
                  slli         t1, s2, 19
                  sltu         s10, a5, s1
80:               addi         t1, s11, 1071
81:               auipc        a6, 1032256
82:               or           s2, a0, a2
83:               srai         zero, a5, 21
                  xori         a7, s7, 1174
                  beq          a6, t3, 90f
                  add          s8, s5, t1
                  beq          t2, s2, 90f
                  beq          s10, s8, 104f
                  sra          s5, a3, t5
90:               slti         s5, t3, -1305
                  auipc        a1, 152165
                  add          s11, a3, s9
                  bge          a5, t6, 105f
                  and          ra, s6, s3
                  srai         a3, s11, 15
                  andi         zero, a4, 48
                  lui          gp, 931710
                  auipc        s2, 200643
                  slti         t4, s7, 1649
                  lui          s9, 165153
                  addi         tp, t5, 766
                  sltu         sp, a3, s6
                  xori         s9, a0, -751
104:              bgeu         a4, s0, 110f
105:              xori         s0, gp, 135
                  slt          a2, s0, t4
                  andi         a5, t4, -1001
                  srli         t3, tp, 20
                  blt          s2, s4, 122f
110:              ori          a4, tp, -501
                  sra          t6, t3, a4
                  add          s2, a4, a7
                  or           s3, a3, zero
                  xor          a3, t2, s7
                  andi         a5, s0, -309
                  slli         s2, s2, 27
                  sltu         a3, s5, zero
                  bge          a6, gp, 128f
                  nop
                  bne          tp, a4, 126f
                  bne          s5, s2, 134f
122:              ori          a4, a1, -696
                  sra          s3, a1, sp
                  addi         s0, s0, -1939
                  lui          t0, 504133
126:              xor          a2, t3, s10
                  beq          a6, a4, 136f
128:              addi         s11, a2, -500
                  xor          t1, t2, ra
                  bgeu         s3, a4, 138f
                  auipc        a1, 801808
                  bltu         t3, tp, 135f
                  bge          a6, s11, 146f
134:              srl          a2, s9, gp
135:              ori          t4, a2, 616
136:              srli         t1, s11, 29
                  sra          a3, sp, a5
138:              xori         t4, gp, -1967
                  sltiu        a6, s7, 420
                  sub          s3, a3, t1
                  bge          t5, a5, 152f
                  lui          a3, 208888
                  bgeu         a5, s11, 151f
                  srli         ra, t1, 29
                  nop
146:              bne          a3, s5, 151f
                  or           s10, a4, t1
                  or           s0, s0, s2
                  add          a5, gp, s7
                  slli         a1, s11, 7
151:              sra          gp, gp, s5
152:              sra          s2, t3, t1
                  ori          s9, a5, -636
                  srai         t5, t4, 17
                  or           gp, ra, s2
                  add          tp, s9, t1
                  and          gp, t5, s4
                  add          a1, s2, s2
                  slti         s0, s11, -80
                  addi         t0, a2, 1367
                  slt          s10, s4, zero
                  sra          s11, s1, a2
                  srai         s5, tp, 0
                  sltu         t0, ra, s11
                  andi         s7, a7, -176
                  sltiu        t1, s9, -1820
                  ori          a7, zero, 1188
                  srli         t1, a5, 30
                  blt          s1, a6, 188f
                  sltu         t5, a2, gp
                  auipc        t5, 264713
                  sub          t4, a4, s2
                  beq          t5, a6, 188f
                  andi         a4, t0, -1260
                  or           s11, t2, t4
                  blt          t0, t1, 179f
                  xori         t4, ra, -619
                  beq          t4, t2, 186f
179:              sltiu        s2, a2, -405
                  lui          t0, 258215
                  sltiu        s5, gp, -216
                  sra          s11, a3, ra
                  sll          t0, s3, s0
                  srai         a7, gp, 14
                  sra          a3, s10, s6
186:              slt          t1, a7, s7
                  sra          ra, s3, s11
188:              beq          t5, s3, 190f
                  add          t3, sp, s9
190:              srl          t0, t3, a6
                  sra          a4, s0, s9
                  ori          s8, a0, -132
                  and          a6, zero, s3
                  slli         tp, t5, 14
                  nop
                  ori          sp, tp, 1268
                  add          t1, s5, t6
                  andi         a3, zero, 945
                  slti         t4, a7, -1792
                  sltu         a2, s10, zero
                  nop
                  xor          t0, s5, a5
                  and          s8, s6, a4
                  sll          s5, t1, t2
                  sltu         a1, s10, a5
                  sra          s4, t5, s4
                  sra          s1, t0, a2
                  beq          a5, s3, 218f
                  auipc        s5, 319843
                  add          zero, tp, s8
                  andi         t6, ra, 702
                  sltiu        s0, a7, 1544
                  sll          t1, t6, s0
                  xori         s3, t1, -575
                  sub          s1, s6, t1
                  ori          t5, gp, 177
                  bltu         t3, t3, 223f
218:              sll          s7, s2, s9
                  sub          a4, t5, s11
                  bltu         zero, s7, 239f
                  sra          t0, t3, a5
                  sltu         s11, s1, s9
223:              srl          a3, a4, s3
                  srli         t4, s10, 31
                  sra          a6, gp, a0
                  blt          gp, tp, 233f
                  beq          t4, tp, 228f
228:              sll          s9, s9, a4
                  slt          tp, s7, a3
                  andi         t1, s9, 358
                  and          s10, s11, a1
                  bltu         s2, a3, 251f
233:              andi         t5, a2, 1732
                  sltiu        s11, t5, -1064
                  bge          t1, a2, 251f
                  blt          s11, t0, 245f
                  sltu         a7, s11, tp
                  auipc        t6, 472636
239:              add          s1, s5, a2
                  xor          s0, s1, s7
                  and          t4, s10, s10
                  sub          a4, s9, tp
                  sll          t3, s7, tp
                  sltu         t0, a2, s9
245:              bgeu         a1, t6, 259f
                  sra          a2, s4, tp
                  beq          t2, ra, 265f
                  srl          t6, t4, ra
                  bne          s1, s7, 257f
                  andi         a6, t2, 786
251:              lui          t1, 751363
                  sub          a5, a2, ra
                  ori          s2, t2, -16
                  xor          a2, a0, gp
                  addi         s8, s1, 162
                  blt          a3, t1, 265f
257:              srli         s11, s8, 1
                  addi         a2, s9, -931
259:              bge          a0, s10, 275f
                  addi         s0, sp, 1634
                  and          t6, s3, s11
                  srl          t5, s0, ra
                  slt          s11, s6, s11
                  bge          s11, t3, 278f
265:              xori         t1, s6, 1102
                  slti         a2, t1, -1296
                  bltu         s0, t2, 270f
                  xor          s8, a4, a7
                  sub          s10, s8, a0
270:              blt          s5, a1, 282f
                  sltu         t0, s6, a4
                  add          s9, a5, a1
                  or           zero, t6, s0
                  add          ra, a2, tp
275:              or           a3, t5, a3
                  bgeu         t4, s5, 277f
277:              sll          t4, t6, s8
278:              xori         t1, a5, -6
                  bne          a0, a2, 285f
                  addi         s3, s1, -1501
                  blt          s4, t6, 292f
282:              add          gp, a0, t2
                  or           s7, a0, t4
                  bne          s4, s6, 286f
285:              sltiu        s7, t4, 1382
286:              slli         s10, t2, 29
                  bge          t2, s11, 299f
                  add          t4, a4, t4
                  bge          ra, zero, 296f
                  addi         s7, s4, 253
                  bltu         s8, s5, 307f
292:              sltu         s9, s9, s4
                  sra          zero, s10, s0
                  nop
                  blt          s8, s4, 314f
296:              sub          t0, t0, a4
                  bltu         a7, s9, 310f
                  srli         s4, t6, 18
299:              sll          s8, t5, s3
                  sra          t6, s8, t4
                  sra          a5, a5, s2
                  sltu         a4, a5, ra
                  srl          s8, s6, t4
                  beq          a5, gp, 320f
                  sll          a6, s7, a7
                  srli         sp, s3, 16
307:              sll          s4, a5, a6
                  and          t6, t2, t1
                  srli         zero, s5, 19
310:              xori         s9, t4, -1418
                  sltiu        tp, a4, -732
                  auipc        s4, 942578
                  xor          t6, t2, s8
314:              or           s9, t2, zero
                  lui          a1, 751282
                  nop
                  nop
                  nop
                  bne          a3, s9, 333f
320:              blt          zero, s7, 330f
                  lui          a2, 46433
                  bne          s11, zero, 330f
                  sltiu        t4, s3, 952
                  sub          a6, s10, t3
                  sltiu        a7, a2, -412
                  sltu         gp, t5, a3
                  bne          tp, tp, 336f
                  andi         s0, a3, 186
                  ori          a7, s5, -948
330:              slti         sp, s2, 713
                  slli         s4, a5, 20
                  sltu         s5, a0, a1
333:              srli         s5, s10, 31
                  bge          sp, a5, 353f
                  blt          zero, a6, 343f
336:              and          a7, t1, t6
                  ori          s2, s11, 772
                  sltiu        s4, t2, -1676
                  sltiu        s5, s8, 454
                  bltu         zero, a0, 358f
                  slt          t0, s10, s11
                  sub          t5, a5, s5
343:              lui          t1, 669433
                  xor          a3, zero, s9
                  srai         a1, a3, 21
                  auipc        a6, 67616
                  nop
                  slt          t5, sp, a1
                  xor          a5, s0, a5
                  nop
                  add          t6, t6, a6
                  sra          gp, a6, s3
353:              nop
                  sub          s7, t3, s4
                  slt          s4, s4, s7
                  blt          a2, zero, 365f
                  srai         t6, t3, 5
358:              ori          a2, sp, -1065
                  slti         s2, zero, 1506
                  add          tp, s5, s6
                  auipc        s9, 883987
                  andi         a3, a3, 983
                  srli         ra, s10, 11
                  srl          t6, s9, t4
365:              blt          tp, s2, 373f
                  sra          s1, t0, a1
                  add          gp, s1, a0
                  nop
                  slti         s11, a3, 705
                  ori          tp, a7, 220
                  auipc        s4, 67916
                  srai         sp, a2, 14
373:              srl          a1, a0, s9
                  sra          t5, t2, s11
                  slt          s2, s1, a2
                  srai         s4, gp, 12
                  sltiu        s11, a1, 1388
                  bge          t6, s10, 397f
                  sltu         s1, t0, a7
                  slti         a2, s1, 1441
                  addi         a1, a5, 1216
                  srli         t3, a2, 5
                  and          t3, s2, gp
                  blt          a5, a2, 399f
                  srli         t6, s4, 11
                  xori         tp, s5, 347
                  blt          t1, zero, 401f
                  slt          s7, s6, t4
                  sra          a4, a0, s2
                  or           a6, t2, s10
                  or           a6, a6, t1
                  and          s2, s10, gp
                  bltu         t0, s9, 401f
                  bltu         t1, t5, 407f
                  beq          tp, a0, 401f
                  xori         s5, a2, 166
397:              srli         s2, a0, 11
                  bltu         t5, a7, 403f
399:              sll          s3, tp, t6
                  bne          s0, a4, 403f
401:              addi         s4, t6, -1797
                  slt          s4, a6, s11
403:              slt          t4, s3, tp
                  srli         a5, t6, 27
                  or           sp, s3, t2
                  andi         a4, s2, 1854
407:              lui          s10, 276682
                  srli         tp, t0, 8
                  bne          a0, t1, 418f
                  xor          s3, a6, ra
                  slti         s7, t5, -1939
                  bge          ra, a5, 415f
                  bltu         a4, t3, 416f
                  add          s11, t1, t4
415:              add          s7, a0, s0
416:              sltu         a4, a4, sp
                  slt          t5, a5, t4
418:              slt          s3, s1, t3
                  bltu         t1, s3, 437f
                  andi         a7, a4, 768
                  ori          a1, a1, 727
                  and          t3, a2, s8
                  slli         s8, s9, 14
                  bne          a1, tp, 433f
                  bltu         zero, t0, 431f
                  sltiu        t0, s2, -235
                  bgeu         sp, a0, 435f
                  xori         t1, a0, 1136
                  and          t0, a3, a5
                  or           t6, t1, s1
431:              bgeu         a2, sp, 447f
                  srai         s2, s11, 9
433:              auipc        t6, 489296
                  xor          t6, tp, a4
435:              add          s11, a1, s6
                  bltu         ra, a7, 439f
437:              addi         s0, t5, 1992
                  blt          s2, s2, 457f
439:              bne          t1, zero, 458f
                  sll          s11, t0, gp
                  sltu         tp, t3, s2
                  auipc        s1, 570031
                  sltiu        a3, a1, 1440
                  slli         s3, t0, 1
                  sltiu        s10, t4, 1577
                  or           a5, ra, s6
447:              sra          a6, zero, a5
                  xori         sp, t3, 217
                  add          s0, s0, a3
                  sltiu        s11, zero, 1709
                  sll          t0, s1, a3
                  slti         t0, a5, -296
                  ori          t1, s0, 879
                  andi         s9, gp, 292
                  nop
                  lui          s11, 502217
457:              bltu         s9, a2, 465f
458:              lui          s4, 1011168
                  bne          a5, a7, 464f
                  bge          s11, s2, 470f
                  bltu         a5, s5, 464f
                  beq          s2, s10, 475f
                  slti         a6, t0, -1288
464:              auipc        a6, 4520
465:              xor          t4, a3, s4
                  and          t6, t0, t5
                  slli         s1, tp, 1
                  bltu         s2, a0, 475f
                  and          t6, s9, tp
470:              sra          a6, a1, a0
                  srli         s7, a6, 21
                  sltu         s8, t6, a7
                  slli         sp, a1, 16
                  beq          a3, t0, 476f
475:              add          s7, s1, t1
476:              srai         t6, t6, 22
                  xori         gp, s0, 1582
                  srli         t6, a0, 9
                  bne          s6, t3, 485f
                  xor          s2, a0, a6
                  sltu         s9, t4, s4
                  bge          t4, s5, 493f
                  sll          s10, a4, s5
                  addi         a7, s10, -452
485:              bltu         a0, s5, 498f
                  ori          s7, a7, -536
                  bgeu         s9, a1, 495f
                  addi         s2, t1, -1540
                  sub          zero, s2, t3
                  sub          s9, s6, s5
                  sub          a4, s3, s3
                  andi         a2, s6, 1050
493:              slti         a2, t6, -213
                  auipc        s7, 28534
495:              andi         s9, sp, -1454
                  bgeu         s4, s9, 497f
497:              sltiu        a4, t5, -635
498:              srli         t0, a2, 5
                  sra          gp, t4, a7
                  lui          s2, 400882
                  blt          t3, t4, 510f
                  add          tp, s4, a6
                  sltiu        t1, s9, -672
                  bge          a5, a5, 513f
                  slli         s0, gp, 0
                  bne          a4, s6, 513f
                  srl          ra, s1, a5
                  sub          t4, a7, ra
                  lui          t3, 560807
510:              and          s1, s5, s9
                  slli         ra, s4, 22
                  xori         t5, s9, 1235
513:              xor          s11, t3, a7
                  srai         t3, a3, 27
                  auipc        s4, 703822
                  slli         tp, s4, 18
                  lw           t1, 4(a0)
                  nop
                  srli         t6, a7, 3
                  addi         a0, a0, 20
                  sltiu        s9, gp, 519
                  xor          s0, sp, s7
                  xor          a5, s7, t4
1162:             addi x28, x6, 0
1162:             jalr x28, x28, 0
sub_2:            bne          ra, s6, sub_2_stack_p
                  slt          s8, t2, s11
                  sub          s8, s3, sp
                  nop
sub_2_stack_p:    addi         a0, a0, -44
                  sra          a3, sp, sp
                  sw           t1, 4(a0)
                  sltiu        a6, a7, 657
                  la           t1, region_1+970 #start load_store_instr_stream_1
                  lbu          t4, -228(t1)
                  la           a6, region_1+613 #start load_store_instr_stream_0
                  lb           a5, -234(t1)
                  lh           t4, 144(t1)
                  lb           s4, 204(a6)
                  sh           t3, -116(t1)
                  sb           s5, 180(a6)
                  lb           tp, 138(a6)
                  lb           a7, 150(t1)
                  lh           s0, 91(a6)
                  lbu          s11, 220(t1)
                  sh           s0, 164(t1)
                  lbu          a1, 155(t1) #end load_store_instr_stream_1
                  sh           gp, -89(a6) #end load_store_instr_stream_0
                  la           sp, region_0+3054 #start riscv_load_store_hazard_instr_stream_2
                  lhu          t5, -92(sp)
                  sb           t2, -92(sp)
                  lb           zero, -49(sp)
                  sb           a3, 209(sp)
                  lb           ra, 145(sp)
                  lbu          t4, -10(sp)
                  srli         s5, a0, 1
                  sb           t6, -10(sp)
                  lhu          t0, 132(sp)
                  lhu          zero, 132(sp)
                  sb           s8, 132(sp)
                  slti         t4, a0, -1782
                  lb           s1, -63(sp)
                  sw           tp, 66(sp)
                  sb           tp, 87(sp)
                  sll          tp, t0, t4
                  srl          a3, a1, s5
                  sb           s5, 236(sp)
                  lui          s7, 493377
                  lbu          s9, 201(sp)
                  sb           s3, -227(sp)
                  sb           s6, -227(sp)
                  sb           a7, 23(sp) #end riscv_load_store_hazard_instr_stream_2
                  addi         gp, zero, -8 #init loop 1 counter
                  andi         a7, a3, -1610
                  addi         a3, zero, -14 #init loop 1 limit
                  sll          ra, sp, zero
sub_2_10_1_t:     add          a6, s1, a0
                  slti         sp, tp, -24
                  addi         gp, gp, -1 #update loop 1 counter
                  addi         t6, zero, -5 #init loop 0 counter
                  addi         s3, zero, 1 #init loop 0 limit
                  srl          s10, s4, sp
sub_2_10_0_t:     slt          a4, s4, t3
                  addi         t6, t6, 9 #update loop 0 counter
                  srl          s5, s6, t2
                  bltu         t6, s3, sub_2_10_0_t #branch for loop 0
                  bge          gp, a3, sub_2_10_1_t #branch for loop 1
                  slli         s1, s4, 22
                  la           s7, region_1+2776 #start load_store_instr_stream_0
                  la           t3, region_0+3940 #start load_store_instr_stream_1
                  lbu          ra, -26(s7)
                  lh           s8, -192(t3)
                  sb           zero, 44(t3)
                  lb           s4, -9(s7)
                  lb           s9, 87(t3)
                  lbu          a7, -17(s7)
                  lb           ra, -209(t3)
                  lb           ra, -94(t3)
                  lb           a6, -27(s7)
                  lbu          t1, -60(t3)
                  lb           s1, 16(s7)
                  lbu          sp, -1(s7)
                  sb           s10, 151(t3)
                  sh           a6, 32(t3) #end load_store_instr_stream_1
                  sh           t6, -8(s7) #end load_store_instr_stream_0
                  la           t3, region_1+2800 #start load_store_instr_stream_0
                  la           t4, region_0+2062 #start load_store_instr_stream_1
                  sb           s9, -1377(t3)
                  lb           s7, 1202(t4)
                  lbu          s5, 313(t4)
                  lb           zero, -1430(t3)
                  sb           a6, -573(t4)
                  lb           a2, -1897(t3)
                  lbu          a7, 1319(t4)
                  lbu          t6, 1272(t4)
                  sb           s9, -1502(t4)
                  sb           ra, -309(t4)
                  lb           s8, 965(t4)
                  sw           a4, -924(t3)
                  lb           a2, 142(t4)
                  lbu          a1, 2009(t4) #end load_store_instr_stream_1
                  lhu          a3, -1654(t3) #end load_store_instr_stream_0
                  la           ra, region_1+2794 #start riscv_hazard_instr_stream_0
                  srli         a4, s3, 7
                  slti         t5, gp, -250
                  lb           gp, -15(ra)
                  slt          t5, t4, a4
                  srl          zero, a4, gp
                  sltiu        t5, t4, 344
                  ori          a4, gp, 1175
                  or           t5, gp, t4
                  auipc        a4, 717715
                  sb           gp, 23(ra)
                  xori         a4, zero, 408
                  lb           t5, -7(ra)
                  nop
                  lb           s3, -10(ra)
                  add          t4, gp, zero
                  and          s3, zero, t4
                  sb           t4, 47(ra)
                  lhu          zero, -54(ra)
                  sltiu        s3, zero, -828
                  nop
                  or           t4, s3, s3
                  nop
                  lb           a4, 20(ra)
                  srli         gp, t4, 26
                  ori          t5, t4, 195
                  lhu          t5, -46(ra)
                  andi         zero, t5, -1173
                  slli         zero, gp, 31
                  xori         zero, t5, -616
                  auipc        t5, 89832
                  lb           a4, -3(ra)
                  sb           gp, 1(ra)
                  sb           t4, 62(ra)
                  nop
                  lb           gp, 27(ra)
                  sb           t5, -27(ra)
                  sb           s3, 2(ra)
                  lhu          gp, -32(ra)
                  sltiu        a4, t5, 341
                  sub          gp, a4, t4
                  addi         a4, gp, 632
                  sb           zero, 55(ra)
                  andi         zero, s3, -780
                  slli         t4, s3, 7
                  lhu          gp, 4(ra) #end riscv_hazard_instr_stream_0
                  la           t3, region_1+3470 #start load_store_instr_stream_0
                  sb           s6, -45(t3)
                  la           s4, region_0+1235 #start load_store_instr_stream_1
                  sb           s1, 19(t3)
                  lb           s11, 265(s4)
                  lbu          gp, 9(t3)
                  lbu          s3, -803(s4)
                  lbu          a6, -761(s4)
                  lb           s8, -31(t3)
                  lbu          zero, -53(t3)
                  lb           ra, -241(s4)
                  sb           s8, -20(s4) #end load_store_instr_stream_1
                  sh           s5, -8(t3)
                  lbu          a5, -37(t3) #end load_store_instr_stream_0
                  la           s0, region_0+2720 #start riscv_load_store_hazard_instr_stream_1
                  lbu          a3, 60(s0)
                  sw           a0, 60(s0)
                  or           s3, a2, gp
                  lw           s5, 60(s0)
                  lb           a6, -157(s0)
                  andi         zero, a4, -648
                  sb           s3, -157(s0)
                  srai         ra, a0, 7
                  sb           t6, -157(s0)
                  sb           a7, -157(s0)
                  sw           s6, -184(s0)
                  lw           s3, -184(s0)
                  sw           a6, -184(s0)
                  ori          a1, sp, -1029
                  lw           s4, 84(s0)
                  lh           a4, 84(s0)
                  sw           s1, 84(s0)
                  lbu          gp, 84(s0)
                  lb           a1, 84(s0)
                  sh           tp, 84(s0)
                  and          s9, s10, t1
                  sw           t2, 84(s0)
                  sltu         s10, gp, tp
                  srli         ra, s5, 10
                  lh           a7, 84(s0)
                  lh           s2, 84(s0)
                  lbu          t3, -243(s0) #end riscv_load_store_hazard_instr_stream_1
                  la           sp, region_1+1234 #start riscv_hazard_instr_stream_3
                  sltu         s9, s9, s7
                  sll          s4, s3, s9
                  lhu          s4, 16(sp)
                  xori         s4, a4, -1658
                  sb           a4, 11(sp)
                  auipc        a4, 805292
                  addi         s7, s4, -1146
                  xor          s4, a5, s7
                  xor          s9, a5, s7
                  sb           s4, -12(sp)
                  lbu          s9, 3(sp)
                  lh           s3, -12(sp)
                  slli         s4, s3, 30
                  sh           a5, -4(sp)
                  lb           a4, -7(sp)
                  lhu          a4, 0(sp)
                  lw           s7, -6(sp)
                  sltiu        s3, s9, -435
                  lhu          a5, -16(sp)
                  sub          a5, s3, s7
                  lb           s9, 7(sp)
                  srli         s9, s7, 25
                  sltiu        s9, a5, 1852
                  srai         s3, s7, 16
                  slti         s4, s7, 88
                  lh           s9, 6(sp)
                  and          s3, s3, s9
                  lhu          a4, 2(sp)
                  lbu          s3, -11(sp)
                  ori          s7, s9, 427
                  sll          a5, s7, s3
                  lbu          s4, -7(sp)
                  sb           s9, -12(sp)
                  nop
                  or           a4, s9, s4
                  lbu          s7, -9(sp)
                  sub          s7, a5, s9
                  sll          s9, a5, s9
                  slti         s3, s4, 1690
                  lui          a4, 827732
                  sltiu        s9, s3, -861
                  srai         s3, s7, 18
                  xor          s4, a4, a5
                  lbu          s9, 11(sp) #end riscv_hazard_instr_stream_3
                  la           sp, region_0+3475 #start riscv_load_store_hazard_instr_stream_0
                  lbu          s0, 221(sp)
                  lbu          t0, 221(sp)
                  lb           a5, -84(sp)
                  xor          s5, t5, s6
                  lb           s4, -141(sp)
                  sub          s5, s4, s4
                  lb           s5, -144(sp)
                  lbu          a7, -232(sp)
                  lbu          t6, -232(sp)
                  slt          s4, a6, t5
                  lbu          t1, -232(sp)
                  lbu          t4, -232(sp)
                  lbu          s4, -232(sp)
                  lbu          s2, -32(sp)
                  lb           s1, -32(sp)
                  lbu          t1, 46(sp)
                  lbu          t0, -211(sp)
                  lb           s2, 256(sp)
                  lb           a5, -42(sp)
                  sb           t4, -42(sp)
                  xor          s0, a0, gp
                  srai         a6, a5, 1
                  lb           s8, -238(sp)
                  sb           s3, -238(sp) #end riscv_load_store_hazard_instr_stream_0
sub_2_5:          jal          t1, 6f
0:                jal          gp, 10f
1:                jal          ra, 24f
2:                jal          ra, 18f
3:                jal          ra, 22f
4:                jal          ra, 30f
5:                jal          a3, 14f
6:                jal          ra, 13f
7:                jal          ra, 4b
8:                jal          t1, 9f
9:                jal          s0, 26f
10:               jal          t1, 28f
11:               jal          s7, 5b
12:               jal          t3, 29f
13:               jal          s1, 3b
14:               jal          t1, 1b
15:               jal          ra, 27f
16:               jal          t1, 8b
17:               jal          t0, 23f
18:               jal          ra, 15b
19:               jal          t1, 7b
20:               jal          gp, 12b
21:               jal          ra, 16b
22:               jal          ra, 17b
23:               jal          ra, 2b
24:               jal          t0, 20b
25:               jal          s2, 11b
26:               jal          a6, 25b
27:               jal          ra, 21b
28:               jal          ra, 19b
29:               jal          ra, 0b
30:               slti         a2, sp, 758
                  la           t6, region_1+3726 #start load_store_instr_stream_1
                  la           s10, region_0+3002 #start load_store_instr_stream_0
                  sh           s4, 50(s10)
                  lh           s4, 42(s10)
                  sb           a7, -175(t6)
                  lw           t0, -2(s10)
                  lb           a7, 9(s10)
                  sw           ra, 74(t6)
                  lbu          s8, -20(s10)
                  lbu          a6, 5(s10)
                  lhu          s0, 62(s10)
                  lbu          s11, -35(s10)
                  lb           a7, -1225(t6)
                  lbu          a4, -826(t6)
                  lbu          a2, -761(t6)
                  lbu          tp, 226(t6)
                  lb           a1, -15(s10)
                  lb           t3, 292(t6) #end load_store_instr_stream_1
                  sb           s3, 51(s10) #end load_store_instr_stream_0
                  la           a6, region_1+1895 #start riscv_hazard_instr_stream_1
                  add          a2, a2, t3
                  sra          a2, s1, ra
                  sra          s1, a7, ra
                  lb           t3, -15(a6)
                  lbu          t3, -17(a6)
                  sltu         s10, ra, ra
                  lhu          ra, -57(a6)
                  sltiu        ra, ra, 151
                  lb           ra, 11(a6)
                  slt          s1, s10, s1
                  srli         s1, s1, 2
                  slt          s1, a2, t3
                  sb           ra, -8(a6)
                  add          a2, s1, a2
                  lb           ra, 10(a6)
                  sb           ra, 5(a6)
                  sltiu        a2, s10, -1103
                  sw           ra, -27(a6)
                  lbu          a2, 42(a6)
                  srli         a7, t3, 8
                  auipc        a7, 753373
                  sb           a7, -1(a6)
                  lbu          a7, 7(a6)
                  sll          a7, a2, t3
                  and          a2, s10, ra
                  lh           ra, 35(a6)
                  lh           a7, -19(a6)
                  sb           s1, -27(a6)
                  lbu          t3, 37(a6)
                  xori         t3, s10, 490
                  srli         ra, s10, 29
                  sb           a7, 28(a6)
                  lb           ra, -57(a6)
                  sb           ra, -52(a6)
                  sltiu        s10, a7, 1900
                  srli         t3, a2, 14
                  lbu          a7, 10(a6) #end riscv_hazard_instr_stream_1
                  la           s0, region_1+1693 #start load_store_instr_stream_1
                  la           s10, region_1+3982 #start load_store_instr_stream_2
                  lb           a7, -90(s0)
                  sb           s11, 81(s10)
                  sb           ra, -114(s0)
                  lbu          sp, -135(s10)
                  sb           s1, -204(s0)
                  lb           gp, -40(s10)
                  la           s9, region_1+2306 #start load_store_instr_stream_0
                  lbu          gp, 1(s10)
                  la           t3, region_1+3232 #start load_store_instr_stream_3
                  sb           s8, -185(s10)
                  lb           ra, -255(s0)
                  lbu          a3, 104(s0)
                  lb           s7, -58(s9)
                  sb           s5, 57(t3)
                  sh           t1, -44(s9)
                  lbu          s11, -140(s0)
                  lbu          tp, -59(t3)
                  lbu          a6, -93(s10)
                  lhu          t4, -18(t3)
                  lb           a2, -117(s0)
                  lb           s11, -49(s10)
                  lb           a5, 27(s9)
                  sh           t2, 14(s9)
                  lbu          s3, 134(s0)
                  lb           s4, -132(s10)
                  lb           s11, 249(s0)
                  lb           t5, -41(t3)
                  sb           a7, 60(t3)
                  sb           s9, -74(s10) #end load_store_instr_stream_2
                  lw           a4, 0(t3) #end load_store_instr_stream_3
                  lb           s4, 12(s0) #end load_store_instr_stream_1
                  lb           s5, -56(s9) #end load_store_instr_stream_0
sub_2_4:          jal          t1, 2f
0:                jal          ra, 7f
1:                jal          t1, 9f
2:                jal          t1, 20f
3:                jal          a5, 10f
4:                jal          t1, 13f
5:                jal          ra, 15f
6:                jal          ra, 1b
7:                jal          ra, 8f
8:                jal          s1, 14f
9:                jal          tp, 0b
10:               jal          ra, 18f
11:               jal          ra, 21f
12:               jal          ra, 16f
13:               jal          ra, 23f
14:               jal          t1, 11b
15:               jal          t0, 17f
16:               jal          t1, 19f
17:               jal          t1, 12b
18:               jal          s0, 4b
19:               jal          tp, 6b
20:               jal          ra, 5b
21:               jal          ra, 22f
22:               jal          ra, 3b
23:               slli         s3, s4, 27
                  la           t4, region_0+2587 #start load_store_instr_stream_0
                  la           s10, region_0+3950 #start load_store_instr_stream_1
                  lb           ra, -75(t4)
                  lb           s9, -493(s10)
                  sb           a4, 240(t4)
                  lh           s9, -644(s10)
                  lbu          s0, -189(t4)
                  lb           a5, -63(t4)
                  sh           t1, -1426(s10)
                  lbu          s1, 186(t4)
                  lbu          s8, -1947(s10)
                  lh           gp, -690(s10) #end load_store_instr_stream_1
                  sb           s4, 105(t4) #end load_store_instr_stream_0
                  la           gp, region_1+3726 #start riscv_hazard_instr_stream_2
                  lb           a3, -5(gp)
                  lb           s0, -7(gp)
                  slti         s0, s0, -14
                  sltiu        s0, s0, 686
                  lb           a7, 4(gp)
                  auipc        ra, 425127
                  srl          ra, a3, s10
                  and          s10, ra, ra
                  sub          a3, a7, ra
                  lb           a3, -13(gp)
                  lh           s10, 4(gp)
                  and          ra, ra, s0
                  sb           s0, -3(gp)
                  lbu          s10, -5(gp)
                  lbu          a3, -2(gp)
                  auipc        a3, 976024
                  add          t4, s0, s0
                  or           s10, ra, s10
                  lb           a7, 1(gp)
                  slti         a3, a7, -1533
                  lb           s0, 0(gp)
                  lhu          a3, 12(gp)
                  slti         s10, s0, -189
                  sra          a7, a3, s0
                  lh           t4, -14(gp)
                  slli         s10, s10, 30
                  lb           t4, 1(gp)
                  sb           s10, 10(gp)
                  srl          a7, ra, a3
                  lbu          a7, 13(gp)
                  sb           a3, 3(gp)
                  lbu          t4, -1(gp)
                  auipc        s0, 666335
                  sub          a3, a3, a7
                  xori         t4, a3, 1573
                  lbu          ra, 3(gp)
                  sltu         ra, ra, s10
                  sb           t4, -16(gp)
                  sb           ra, 14(gp)
                  xori         s10, a3, -1167
                  xor          ra, s10, a7
                  srai         s10, s0, 29
                  lh           ra, 4(gp)
                  sra          a3, t4, t4
                  sw           ra, 10(gp)
                  lbu          a3, 1(gp)
                  and          s0, t4, t4
                  slt          ra, s0, s10
                  lb           s10, 15(gp)
                  lui          ra, 375997
                  lb           a3, -9(gp)
                  sltiu        a3, a3, -57
                  lb           t4, -1(gp)
                  lui          a7, 205187
                  lb           a7, 8(gp)
                  lbu          t4, 6(gp)
                  lbu          a7, -12(gp) #end riscv_hazard_instr_stream_2
                  la           s2, region_1+516 #start load_store_instr_stream_0
                  lh           s4, -2(s2)
                  la           t1, region_1+2627 #start load_store_instr_stream_1
                  sb           zero, -214(t1)
                  lb           zero, 3(s2)
                  sb           t1, 45(t1)
                  lh           a3, -12(s2)
                  la           t6, region_1+2506 #start load_store_instr_stream_2
                  lw           zero, -11(t1)
                  sw           a7, 8(s2)
                  sb           t1, 48(t1)
                  lb           sp, 62(t6)
                  lbu          s5, -5(s2)
                  lbu          a4, -252(t1)
                  lbu          a2, 9(t6)
                  lb           s10, 15(s2)
                  lb           s4, -9(t6)
                  sb           t5, -216(t1)
                  lbu          gp, 148(t1)
                  lb           s11, -46(t6)
                  lbu          s11, 13(t6)
                  lb           tp, 8(s2)
                  sb           a4, 2(s2)
                  lb           sp, -248(t1)
                  lb           t3, -60(t6) #end load_store_instr_stream_2
                  lbu          s0, 212(t1)
                  lh           s10, -16(s2)
                  lbu          t0, -221(t1) #end load_store_instr_stream_1
                  sb           a3, 3(s2) #end load_store_instr_stream_0
                  addi         s5, zero, 9 #init loop 0 counter
                  sltu         a5, s3, s1
                  and          s2, a7, sp
                  andi         t0, t4, -1449
                  addi         tp, zero, 7 #init loop 0 limit
                  srli         t1, zero, 19
sub_2_11_0_t:     or           s3, a7, s6
                  nop
                  addi         s5, s5, -5 #update loop 0 counter
                  srli         a5, a3, 23
                  slti         t5, s9, -201
                  sll          s9, ra, s7
                  bgeu         s5, tp, sub_2_11_0_t #branch for loop 0
                  sra          t0, a3, s5
                  bge          t4, s4, 14f
                  srai         zero, t5, 14
                  sub          a7, t0, a1
                  bltu         t3, zero, 5f
                  addi         s3, t1, -430
5:                bge          tp, a1, 23f
                  auipc        zero, 950757
                  and          s4, a2, s11
                  and          s1, ra, a5
                  sltiu        a3, t2, 1961
                  sub          s4, t2, s5
                  slli         a3, s9, 27
                  addi         s11, t1, -280
                  nop
14:               or           zero, t5, a1
                  xor          t1, s2, s10
                  add          s1, s4, a2
                  sll          t6, a3, s3
                  bge          a1, a3, 30f
                  bltu         s1, s10, 39f
                  lui          s8, 805717
                  srl          t3, s2, a7
                  sltiu        ra, a1, -37
23:               sll          tp, a1, s7
                  sra          s9, s8, t3
                  lui          a7, 834653
                  add          s7, s0, s11
                  srl          a5, t4, t0
                  xori         s4, s6, -936
                  bge          a4, a4, 33f
30:               nop
                  xori         a4, s5, 1145
                  sll          gp, t1, s11
33:               srai         s2, s3, 10
                  sltiu        s11, s3, -1502
                  add          t1, s7, a4
                  beq          a1, s11, 55f
                  nop
                  bgeu         s8, s11, 53f
39:               srli         s0, tp, 27
                  sra          a2, s4, t3
                  add          t1, t6, t5
                  bgeu         s3, t0, 52f
                  auipc        t1, 822499
                  srli         a2, a2, 8
                  and          s3, a1, a7
                  bge          t2, s4, 62f
                  bltu         a2, a5, 63f
                  blt          a0, a3, 67f
                  add          s7, a1, s9
                  slli         tp, s7, 24
                  slti         t5, s9, 167
52:               bgeu         s9, zero, 55f
53:               nop
                  bne          t5, a6, 59f
55:               slli         zero, s10, 9
                  srl          t3, s5, s2
                  bgeu         s0, sp, 60f
                  srl          a3, s5, s2
59:               srli         ra, t1, 6
60:               nop
                  bgeu         a2, s7, 71f
62:               slt          gp, t3, a6
63:               bgeu         s8, sp, 69f
                  and          a5, t5, s3
                  slli         s8, a2, 27
                  or           a4, s7, a7
67:               add          s11, s10, s6
                  addi         t6, s7, -1902
69:               sub          a2, tp, a2
                  sra          t4, s8, a1
71:               srl          t1, a6, a4
                  sra          a6, a5, s11
                  sltu         s2, a5, a7
                  bgeu         t2, a7, 86f
                  ori          tp, s5, 499
                  srai         t4, a2, 17
                  blt          ra, a1, 92f
                  sra          s1, t4, a7
                  slti         sp, s4, 876
                  xori         s7, s10, -257
                  slt          s5, t2, a6
                  add          s10, s3, s3
                  bltu         s10, t2, 85f
                  sltiu        s2, a2, 1119
85:               nop
86:               sll          t3, t2, s3
                  ori          s2, a1, -1792
                  blt          a2, s7, 99f
                  lui          s2, 754300
                  sub          s7, a2, s2
                  srli         s3, s8, 25
92:               xori         tp, a1, 1686
                  or           s10, a0, zero
                  auipc        t4, 252994
                  sll          t4, t6, s4
                  bge          gp, t6, 109f
                  slti         t1, t1, 1784
                  xor          s11, t0, a0
99:               bge          a2, ra, 117f
                  bltu         a6, s10, 113f
                  srli         t3, zero, 27
                  andi         t4, gp, 1645
                  xor          s1, a2, a5
                  bne          gp, a5, 112f
                  srai         a7, s6, 12
                  xori         s9, s11, 946
                  xori         s5, t4, 360
                  auipc        a4, 292537
109:              bge          t0, t6, 128f
                  and          s11, t3, t1
                  sra          a5, t1, a5
112:              bgeu         a5, s2, 131f
113:              srl          t4, a4, s1
                  srl          s0, sp, s10
                  andi         a2, ra, 1116
                  sra          s2, s4, a3
117:              sltu         s0, a4, s2
                  nop
                  sra          s4, t0, a1
                  addi         ra, s9, -60
                  lui          a5, 651787
                  bne          a4, s4, 123f
123:              bgeu         sp, a4, 124f
124:              and          tp, ra, s1
                  srl          gp, a7, s9
                  srl          ra, s6, s1
                  addi         t4, s8, 875
128:              nop
                  sra          s4, s11, s11
                  bltu         t3, t2, 136f
131:              bne          a2, s9, 143f
                  sub          s1, s8, tp
                  ori          a7, s3, -331
                  bge          t0, t2, 136f
                  blt          s8, t5, 146f
136:              bne          s1, a6, 151f
                  xor          t3, gp, t6
                  or           gp, a5, sp
                  lui          t4, 266946
                  bltu         ra, a6, 153f
                  auipc        t1, 724691
                  and          t0, gp, a4
143:              sll          s8, t6, gp
                  slti         t0, s0, 652
                  auipc        s5, 705576
146:              bge          s7, t5, 148f
                  sltiu        a7, t6, 1219
148:              or           s1, s8, s2
                  bne          s6, t1, 154f
                  srai         s0, s9, 30
151:              bltu         t6, s6, 167f
                  bltu         a4, t2, 171f
153:              slli         gp, s7, 0
154:              bne          t5, t5, 173f
                  slli         s2, t6, 30
                  slti         s5, a3, -420
                  slt          gp, s6, s9
                  auipc        s2, 932221
                  auipc        a7, 745627
                  xor          s1, sp, a5
                  slti         s7, a3, 207
                  bltu         gp, t0, 168f
                  srl          s1, gp, s1
                  add          t4, a5, s8
                  sltu         a2, tp, a7
                  bge          s3, s0, 179f
167:              srai         s11, t6, 31
168:              srl          a6, tp, s6
                  bge          s10, s11, 187f
                  sll          t0, t0, t2
171:              sltu         a5, s4, s5
                  sub          a4, a7, s3
173:              bgeu         s11, t3, 183f
                  blt          a0, s9, 175f
175:              xori         a3, s7, -8
                  ori          t0, s5, 327
                  nop
                  and          s3, gp, t3
179:              sltu         t3, s1, t4
                  slti         s3, s8, -1880
                  slt          a2, s4, sp
                  nop
183:              addi         s5, s5, 298
                  bge          t6, a6, 203f
                  or           s0, s0, s1
                  slt          s1, s8, s11
187:              andi         s5, t6, -1546
                  add          s8, t0, s3
                  lui          a6, 58220
                  or           a6, s2, s0
                  slt          a2, sp, s5
                  nop
                  beq          s4, t3, 196f
                  slti         t6, a1, 1745
                  beq          ra, s8, 213f
196:              xori         s0, t5, -56
                  sltu         gp, s2, t4
                  nop
                  bge          t4, t1, 200f
200:              add          a7, s3, t6
                  addi         s4, gp, -1162
                  addi         s8, s3, -642
203:              add          s5, a0, a7
                  slt          t5, t0, t0
                  sltiu        s1, s8, 1538
                  srli         tp, a3, 18
                  srli         t0, s6, 15
                  andi         a3, gp, 68
                  andi         tp, t6, -684
                  blt          a6, a3, 225f
                  nop
                  and          s7, zero, zero
213:              sub          s4, s9, t0
                  slti         a7, t0, -1811
                  andi         s10, a4, -1373
                  sub          s9, s9, s1
                  srli         s0, s11, 4
                  sltu         s8, zero, s11
                  andi         a3, a2, -299
                  andi         s0, s0, -718
                  xori         t5, s1, -1959
                  bgeu         t0, a2, 228f
                  slt          s8, t6, s7
                  sltu         sp, a1, a4
225:              bgeu         t6, s10, 241f
                  sltu         zero, s0, zero
                  sra          a2, a7, a7
228:              sltu         t3, s5, t1
                  xor          gp, s7, a1
                  xor          zero, t5, s10
                  bgeu         t3, s9, 235f
                  nop
                  and          a3, s7, a4
                  sltiu        sp, a6, -452
235:              bne          s7, ra, 243f
                  blt          s2, s5, 246f
                  andi         tp, t4, 1906
                  xori         s5, t2, -1169
                  bne          t1, zero, 258f
                  xori         s11, s4, -1547
241:              sltiu        t1, gp, 33
                  sub          s1, s8, a3
243:              slti         a4, s8, 1590
                  sltiu        a7, a7, 188
                  srl          gp, gp, t1
246:              beq          s11, t2, 249f
                  srl          t3, t1, zero
                  xor          t6, s10, ra
249:              slli         s4, t4, 5
                  xor          a6, a6, s10
                  sub          s0, s3, t5
                  bgeu         a4, s2, 272f
                  xori         a5, a5, 374
                  sltiu        a6, zero, -312
                  nop
                  add          t0, a0, t6
                  slti         zero, s6, 1852
258:              blt          a4, s7, 272f
                  xori         a7, s10, 1418
                  and          a6, s3, s6
                  auipc        t6, 152280
                  sltiu        t4, sp, 869
                  bne          t5, t1, 275f
                  andi         a1, t2, -125
                  sltu         s11, a6, s3
                  bne          a7, s3, 269f
                  and          t6, t3, gp
                  addi         t1, t0, -164
269:              andi         gp, zero, -944
                  or           t1, s8, sp
                  slt          t3, tp, a0
272:              addi         a3, t2, -1962
                  sra          t6, a1, s1
                  andi         a1, t3, -310
275:              beq          t3, sp, 283f
                  lui          t5, 927720
                  slli         t4, a3, 16
                  nop
                  slt          s10, t3, s3
                  xor          a1, sp, a1
                  add          sp, t6, a3
                  nop
283:              sltu         a5, a3, t6
                  bgeu         s6, a0, 294f
                  bne          t3, s0, 297f
                  srli         zero, a4, 3
                  sub          s11, a4, s4
                  sll          gp, s8, sp
                  andi         s11, a7, -1387
                  bltu         s8, s4, 303f
                  blt          a4, a7, 306f
                  lui          s9, 423580
                  andi         gp, t3, 178
294:              slti         s4, s11, 1865
                  xor          s11, s0, a7
                  sll          s11, t5, t6
297:              addi         tp, t2, -650
                  beq          s1, t5, 316f
                  andi         s9, t3, 1622
                  srli         t4, t3, 29
                  slt          a7, a5, sp
                  sll          ra, t5, a7
303:              sra          a4, a4, sp
                  or           t3, s7, s4
                  sub          t0, tp, ra
306:              srl          t0, s7, s9
                  bge          a6, a6, 319f
                  srli         a1, s0, 14
                  auipc        t6, 440034
                  srli         s7, gp, 4
                  slli         sp, t3, 2
                  xor          s8, s0, t5
                  xori         a5, a1, 170
                  blt          s0, s4, 334f
                  lui          s2, 1023525
316:              blt          a6, t4, 335f
                  bne          ra, a7, 328f
                  and          s4, tp, gp
319:              xor          s9, sp, s9
                  srai         a2, t1, 3
                  xor          t4, s2, s10
                  sltu         a7, a2, s4
                  bltu         s11, s9, 325f
                  slli         s5, s1, 23
325:              bne          t1, s4, 341f
                  xori         s4, s4, -340
                  slti         s9, gp, 176
328:              srl          a5, s3, sp
                  add          s2, t1, t2
                  addi         s7, a5, 163
                  bgeu         a2, a5, 349f
                  and          ra, a7, t0
                  addi         t5, s0, 1130
334:              sll          tp, t1, a4
                  la           t1, region_1+3464 #start riscv_load_store_hazard_instr_stream_3
                  sltiu        s10, zero, -1236
                  lbu          s3, -45(t1)
                  sb           t0, 45(t1)
                  lbu          s0, 53(t1)
                  lb           s1, 53(t1)
                  lbu          s8, 53(t1)
                  srai         a3, a4, 4
                  srai         gp, s4, 26
                  sh           sp, -38(t1)
                  lb           tp, -11(t1)
                  lbu          t6, -43(t1)
                  lh           t5, 14(t1)
                  lhu          a2, -56(t1)
                  lw           s5, -56(t1)
                  lw           a5, -56(t1)
                  lh           a2, 2(t1)
                  lhu          ra, 2(t1)
                  lh           a2, 2(t1)
                  sh           s2, 2(t1)
                  lbu          zero, -42(t1) #end riscv_load_store_hazard_instr_stream_3
335:              auipc        a3, 971128
                  andi         zero, s11, 1979
                  beq          tp, a5, 341f
                  add          gp, s5, a1
                  srli         s0, a7, 18
                  slti         zero, t4, 816
341:              slti         s11, gp, 1684
                  bne          s11, s3, 345f
                  sltu         t4, t2, a1
                  ori          t5, t1, -1296
345:              slli         sp, s9, 13
                  sltu         gp, s1, s5
                  addi         a4, a6, -1978
                  slti         t0, s11, -1379
349:              xori         s4, s3, -253
                  sub          tp, t4, a6
                  srli         zero, s11, 8
                  bgeu         t2, a5, 353f
353:              auipc        ra, 361842
                  lui          t3, 379358
                  sltu         a3, s6, s5
                  bne          t3, s1, 362f
                  blt          t1, s3, 376f
                  srai         s7, ra, 29
                  addi         a7, t0, 1933
                  slli         a4, s7, 7
                  and          a7, a0, t1
362:              bne          gp, s10, 363f
363:              add          a2, gp, zero
                  bne          s2, t5, 378f
                  sub          zero, a0, t0
                  srl          s7, sp, t6
                  bgeu         tp, sp, 369f
                  sll          s1, a2, s5
369:              sll          t4, gp, a3
                  slt          a4, s2, s7
                  xor          a7, zero, a5
                  lui          s7, 140441
                  addi         t1, s6, 0
                  addi         t3, s9, -1355
                  auipc        t3, 1005271
376:              nop
                  or           s1, sp, a1
378:              bltu         a3, ra, 388f
                  sltu         s8, t6, s10
                  slli         gp, s2, 23
                  bgeu         a6, t1, 387f
                  srai         t5, t1, 17
                  srl          a5, a0, a4
                  add          a2, a1, a5
                  bge          s11, t6, 404f
                  sltiu        s5, t3, 1137
387:              nop
388:              add          a2, s1, s6
                  srl          t5, s6, a0
                  srli         s2, t2, 28
                  srl          a4, t1, s0
                  andi         a4, t6, -353
                  add          t1, a1, a0
                  sltu         s3, a0, s5
                  bne          a0, s4, 410f
                  ori          t4, s7, 922
                  slti         t1, t6, 1152
                  sra          t5, s3, s10
                  beq          s7, t6, 415f
                  sll          t4, s7, s6
                  or           s0, s7, t0
                  addi         s7, a0, -413
                  blt          a3, t0, 422f
404:              sltu         t0, zero, gp
                  bltu         a2, gp, 410f
                  xor          gp, a4, s1
                  slt          t6, s0, s10
                  beq          a2, gp, 421f
                  or           a3, t6, a4
410:              xor          t3, s9, a4
                  sltiu        a7, gp, -1486
                  slli         s8, a7, 7
                  andi         t4, zero, -770
                  sra          s8, s5, s3
415:              bltu         s8, a1, 434f
                  blt          t5, sp, 432f
                  slti         s7, s4, -311
                  xor          s0, s8, ra
                  srl          s9, gp, t4
                  srli         s10, s11, 14
421:              srl          a3, t4, a0
422:              sltiu        t0, zero, 653
                  nop
                  andi         s2, s2, 1009
                  slli         a3, t1, 14
                  sltiu        s2, s5, 201
                  or           s9, a6, gp
                  ori          s1, t1, 1201
                  and          a5, t6, a4
                  srai         s0, s8, 24
                  slli         s2, s5, 3
432:              bltu         s5, t3, 434f
                  slti         a3, s8, 302
434:              andi         gp, sp, 53
                  sra          s7, s2, a2
                  lw           t1, 4(a0)
                  xori         ra, t1, -693
                  addi         a0, a0, 44
                  sltiu        s0, t5, -492
                  srl          a6, a6, t3
                  slt          s9, s5, s0
980:              addi x4, x6, 1
980:              jalr x4, x4, 0
write_tohost:     
                  sw gp, tohost, t5

_exit:            
                  j write_tohost

instr_end:        
                  nop

.section .data
.align 6; .global tohost; tohost: .dword 0;
.align 6; .global fromhost; fromhost: .dword 0;
.section .region_0,"aw",@progbits;
region_0:
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.section .region_1,"aw",@progbits;
region_1:
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.word 0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f
.word 0x20212223, 0x24252627, 0x28292a2b, 0x2c2d2e2f, 0x30313233, 0x34353637, 0x38393a3b, 0x3c3d3e3f
.word 0x40414243, 0x44454647, 0x48494a4b, 0x4c4d4e4f, 0x50515253, 0x54555657, 0x58595a5b, 0x5c5d5e5f
.word 0x60616263, 0x64656667, 0x68696a6b, 0x6c6d6e6f, 0x70717273, 0x74757677, 0x78797a7b, 0x7c7d7e7f
.word 0x80818283, 0x84858687, 0x88898a8b, 0x8c8d8e8f, 0x90919293, 0x94959697, 0x98999a9b, 0x9c9d9e9f
.word 0xa0a1a2a3, 0xa4a5a6a7, 0xa8a9aaab, 0xacadaeaf, 0xb0b1b2b3, 0xb4b5b6b7, 0xb8b9babb, 0xbcbdbebf
.word 0xc0c1c2c3, 0xc4c5c6c7, 0xc8c9cacb, 0xcccdcecf, 0xd0d1d2d3, 0xd4d5d6d7, 0xd8d9dadb, 0xdcdddedf
.word 0xe0e1e2e3, 0xe4e5e6e7, 0xe8e9eaeb, 0xecedeeef, 0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff
.section .user_stack,"aw",@progbits;
.align 2
user_stack_start:
.rept 2000
.4byte 0x0
.endr
user_stack_end:
.4byte 0x0
.align 2
kernel_instr_start:
.text
mmode_intr_vector_1:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_2:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_3:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_4:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_5:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_6:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_7:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_8:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_9:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_10:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_11:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_12:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_13:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_14:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

mmode_intr_vector_15:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x342 # MCAUSE
                  srli x28, x28, 0x1f
                  beqz x28, 1f
                  j mmode_intr_handler
                  1: la x22, test_done
                  jalr x0, x22, 0

.align           4
mtvec_handler:    
                  .option norvc;
                  j mmode_exception_handler
                  j mmode_intr_vector_1
                  j mmode_intr_vector_2
                  j mmode_intr_vector_3
                  j mmode_intr_vector_4
                  j mmode_intr_vector_5
                  j mmode_intr_vector_6
                  j mmode_intr_vector_7
                  j mmode_intr_vector_8
                  j mmode_intr_vector_9
                  j mmode_intr_vector_10
                  j mmode_intr_vector_11
                  j mmode_intr_vector_12
                  j mmode_intr_vector_13
                  j mmode_intr_vector_14
                  j mmode_intr_vector_15

mmode_exception_handler:
                  addi x7, x7, -4
                  sw  x10, (x7)
                  add x10, x7, zero
                  addi x10, x10, -128
                  sw  x1, 4(x10)
                  sw  x2, 8(x10)
                  sw  x3, 12(x10)
                  sw  x4, 16(x10)
                  sw  x5, 20(x10)
                  sw  x6, 24(x10)
                  sw  x7, 28(x10)
                  sw  x8, 32(x10)
                  sw  x9, 36(x10)
                  sw  x10, 40(x10)
                  sw  x11, 44(x10)
                  sw  x12, 48(x10)
                  sw  x13, 52(x10)
                  sw  x14, 56(x10)
                  sw  x15, 60(x10)
                  sw  x16, 64(x10)
                  sw  x17, 68(x10)
                  sw  x18, 72(x10)
                  sw  x19, 76(x10)
                  sw  x20, 80(x10)
                  sw  x21, 84(x10)
                  sw  x22, 88(x10)
                  sw  x23, 92(x10)
                  sw  x24, 96(x10)
                  sw  x25, 100(x10)
                  sw  x26, 104(x10)
                  sw  x27, 108(x10)
                  sw  x28, 112(x10)
                  sw  x29, 116(x10)
                  sw  x30, 120(x10)
                  sw  x31, 124(x10)
                  add x7, x10, zero
                  csrr x28, 0x341 # MEPC
                  csrr x28, 0x342 # MCAUSE
                  li x14, 0x3 # BREAKPOINT
                  beq x28, x14, ebreak_handler
                  li x14, 0x8 # ECALL_UMODE
                  beq x28, x14, ecall_handler
                  li x14, 0x9 # ECALL_SMODE
                  beq x28, x14, ecall_handler
                  li x14, 0xb # ECALL_MMODE
                  beq x28, x14, ecall_handler
                  li x14, 0x1
                  beq x28, x14, instr_fault_handler
                  li x14, 0x5
                  beq x28, x14, load_fault_handler
                  li x14, 0x7
                  beq x28, x14, store_fault_handler
                  li x14, 0xc
                  beq x28, x14, pt_fault_handler
                  li x14, 0xd
                  beq x28, x14, pt_fault_handler
                  li x14, 0xf
                  beq x28, x14, pt_fault_handler
                  li x14, 0x2 # ILLEGAL_INSTRUCTION
                  beq x28, x14, illegal_instr_handler
                  csrr x14, 0x343 # MTVAL
                  1: la x22, test_done
                  jalr x1, x22, 0

ecall_handler:    
                  la x28, _start
                  sw x0, 0(x28)
                  sw x1, 4(x28)
                  sw x2, 8(x28)
                  sw x3, 12(x28)
                  sw x4, 16(x28)
                  sw x5, 20(x28)
                  sw x6, 24(x28)
                  sw x7, 28(x28)
                  sw x8, 32(x28)
                  sw x9, 36(x28)
                  sw x10, 40(x28)
                  sw x11, 44(x28)
                  sw x12, 48(x28)
                  sw x13, 52(x28)
                  sw x14, 56(x28)
                  sw x15, 60(x28)
                  sw x16, 64(x28)
                  sw x17, 68(x28)
                  sw x18, 72(x28)
                  sw x19, 76(x28)
                  sw x20, 80(x28)
                  sw x21, 84(x28)
                  sw x22, 88(x28)
                  sw x23, 92(x28)
                  sw x24, 96(x28)
                  sw x25, 100(x28)
                  sw x26, 104(x28)
                  sw x27, 108(x28)
                  sw x28, 112(x28)
                  sw x29, 116(x28)
                  sw x30, 120(x28)
                  sw x31, 124(x28)
                  la x22, write_tohost
                  jalr x0, x22, 0

instr_fault_handler:
                  add x10, x7, zero
                  lw  x1, 4(x10)
                  lw  x2, 8(x10)
                  lw  x3, 12(x10)
                  lw  x4, 16(x10)
                  lw  x5, 20(x10)
                  lw  x6, 24(x10)
                  lw  x7, 28(x10)
                  lw  x8, 32(x10)
                  lw  x9, 36(x10)
                  lw  x10, 40(x10)
                  lw  x11, 44(x10)
                  lw  x12, 48(x10)
                  lw  x13, 52(x10)
                  lw  x14, 56(x10)
                  lw  x15, 60(x10)
                  lw  x16, 64(x10)
                  lw  x17, 68(x10)
                  lw  x18, 72(x10)
                  lw  x19, 76(x10)
                  lw  x20, 80(x10)
                  lw  x21, 84(x10)
                  lw  x22, 88(x10)
                  lw  x23, 92(x10)
                  lw  x24, 96(x10)
                  lw  x25, 100(x10)
                  lw  x26, 104(x10)
                  lw  x27, 108(x10)
                  lw  x28, 112(x10)
                  lw  x29, 116(x10)
                  lw  x30, 120(x10)
                  lw  x31, 124(x10)
                  addi x10, x10, 128
                  add x7, x10, zero
                  lw  x10, (x7)
                  addi x7, x7, 4
                  mret

load_fault_handler:
                  add x10, x7, zero
                  lw  x1, 4(x10)
                  lw  x2, 8(x10)
                  lw  x3, 12(x10)
                  lw  x4, 16(x10)
                  lw  x5, 20(x10)
                  lw  x6, 24(x10)
                  lw  x7, 28(x10)
                  lw  x8, 32(x10)
                  lw  x9, 36(x10)
                  lw  x10, 40(x10)
                  lw  x11, 44(x10)
                  lw  x12, 48(x10)
                  lw  x13, 52(x10)
                  lw  x14, 56(x10)
                  lw  x15, 60(x10)
                  lw  x16, 64(x10)
                  lw  x17, 68(x10)
                  lw  x18, 72(x10)
                  lw  x19, 76(x10)
                  lw  x20, 80(x10)
                  lw  x21, 84(x10)
                  lw  x22, 88(x10)
                  lw  x23, 92(x10)
                  lw  x24, 96(x10)
                  lw  x25, 100(x10)
                  lw  x26, 104(x10)
                  lw  x27, 108(x10)
                  lw  x28, 112(x10)
                  lw  x29, 116(x10)
                  lw  x30, 120(x10)
                  lw  x31, 124(x10)
                  addi x10, x10, 128
                  add x7, x10, zero
                  lw  x10, (x7)
                  addi x7, x7, 4
                  mret

store_fault_handler:
                  add x10, x7, zero
                  lw  x1, 4(x10)
                  lw  x2, 8(x10)
                  lw  x3, 12(x10)
                  lw  x4, 16(x10)
                  lw  x5, 20(x10)
                  lw  x6, 24(x10)
                  lw  x7, 28(x10)
                  lw  x8, 32(x10)
                  lw  x9, 36(x10)
                  lw  x10, 40(x10)
                  lw  x11, 44(x10)
                  lw  x12, 48(x10)
                  lw  x13, 52(x10)
                  lw  x14, 56(x10)
                  lw  x15, 60(x10)
                  lw  x16, 64(x10)
                  lw  x17, 68(x10)
                  lw  x18, 72(x10)
                  lw  x19, 76(x10)
                  lw  x20, 80(x10)
                  lw  x21, 84(x10)
                  lw  x22, 88(x10)
                  lw  x23, 92(x10)
                  lw  x24, 96(x10)
                  lw  x25, 100(x10)
                  lw  x26, 104(x10)
                  lw  x27, 108(x10)
                  lw  x28, 112(x10)
                  lw  x29, 116(x10)
                  lw  x30, 120(x10)
                  lw  x31, 124(x10)
                  addi x10, x10, 128
                  add x7, x10, zero
                  lw  x10, (x7)
                  addi x7, x7, 4
                  mret

ebreak_handler:   
                  csrr  x28, 0x341
                  addi  x28, x28, 4
                  csrw  0x341, x28
                  add x10, x7, zero
                  lw  x1, 4(x10)
                  lw  x2, 8(x10)
                  lw  x3, 12(x10)
                  lw  x4, 16(x10)
                  lw  x5, 20(x10)
                  lw  x6, 24(x10)
                  lw  x7, 28(x10)
                  lw  x8, 32(x10)
                  lw  x9, 36(x10)
                  lw  x10, 40(x10)
                  lw  x11, 44(x10)
                  lw  x12, 48(x10)
                  lw  x13, 52(x10)
                  lw  x14, 56(x10)
                  lw  x15, 60(x10)
                  lw  x16, 64(x10)
                  lw  x17, 68(x10)
                  lw  x18, 72(x10)
                  lw  x19, 76(x10)
                  lw  x20, 80(x10)
                  lw  x21, 84(x10)
                  lw  x22, 88(x10)
                  lw  x23, 92(x10)
                  lw  x24, 96(x10)
                  lw  x25, 100(x10)
                  lw  x26, 104(x10)
                  lw  x27, 108(x10)
                  lw  x28, 112(x10)
                  lw  x29, 116(x10)
                  lw  x30, 120(x10)
                  lw  x31, 124(x10)
                  addi x10, x10, 128
                  add x7, x10, zero
                  lw  x10, (x7)
                  addi x7, x7, 4
                  mret

illegal_instr_handler:
                  csrr  x28, 0x341
                  addi  x28, x28, 4
                  csrw  0x341, x28
                  add x10, x7, zero
                  lw  x1, 4(x10)
                  lw  x2, 8(x10)
                  lw  x3, 12(x10)
                  lw  x4, 16(x10)
                  lw  x5, 20(x10)
                  lw  x6, 24(x10)
                  lw  x7, 28(x10)
                  lw  x8, 32(x10)
                  lw  x9, 36(x10)
                  lw  x10, 40(x10)
                  lw  x11, 44(x10)
                  lw  x12, 48(x10)
                  lw  x13, 52(x10)
                  lw  x14, 56(x10)
                  lw  x15, 60(x10)
                  lw  x16, 64(x10)
                  lw  x17, 68(x10)
                  lw  x18, 72(x10)
                  lw  x19, 76(x10)
                  lw  x20, 80(x10)
                  lw  x21, 84(x10)
                  lw  x22, 88(x10)
                  lw  x23, 92(x10)
                  lw  x24, 96(x10)
                  lw  x25, 100(x10)
                  lw  x26, 104(x10)
                  lw  x27, 108(x10)
                  lw  x28, 112(x10)
                  lw  x29, 116(x10)
                  lw  x30, 120(x10)
                  lw  x31, 124(x10)
                  addi x10, x10, 128
                  add x7, x10, zero
                  lw  x10, (x7)
                  addi x7, x7, 4
                  mret

pt_fault_handler: 
                  nop

.align 2
mmode_intr_handler:
                  csrr  x28, 0x300 # MSTATUS;
                  csrr  x28, 0x304 # MIE;
                  csrr  x28, 0x344 # MIP;
                  csrrc x28, 0x344, x28 # MIP;
                  add x10, x7, zero
                  lw  x1, 4(x10)
                  lw  x2, 8(x10)
                  lw  x3, 12(x10)
                  lw  x4, 16(x10)
                  lw  x5, 20(x10)
                  lw  x6, 24(x10)
                  lw  x7, 28(x10)
                  lw  x8, 32(x10)
                  lw  x9, 36(x10)
                  lw  x10, 40(x10)
                  lw  x11, 44(x10)
                  lw  x12, 48(x10)
                  lw  x13, 52(x10)
                  lw  x14, 56(x10)
                  lw  x15, 60(x10)
                  lw  x16, 64(x10)
                  lw  x17, 68(x10)
                  lw  x18, 72(x10)
                  lw  x19, 76(x10)
                  lw  x20, 80(x10)
                  lw  x21, 84(x10)
                  lw  x22, 88(x10)
                  lw  x23, 92(x10)
                  lw  x24, 96(x10)
                  lw  x25, 100(x10)
                  lw  x26, 104(x10)
                  lw  x27, 108(x10)
                  lw  x28, 112(x10)
                  lw  x29, 116(x10)
                  lw  x30, 120(x10)
                  lw  x31, 124(x10)
                  addi x10, x10, 128
                  add x7, x10, zero
                  lw  x10, (x7)
                  addi x7, x7, 4
                  mret;

kernel_instr_end: nop
.section .kernel_stack,"aw",@progbits;
.align 2
kernel_stack_start:
.rept 2000
.4byte 0x0
.endr
kernel_stack_end:
.4byte 0x0
