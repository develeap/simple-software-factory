#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! docker compose -f "$SCRIPT_DIR/docker-compose.yml" ps dev | grep -q "running"; then
  echo "Starting dev container..."
  docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d
fi

U=$(id -u)
G=$(id -g)

"$SCRIPT_DIR/listen-notifications.sh"

# Load COMPOSE_PROJECT_NAME from .env
source "$SCRIPT_DIR/.env"
CONTAINER="${COMPOSE_PROJECT_NAME}-dev"

# First-time setup: copy example settings if none exist yet
docker exec --workdir /workspace --user $U:$G "$CONTAINER" bash -c \
  '[ -f ~/.claude/settings.json ] || { mkdir -p ~/.claude && cp /private-agent-instructions/settings.example.json ~/.claude/settings.json && echo "Installed Claude settings (notifications enabled)."; }'

echo "To start Claude: /private-agent-instructions/power-claude"
echo "To use trycycle: \"Use trycycle in order to...\""
exec docker exec --workdir /workspace --user $U:$G "$CONTAINER" bash
