#!/usr/bin/env bash

set -euo pipefail

THRESHOLD="${1:-120}"
START_FILE="/tmp/claude_task_start"

START=$(cat "$START_FILE" 2>/dev/null || echo 0)
NOW=$(date +%s)
SECELAPSED=$(( NOW - START ))

if [ "$SECELAPSED" -gt "$THRESHOLD" ]; then
    ELAPSED=$(printf "%02d:%02d:%02d" \
       $((SECELAPSED/3600)) $(((SECELAPSED%3600)/60)) $((SECELAPSED%60)))
    python3 -c "
import socket, sys
msg = 'Task complete in ${ELAPSED}'
try:
    s = socket.socket()
    s.settimeout(2)
    s.connect(('host.docker.internal', 9999))
    s.sendall(msg.encode())
    s.close()
    print('notified user')
except Exception as e:
    print(f'notification failed: {e}', file=sys.stderr)
    print('\a')
"
else
    echo -e "\a"
fi
