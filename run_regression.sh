#!/bin/bash

TOTAL_LOOPS=2
# 建立存放 coverage 的目錄
mkdir -p build/coverage_db

echo "Starting Regression..."

for (( i=0; i<=TOTAL_LOOPS; i++ ))
do
    echo "Iteration #$i"
    
    # 1. 清除 (只清 build，不與 coverage_db 衝突)
    make clean > /dev/null 2>&1

    # 2. 生成
    make gen_prog

    # 3. 執行 (關鍵：傳入不同的 COV_NAME)
    # 這樣 VCS 會產生 sim/coverage_db/run_1.vdb, run_2.vdb ...
    make rtl_gen COV_NAME=run_$i

    if [ $? -ne 0 ]; then
        echo "[FAIL] Iteration #$i failed"
        exit 1
    fi
done

echo "Regression Done."

# --- [新增] 自動合併 Coverage ---
echo "Merging Coverage..."

# 使用 Synopsys 的 urg 工具合併所有 .vdb
# -dir: 指定要合併的來源資料夾 (所有 run_*.vdb)
# -dbname: 合併後的總資料夾名稱
urg -dir sim/coverage_db/run_*.vdb -dbname sim/coverage_db/merged.vdb -format both -metric line+cond+branch+tgl

echo "Report generated at sim/coverage_db/merged.vdb"