ELF_NAME := main

export CROSS_PREFIX ?= riscv64-unknown-elf-
export RISCV_GCC ?= $(CROSS_PREFIX)gcc
export RISCV_OBJDUMP ?= $(CROSS_PREFIX)objdump -xsd
export RISCV_OBJCOPY ?= $(CROSS_PREFIX)objcopy

LDFILE := link.ld
CFLAGS := -march=rv32imf -mabi=ilp32
LDFLAGS := -static -nostdlib -nostartfiles -march=rv32imf -mabi=ilp32 -T$(LDFILE) -lgcc

SRC_C := $(wildcard *.c)
OBJ_C := $(patsubst %.c,%.o,$(SRC_C))
SRC_S := $(wildcard *.S)
OBJ_S := $(patsubst %.S,%.o,$(SRC_S))
SRC := $(SRC_C) $(SRC_S)
OBJ := $(OBJ_C) $(OBJ_S)

.SUFFIXES: .o .S .c

.PHONY: all clean build_elf build_log build_hex run_spike

all: build_elf build_log build_hex run_spike

build_elf: $(OBJ) | $(LDFILE)
	$(RISCV_GCC) $^ $(LDFLAGS) -o $(ELF_NAME).elf

build_log: $(ELF_NAME).elf
	$(RISCV_OBJDUMP) $< > $(ELF_NAME).log

build_hex: $(ELF_NAME).elf
	$(RISCV_OBJCOPY) -O verilog $< -i 4 -b 0 -j .text0 --change-addresses 0 rom0.hex
	$(RISCV_OBJCOPY) -O verilog $< -i 4 -b 1 -j .text0 --change-addresses 0 rom1.hex
	$(RISCV_OBJCOPY) -O verilog $< -i 4 -b 2 -j .text0 --change-addresses 0 rom2.hex
	$(RISCV_OBJCOPY) -O verilog $< -i 4 -b 3 -j .text0 --change-addresses 0 rom3.hex
	$(RISCV_OBJCOPY) -O verilog $< -i 4 -b 0 -R .text0 --change-addresses -0x20000000 dram0.hex
	$(RISCV_OBJCOPY) -O verilog $< -i 4 -b 1 -R .text0 --change-addresses -0x20000000 dram1.hex
	$(RISCV_OBJCOPY) -O verilog $< -i 4 -b 2 -R .text0 --change-addresses -0x20000000 dram2.hex
	$(RISCV_OBJCOPY) -O verilog $< -i 4 -b 3 -R .text0 --change-addresses -0x20000000 dram3.hex

#run_spike: $(ELF_NAME).elf
#	spike --isa=rv32imf -m0x2000:0x2000,0x10000:0x20000,0x20000000:0x1000000 --log-commits -l $< > golden.log 2>&1
#	python3 gen_commit_log.py golden.log

%.o: %.S
	$(RISCV_GCC) -c $(CFLAGS) $^

%.o: %.c
	$(RISCV_GCC) -c $(CFLAGS) $^

clean:
	rm -rf $(ELF_NAME) *.log rom*.hex  dram*.hex *.o *.elf golden.log commit.log