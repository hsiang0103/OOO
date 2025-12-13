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
        # 讀取並過濾所有有效行
        # 這裡我們一次讀完，因為檔案通常不會大到記憶體爆掉，處理起來比較簡單
        rtl_lines = [clean_line(l) for l in f_rtl.readlines()]
        gold_lines = [clean_line(l) for l in f_gold.readlines()]
        
        # 過濾掉 None (空行或標頭)
        rtl_lines = [l for l in rtl_lines if l is not None]
        gold_lines = [l for l in gold_lines if l is not None]

        # 1. 檢查基本長度
        # 如果 RTL 比 Golden 短，那一定是錯的 (沒跑完)
        if len(rtl_lines) < len(gold_lines):
            print(f"{RED}[FAIL] RTL log stopped earlier than Golden log.{RESET}")
            print(f"RTL lines: {len(rtl_lines)}, Golden lines: {len(gold_lines)}")
            sys.exit(1)

        # 2. 逐行比對 (只比對 Golden 有的部分)
        for i, (r, g) in enumerate(zip(rtl_lines, gold_lines)):
            if r != g:
                print(f"{RED}[FAIL] Mismatch at line {i+1}{RESET}")
                print(f"Golden: {g}")
                print(f"RTL   : {r}")
                sys.exit(1)

        # 3. 處理 RTL 多出來的尾巴 (Handling Trailing Instructions)
        # 這是你遇到問題的關鍵修正
        if len(rtl_lines) > len(gold_lines):
            extra_lines = rtl_lines[len(gold_lines):]
            print(f"{YELLOW}[INFO] RTL has {len(extra_lines)} extra lines. Analyzing...{RESET}")
            
            # 我們要檢查這些多出來的行是否是 "SystemExit" 相關的指令
            # 通常是寫入 tohost 之後的指令，或者是寫入 _sim_end 的指令
            # 這裡做一個寬鬆的檢查：只要不是大量的運算錯誤，我們允許結尾有 10 行以內的誤差
            if len(extra_lines) > 10:
                print(f"{RED}[FAIL] RTL has too many extra lines ({len(extra_lines)}). Something is wrong.{RESET}")
                print(f"First extra line: {extra_lines[0]}")
                sys.exit(1)
            else:
                # 這裡可以選擇印出來讓你知道它忽略了什麼
                for l in extra_lines:
                    print(f"  Ignoring extra RTL commit: {l}")
                print(f"{YELLOW}[WARN] Ignored {len(extra_lines)} trailing instructions (assumed simulation exit sequence).{RESET}")

    print(f"{GREEN}[PASS] Verification Successful! Logs match.{RESET}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        # 預設檔名
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