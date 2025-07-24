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
        exec mitmdump -p 23410 --mode upstream:http://akagi:7880 -s addons.py --ssl-insecure
        ;;
    *)
        exec "$@"
        ;;
esac