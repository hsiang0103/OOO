import sys
import re

def parse_and_convert(input_file, output_file):
    # Regex 用來匹配 Spike Log
    re_base = re.compile(r"core\s+\d+:\s+\d\s+(0x[0-9a-fA-F]+)\s+\((0x[0-9a-fA-F]+)\)")
    re_reg = re.compile(r"\s+([xf])(\d+)\s+(0x[0-9a-fA-F]+)")
    re_mem = re.compile(r"mem\s+(0x[0-9a-fA-F]+)(?:\s+(0x[0-9a-fA-F]+))?")

    with open(input_file, 'r') as fin, open(output_file, 'w') as fout:
        for line in fin:
            line = line.strip()
            
            # 抓取 PC 和 指令
            match_base = re_base.search(line)
            if not match_base:
                continue

            pc_str = match_base.group(1)
            inst_str = match_base.group(2)
            
            # --- [新增功能] 過濾 Boot ROM ---
            # 將 Hex 字串轉成整數進行比較
            if int(pc_str, 16) < 0x2000:
                continue
            
            # --- 判斷邏輯 ---
            match_mem = re_mem.search(line)
            match_reg = re_reg.search(line)
            
            output_line = None

            # 1. 處理 Memory Write (Store)
            if match_mem and match_mem.group(2): 
                addr = match_mem.group(1)
                data = match_mem.group(2)
                output_line = f"{pc_str} ({inst_str}) mem {addr} {data}"
            
            # 2. 處理 Register Write (ALU 或 Load)
            elif match_reg:
                reg_prefix = match_reg.group(1)
                reg_num = int(match_reg.group(2))
                reg_val = match_reg.group(3)

                # 執行映射: x0-x31 保持, f0-f31 -> 32-63
                final_idx = reg_num
                if reg_prefix == 'f':
                    final_idx = reg_num + 32
                
                output_line = f"{pc_str} ({inst_str}) x{final_idx:<2} {reg_val}"

            # 3. 如果都不是 (例如 Branch)，這裡選擇跳過，不印出
            
            if output_line:
                fout.write(output_line + "\n")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 gen_custom_log.py <golden.log>")
        sys.exit(1)
    
    input_log = sys.argv[1]
    parse_and_convert(input_log, "commit.log")
    print(f"Converted {input_log} to commit.log (Start from PC 0x2000)")