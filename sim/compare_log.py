import sys

# 設定顏色代碼，讓輸出更明顯
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
RESET = "\033[0m"

def clean_line(line):
    """
    清理行內容：
    1. 去除前後空白
    2. 將連續空白縮減為單一空格 (split + join)
    3. 轉為小寫 (忽略 hex 大小寫差異)
    """
    # 如果是分隔線或標頭，回傳 None 讓主迴圈跳過
    if line.strip().startswith("PC") or line.strip().startswith("-"):
        return None
    
    # 移除 Verilog 可能產生的底線 (例如 0000_1234 -> 00001234)
    line = line.replace("_", "")
    
    return line.strip().lower().split()

def compare_files(rtl_file, gold_file):
    print(f"Comparing {YELLOW}{rtl_file}{RESET} vs {YELLOW}{gold_file}{RESET} ...")
    
    with open(rtl_file, 'r') as f_rtl, open(gold_file, 'r') as f_gold:
        line_num = 0
        
        while True:
            # 同時讀取兩份檔案
            raw_rtl = f_rtl.readline()
            raw_gold = f_gold.readline()
            
            # 兩份都讀完了 -> PASS
            if not raw_rtl and not raw_gold:
                break
            
            line_num += 1
            
            # 清理並正規化內容
            rtl_parts = clean_line(raw_rtl)
            gold_parts = clean_line(raw_gold)
            
            # 如果是標頭或空行，跳過不比對
            if rtl_parts is None:
                # 為了保持行號同步，這裡稍微簡單處理，
                # 假設 RTL 沒有標頭，只有 Golden 有，
                # 實際情況可能需要更複雜的游標控制。
                # 但針對你的 case，我們假設兩邊都是純數據或都有標頭。
                # 如果只有一邊有標頭，建議在 clean_line 回傳 None 時不要增加 line_num
                # 但這裡我們先簡單處理：如果是 None 就讀下一行
                continue
            
            if gold_parts is None:
                continue

            # 檢查是否有一邊提早結束
            if not raw_rtl and raw_gold:
                print(f"{RED}[FAIL] RTL log ended earlier than Golden log at line {line_num}{RESET}")
                sys.exit(1)
            if raw_rtl and not raw_gold:
                print(f"{RED}[FAIL] Golden log ended earlier than RTL log at line {line_num}{RESET}")
                sys.exit(1)

            # --- 核心比對邏輯 ---
            if rtl_parts != gold_parts:
                print(f"{RED}[FAIL] Mismatch detected at line {line_num}{RESET}")
                print("-" * 40)
                print(f"Golden: {raw_gold.strip()}")
                print(f"RTL   : {raw_rtl.strip()}")
                print("-" * 40)
                
                # 找出具體是哪個欄位錯了
                for i, (r, g) in enumerate(zip(rtl_parts, gold_parts)):
                    if r != g:
                        print(f"Diff at token #{i+1}: Exp '{g}', Got '{r}'")
                
                sys.exit(1) # 回傳錯誤碼 1

    print(f"{GREEN}[PASS] Verification Successful! Logs match perfectly.{RESET}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 compare_log.py <rtl_log> <golden_log>")
        # 預設行為 (方便你直接跑)
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