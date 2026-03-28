#!/usr/bin/env bash
# Customize this script for your OS and notification preferences.
# Called by listen-notifications.py with the message as the first argument.

MESSAGE="${1:-Claude task complete}"

case "$(uname)" in
  Darwin)
    osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\""
    ;;
  Linux)
    notify-send "Claude Code" "$MESSAGE"
    ;;
  *)
    echo "Claude Code: $MESSAGE" >&2
    ;;
esac
