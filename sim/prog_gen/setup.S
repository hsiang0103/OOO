.global SystemExit

# Define constants
.section .text
.align 2
.globl custom_setup    
custom_setup:       
    /* 1. 保存返回地址 (main.S 的地址) 到臨時暫存器 s11 */
    mv s11, ra

    /* 設定 CSR (如果需要) */
    li t0, 0x00006000   
    csrs mstatus, t0 

    /* initialize global pointer */
    la gp, _gp

init_bss:
    /* init bss section */
    la a0, __bss_start
    la a1, __bss_end-4 
    li a2, 0x0
    jal fill_block      /* jal 會覆蓋 ra (x1)，但我們已經備份在 s11 了 */

init_sbss:
    /* init sbss section */
    la a0, __sbss_start
    la a1, __sbss_end-4 
    li a2, 0x0
    jal fill_block

SystemInit:
    /* 3. 恢復返回地址，並跳回 main.S */
    mv ra, s11          /* 從 s11 取回原本 main.S 的地址 */
    ret

SystemExit:
    /* End simulation */
    li t0, 1
    la t1, tohost
    sw t0, 0(t1) 
    la t0, _sim_end
    li t1, -1
    sw t1, 0(t0)
dead_loop:
    j dead_loop

/* Fills memory blocks */
fill_block:
    bgeu a0, a1, fb_end
    sw a2, 0(a0)
    addi a0, a0, 4
    j fill_block
fb_end:
    ret