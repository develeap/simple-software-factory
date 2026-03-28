#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Stopping dev container..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" down

echo "Stopping notification listener..."
pkill -f "listen-notifications.py" 2>/dev/null && echo "Listener stopped." || echo "Listener was not running."
