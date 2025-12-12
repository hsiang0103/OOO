ELF_NAME := main

export CROSS_PREFIX ?= riscv64-unknown-elf-
export RISCV_GCC ?= $(CROSS_PREFIX)gcc
export RISCV_OBJDUMP ?= $(CROSS_PREFIX)objdump -xsd
export RISCV_OBJCOPY ?= $(CROSS_PREFIX)objcopy

RISCV_DV_ROOT ?= $(CURDIR)/../../riscv-dv

LDFILE := link.ld
CFLAGS := -march=rv32imf -mabi=ilp32 -I$(RISCV_DV_ROOT)/user_extension -I$(RISCV_DV_ROOT)/test/riscv_test_lib/asm
LDFLAGS := -static -nostdlib -nostartfiles -march=rv32imf -mabi=ilp32 -T$(LDFILE) -lgcc

SRC_C := $(wildcard *.c)
OBJ_C := $(patsubst %.c,%.o,$(SRC_C))
SRC_S := $(wildcard *.S)
OBJ_S := $(patsubst %.S,%.o,$(SRC_S))
SRC := $(SRC_C) $(SRC_S)
OBJ := $(OBJ_C) $(OBJ_S)

.SUFFIXES: .o .S .c

.PHONY: all clean build_elf build_log build_hex run_spike

all: patch build_elf build_log build_hex run_spike

fix_main: 
	
patch:
	sed -i 's/\becall\b/j SystemExit/g' main.S

build_elf: $(OBJ) | $(LDFILE)
	$(RISCV_GCC) $^ $(LDFLAGS) -o $(ELF_NAME).elf

build_log: $(ELF_NAME).elf
	$(RISCV_OBJDUMP) $< > $(ELF_NAME).log

build_hex: $(ELF_NAME).elf
	$(RISCV_OBJCOPY) -O verilog $< -i 4 -b 0 $(ELF_NAME)0.hex
	$(RISCV_OBJCOPY) -O verilog $< -i 4 -b 1 $(ELF_NAME)1.hex
	$(RISCV_OBJCOPY) -O verilog $< -i 4 -b 2 $(ELF_NAME)2.hex
	$(RISCV_OBJCOPY) -O verilog $< -i 4 -b 3 $(ELF_NAME)3.hex

run_spike: $(ELF_NAME).elf
	spike --isa=rv32imf -m0x2000:0xE000 --log-commits -l $< > golden.log 2>&1
	python3 gen_commit_log.py golden.log

%.o: %.S
	$(RISCV_GCC) -c $(CFLAGS) $^

%.o: %.c
	$(RISCV_GCC) -c $(CFLAGS) $^

clean:
	rm -rf $(ELF_NAME) *.log $(ELF_NAME)*.hex *.o *.elf golden.log commit.log asm_test/ spike_sim/ vcs_simv.daidir/ vcs_simv vc_hdrs.h seed.yaml vcs_simv.csrc/ compile.log
	rm -rf main.S