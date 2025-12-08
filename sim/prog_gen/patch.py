import sys
import re
import os

def patch_file(file_path):
    # 檢查檔案是否存在
    if not os.path.exists(file_path):
        print(f"[Error] File not found: {file_path}")
        sys.exit(1)

    print(f"[Patching] Processing {file_path} ...")

    with open(file_path, 'r') as f:
        content = f.read()

    # 1. 修改 Stack 大小: .rept 4999 -> .rept 2000
    # 修正點：使用 \g 而不是 \g
    new_content, n_stack = re.subn(r'(\.rept\s+)4999', r'\g2000', content)
    
    if n_stack > 0:
        print(f"  - Replaced stack size: .rept 4999 -> 2000 ({n_stack} occurrences)")
    else:
        print("  - [Warning] '.rept 4999' not found.")

    # 2. 修改結束指令: ecall -> j SystemExit
    new_content, n_ecall = re.subn(r'\becall\b', 'j SystemExit', new_content)

    if n_ecall > 0:
        print(f"  - Replaced instruction: ecall -> j SystemExit ({n_ecall} occurrences)")
    else:
        print("  - [Warning] 'ecall' instruction not found.")

    # 寫回檔案
    if n_stack > 0 or n_ecall > 0:
        with open(file_path, 'w') as f:
            f.write(new_content)
        print("[Success] Patch applied.")
    else:
        print("[Info] No changes were needed.")

if __name__ == "__main__":
    target_file = sys.argv[1] if len(sys.argv) > 1 else "main.S"
    patch_file(target_file)