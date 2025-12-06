ELF_NAME := main

export CROSS_PREFIX ?= riscv64-unknown-elf-
export RISCV_GCC ?= $(CROSS_PREFIX)gcc
export RISCV_OBJDUMP ?= $(CROSS_PREFIX)objdump -xsd
export RISCV_OBJCOPY ?= $(CROSS_PREFIX)objcopy -O verilog

LDFILE := link.ld
# 假設 riscv-dv 的路徑 (請根據你的實際路徑調整，如果是在上三層)
RISCV_DV_ROOT ?= $(PWD)/../../riscv-dv
CFLAGS := -march=rv32imf -mabi=ilp32 -I$(RISCV_DV_ROOT)/user_extension -I$(RISCV_DV_ROOT)/test/riscv_test_lib/asm
LDFLAGS := -static -nostdlib -nostartfiles -march=rv32imf -mabi=ilp32 -T$(LDFILE) -lgcc

# --- [修改 1] 定義檔案來源 ---
# 1. riscv-dv 生成的原始檔 (假設你 copy 過來後叫 main.S)
GEN_SRC := main.S
# 2. 修補後的檔案 (我們要編譯這個)
PATCHED_SRC := main_patched.S
# 3. 你自己的啟動檔
USER_SRC := setup.S

SRC_C := $(wildcard *.c)
OBJ_C := $(patsubst %.c,%.o,$(SRC_C))

# --- [修改 2] 組合 Assembly Objects ---
# Object 包含：你的 C, 你的 setup.o, 以及 修補後的 main_patched.o
SRC_S := $(USER_SRC) $(PATCHED_SRC)
OBJ_S := $(SRC_S:.S=.o)

OBJ := $(OBJ_C) $(OBJ_S)

.SUFFIXES: .o .S .c

.PHONY: all clean build_elf build_log build_hex run_spike

all: build_elf build_log build_hex run_spike

$(PATCHED_SRC): $(GEN_SRC)
	cp $(GEN_SRC) $@
	@echo "Patching $(GEN_SRC) to fix symbols, shrink stack, and remove ecall..."
	
	# 1. [符號修正]
	sed -i 's/.globl _start//g' $@
	sed -i 's/_start:/_rv_gen_start:/g' $@
	sed -i 's/.*\.global tohost.*//g' $@
	sed -i 's/tohost: .dword 0//g' $@
	sed -i 's/.*\.global fromhost.*//g' $@
	sed -i 's/fromhost: .dword 0//g' $@
	sed -i '1i .globl init' $@
	
	# 2. [移除舊啟動碼]
	sed -i 's/la x31, h0_start/nop/g' $@
	sed -i 's/jalr x0, x31, 0/nop/g' $@

	# 3. [Stack 瘦身]
	sed -i 's/.rept [0-9]\{3,\}/.rept 128/g' $@

	# 4. [修正] 精確替換 ecall 指令 (使用 \< \> 標示單字邊界)
	# 這會匹配 "ecall" 但不會匹配 "ecall_handler"
	sed -i 's/\<ecall\>/j SystemExit/g' $@

build_elf: $(OBJ) | $(LDFILE)
	$(RISCV_GCC) $^ $(LDFLAGS) -o $(ELF_NAME).elf

build_log: $(ELF_NAME).elf
	$(RISCV_OBJDUMP) $< > $(ELF_NAME).log

build_hex: $(ELF_NAME).elf
	$(RISCV_OBJCOPY) $< -i 4 -b 0 $(ELF_NAME)0.hex
	$(RISCV_OBJCOPY) $< -i 4 -b 1 $(ELF_NAME)1.hex
	$(RISCV_OBJCOPY) $< -i 4 -b 2 $(ELF_NAME)2.hex
	$(RISCV_OBJCOPY) $< -i 4 -b 3 $(ELF_NAME)3.hex

run_spike: $(ELF_NAME).elf
	spike --isa=rv32imf -m0x2000:0xE000 --log-commits -l $< > golden.log 2>&1
	python3 gen_commit_log.py golden.log

%.o: %.S
	$(RISCV_GCC) -c $(CFLAGS) $^ -o $@

%.o: %.c
	$(RISCV_GCC) -c $(CFLAGS) $^ -o $@

clean:
	rm -rf $(ELF_NAME) *.log $(ELF_NAME)*.hex *.o *.elf golden.log commit.log $(PATCHED_SRC)