#!/usr/bin/env bash
set -euo pipefail

FACTORY="${1:-}"
FACTORYFOLDER="${2:-}"
GITREPO="${3:-}"

if [[ -z "$FACTORY" || -z "$FACTORYFOLDER" ]]; then
  echo "Usage: $0 <factory-name> <factory-folder> [git-repo]"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$SCRIPT_DIR/factory-base"
FACTORYFOLDER="$(mkdir -p "$FACTORYFOLDER" && cd "$FACTORYFOLDER" && pwd)"
PRIVATE_DIR="$FACTORYFOLDER/private-agent-instructions"
SRC_DIR="$FACTORYFOLDER/src"

if [[ ! -d "$BASE_DIR" ]]; then
  echo "Error: factory-base directory not found at: $BASE_DIR"
  exit 1
fi

mkdir -p "$PRIVATE_DIR"
cp -r "$BASE_DIR"/. "$FACTORYFOLDER"/

cd "$FACTORYFOLDER"

for file in power-claude settings.example.json notify-user.sh; do
    mv "$file" "$PRIVATE_DIR"/
done

{
  echo "COMPOSE_PROJECT_NAME=$FACTORY"
} > "$FACTORYFOLDER/.env"

if [[ -n "$GITREPO" ]]; then
  git clone "$GITREPO" "$SRC_DIR"
else
  mkdir -p "$SRC_DIR"
fi

cat <<EOF
Factory '$FACTORY' created successfully.

cd $FACTORYFOLDER
and start working...

To enter the dev machine, run:
  ./go.sh

It will start one if it is not running yet.

Inside the dev machine (one time only):
  1. Install any global dependencies you need
     Example: pip install -r requirements.txt

  2. Start Claude with:
     /private-agent-instructions/power-claude

  3. In Claude: "Install Trycycle by following the instructions here:
     https://raw.githubusercontent.com/danshapiro/trycycle/main/README.md"

Note: notifications are set up automatically on first entry via go.sh.

Enjoy!
EOF

