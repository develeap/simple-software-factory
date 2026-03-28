#!/usr/bin/env bash
# Starts the host-side notification listener in the background.
# Safe to call multiple times — skips if our listener is already running.
# If something else holds the port, kills it first.

PORT=9999
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE="/tmp/claude-notify-listener.log"

if pgrep -f "listen-notifications.py" > /dev/null 2>&1; then
    echo "Notification listener already running on port $PORT."
    exit 0
fi

# Something else is on the port — clear it before binding.
BLOCKING_PID=$(ss -tlnp "sport = :$PORT" 2>/dev/null | grep -oP 'pid=\K[0-9]+' | head -1)
if [[ -n "$BLOCKING_PID" ]]; then
    echo "Killing stale process $BLOCKING_PID on port $PORT..."
    kill "$BLOCKING_PID" 2>/dev/null || true
    sleep 0.5
fi

echo "Starting notification listener on port $PORT..."
nohup python3 "$SCRIPT_DIR/listen-notifications.py" "$SCRIPT_DIR/notify.sh" "$PORT" \
    > "$LOGFILE" 2>&1 &
disown
echo "Listener started. Log: $LOGFILE"
