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
    server)
        echo "Starting Frontend Serve..."
        cd /app/AkagiFrontend
        exec bun run serve
        ;;
    frontend)
        echo "Starting Frontend Preview..."
        cd /app/AkagiFrontend
        exec bun run preview --port 4173 --host 0.0.0.0
        ;;
    *)
        exec "$@"
        ;;
esac