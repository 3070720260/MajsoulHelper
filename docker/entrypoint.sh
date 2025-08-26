#!/bin/bash
set -e

case "$1" in
    akagi)
        echo "Starting Akagi..."
        cd /app/Akagi
        exec python3 run_akagi.py
        ;;
    majsoulmax)
        echo "Starting MajsoulMax..."
        cd /app/MajsoulMax
        # 获取 upstream 环境变量，默认 http://akagi:7880
        upstream=${UPSTREAM:-http://akagi:7880}
        exec mitmdump -p 23410 --mode upstream:"$upstream" -s addons.py --ssl-insecure --set block_global=false
        ;;
    *)
        exec "$@"
        ;;
esac
