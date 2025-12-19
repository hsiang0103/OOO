import sys

# 設定顏色代碼
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
RESET = "\033[0m"

def clean_line(line):
    """
    清理行內容：
    1. 去除前後空白
    2. 轉為小寫
    3. 如果是空行或註解，回傳 None
    """
    if not line:
        return None
    line = line.strip()
    if not line or line.startswith("PC") or line.startswith("-") or line.startswith("#"):
        return None
    
    # 移除 Verilog 可能產生的底線
    line = line.replace("_", "")
    return line.lower().split()

def compare_files(rtl_file, gold_file):
    print(f"Comparing {YELLOW}{rtl_file}{RESET} vs {YELLOW}{gold_file}{RESET} ...")
    
    with open(rtl_file, 'r') as f_rtl, open(gold_file, 'r') as f_gold:
        rtl_lines = [clean_line(l) for l in f_rtl.readlines()]
        gold_lines = [clean_line(l) for l in f_gold.readlines()]
        
        # 過濾掉 None
        rtl_lines = [l for l in rtl_lines if l is not None]
        gold_lines = [l for l in gold_lines if l is not None]



        # 2. 逐行比對
        for i, (r, g) in enumerate(zip(rtl_lines, gold_lines)):
            
            # --- 修改重點開始 ---
            # RTL 的 list (r) 最後一個元素是 cycle count，Golden (g) 沒有
            # 使用 slice [:-1] 來忽略 RTL 的最後一個元素
            # 假設 r 的格式是: [PC, (Inst), Type, Addr, Data, CYCLE]
            
            # 防呆：如果 RTL 行長度比 Golden 大，我們才切掉最後一個
            # 這樣如果 RTL 沒印 Cycle 也不會報錯切到資料
            r_to_compare = r[:-1] if len(r) > len(g) else r

            if r_to_compare != g:
                print(f"{RED}[FAIL] Mismatch at line {i+1}{RESET}")
                print(f"Golden: {g}")
                print(f"RTL   : {r}") # 印出原始含有 Cycle 的 RTL，方便除錯
                print(f"CMP   : {r_to_compare} (Cycle ignored)")
                sys.exit(1)
            # --- 修改重點結束 ---
            
                # 1. 檢查基本長度
        if len(rtl_lines) < len(gold_lines):
            print(f"{RED}[FAIL] RTL log stopped earlier than Golden log.{RESET}")
            print(f"RTL lines: {len(rtl_lines)}, Golden lines: {len(gold_lines)}")
            sys.exit(1)

        # 3. 處理 RTL 多出來的尾巴
        if len(rtl_lines) > len(gold_lines):
            extra_lines = rtl_lines[len(gold_lines):]
            print(f"{YELLOW}[INFO] RTL has {len(extra_lines)} extra lines. Analyzing...{RESET}")
            
            if len(extra_lines) > 10:
                print(f"{RED}[FAIL] RTL has too many extra lines ({len(extra_lines)}).{RESET}")
                print(f"First extra line: {extra_lines[0]}")
                sys.exit(1)
            else:
                for l in extra_lines:
                    # 印出忽略的內容時，也可以順便把 Cycle 切掉讓版面好看一點，或者保留皆可
                    print(f"  Ignoring extra RTL commit: {l}") 
                print(f"{YELLOW}[WARN] Ignored {len(extra_lines)} trailing instructions.{RESET}")

    print(f"{GREEN}[PASS] Verification Successful! Logs match.{RESET}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        rtl_log = "rtl_commit.log"
        gold_log = "commit.log"
    else:
        rtl_log = sys.argv[1]
        gold_log = sys.argv[2]
        
    try:
        compare_files(rtl_log, gold_log)
    except FileNotFoundError as e:
        print(f"{RED}Error: File not found - {e.filename}{RESET}")
        sys.exit(1)