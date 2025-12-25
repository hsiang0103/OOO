void boot(void) {
    asm volatile(
        // Descriptor 0: move instruction image from DRAM to IMEM.
        // Descriptor table resides at 0x0002ff00 in DRAM.
        "la t0, _dram_i_start\n\t"      // load _dram_i_start to register
        "la t1, _dram_i_end\n\t"        // load _dram_i_end to register
        "la t2, _imem_start\n\t"        // load _imem_start to register
        "li t3, 0x0002ff00\n\t"         // load 0x0002ff00 to register to fill data
        "sub t1, t1, t0\n\t"            // int LEN = _dram_i_end - _dram_i_start;
        "srli t1, t1, 2\n\t"            // LEN /= 4;
        "addi t1, t1, 1\n\t"            // LEN += 1;
        "sw t0, 0(t3)\n\t"              // store _dram_i_start
        "sw t2, 4(t3)\n\t"              // store _imem_start
        "sw t1, 8(t3)\n\t"              // store LEN
        "addi t4, t3, 20\n\t"           // Descriptor* ptr = Descriptor_list[1];
        "sw t4, 12(t3)\n\t"             // store ptr
        "sw zero, 16(t3)\n\t"           // store EOC (=0)
        
        // Descriptor 1: move small data section from physical DRAM to SRAM.
        "la t0, __sdata_paddr_start\n\t"// load __sdata_paddr_start to register
        "la t1, __sdata_start\n\t"      // load __sdata_start to register
        "la t2, __sdata_end\n\t"        // load __sdata_end to register
        "sub t2, t2, t1\n\t"            // int LEN = __sdata_end - __sdata_start;
        "srli t2, t2, 2\n\t"            // LEN /= 4;
        "addi t2, t2, 1\n\t"            // LEN += 1;
        "sw t0, 20(t3)\n\t"             // store __sdata_paddr_start
        "sw t1, 24(t3)\n\t"             // store __sdata_start
        "sw t2, 28(t3)\n\t"             // store LEN
        "addi t4, t3, 40\n\t"           // Descriptor* ptr = Descriptor_list[2];
        "sw t4, 32(t3)\n\t"             // store ptr
        "sw zero, 36(t3)\n\t"           // store EOC (=0)

        // Descriptor 2: move data section and mark end of chain (EOC = 1).
        "la t0, __data_paddr_start\n\t" // load __data_paddr_start to register          
        "la t1, __data_start\n\t"       // load __data_start to register 
        "la t2, __data_end\n\t"         // load __data_end to register  
        "sub t2, t2, t1\n\t"            // int LEN = __data_end - __data_start;         
        "srli t2, t2, 2\n\t"            // LEN /= 4;
        "addi t2, t2, 1\n\t"            // LEN += 1;
        "sw t0, 40(t3)\n\t"             // store __data_paddr_start
        "sw t1, 44(t3)\n\t"             // store __data_start
        "sw t2, 48(t3)\n\t"             // store LEN
        "sw zero, 52(t3)\n\t"           // Descriptor* ptr = Descriptor_list[1];
        "li t4, 1\n\t"                  // store ptr
        "sw t4, 56(t3)\n\t"             // store EOC (=1)
        
        // Program DMA registers (DESC_BASE @ 0x10020200, DMAEN @ 0x10020100)
        // and wait for interrupt.
        "csrsi mstatus, 0x8\n\t"        // enable global interrupt
        "li t0, 0x800\n\t"              // enable local interrupt
        "csrs mie, t0\n\t"              // 
        "li t1, 0x10020200\n\t"         // 
        "sw t3, 0(t1)\n\t"              // write 0x0002ff00 to DESC_BASE
        "li t1, 0x10020100\n\t"         // 
        "li t2, 1\n\t"                  // 
        "sw t2, 0(t1)\n\t"              // write 0x1 to DMAEN
        "wfi\n\t"                       // waiting for interrupt
        :
        :
        : "t0", "t1", "t2", "t3", "t4", "memory"
    );
}