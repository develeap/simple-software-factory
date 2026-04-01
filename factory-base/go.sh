#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DC="docker compose -f $SCRIPT_DIR/docker-compose.yml"

if ! $DC ps dev | grep -q "running"; then
  echo "Starting dev container..."
  $DC up -d
fi

U=$(id -u)
G=$(id -g)

"$SCRIPT_DIR/listen-notifications.sh"

# First-time setup: copy example settings if none exist yet
$DC exec --workdir /workspace --user $U:$G dev bash -c \
  '[ -f ~/.claude/settings.json ] || { mkdir -p ~/.claude && cp /private-agent-instructions/settings.example.json ~/.claude/settings.json && echo "Installed Claude settings (notifications enabled)."; }'

echo "To start Claude: /private-agent-instructions/power-claude"
echo "We strongly recommend that you use trycycle and superpowers for long running tasks."
exec $DC exec --workdir /workspace --user $U:$G dev bash
