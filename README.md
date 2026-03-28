# Simple Factory

One command to bootstrap an isolated Claude Code session — Docker-based, persistent, with desktop notifications when long tasks finish.

This is a starting point, not a complete solution. Once you outgrow it, customize freely.

## What you get

- A Docker container with Claude Code pre-installed
- Your project code mounted at `/workspace` inside the container
- Claude's home directory persisted in a named volume (memory and settings survive restarts)
- Desktop notifications when Claude finishes a task that took more than ~90 seconds
- A `private-agent-instructions/` folder visible to Claude but hidden from your project

## Prerequisites

- Docker with Compose plugin
- Linux desktop with `notify-send` (part of `libnotify-bin`)
- [Superpowers](https://github.com/anthropics/claude-code) or equivalent skills installed for `power-claude` to be useful

## Quick start

```bash
# Create a factory folder (optionally clone a git repo into src/)
./create-factory.sh my-project ~/factories/my-project
./create-factory.sh my-project ~/factories/my-project https://github.com/you/your-repo

# Enter the container (starts it if needed)
cd ~/factories/my-project
./go.sh

# If you are done with the project and want to shut down all processes. 
# For long running projects this is seldom used. 
./stop.sh
```

Inside the container, one-time setup:

```bash
# Enable notifications on task completion
cp /private-agent-instructions/settings.example.json ~/.claude/settings.json

# Start Claude with full tool permissions
/private-agent-instructions/power-claude
```

## Structure

```
my-project/
├── go.sh                         # Start container and enter it
├── stop.sh                       # Stop container and notification listener
├── docker-compose.yml
├── dockerfile.dev
├── src/                          # Your project code → /workspace in container
└── private-agent-instructions/   # Visible to Claude via --add-dir, not part of src
    ├── power-claude              # Launches Claude (skip-permissions + add-dir)
    ├── notify-user.sh            # Sends desktop notification after long tasks
    └── settings.example.json     # Hook config: copy to ~/.claude/settings.json
```

## Commands

### `go.sh`

Starts the container if it isn't running, then opens a shell inside it. On first run, installs Claude settings from `settings.example.json` (enabling notifications). Also starts the host-side notification listener if it isn't already running.

```bash
./go.sh
```

### `stop.sh`

Stops the Docker container and shuts down the notification listener on the host.

```bash
./stop.sh
```

## How notifications work

`settings.example.json` configures two Claude hooks:

- **UserPromptSubmit** — records a timestamp when you submit a prompt
- **Stop** — calls `notify-user.sh`, which sends a desktop notification if the task took longer than 90 seconds, or just beeps otherwise

## Where to go next

Once you're comfortable here:
- Customize `dockerfile.dev` to match your actual stack (e.g. remove Playwright if you don't need it)
- Install [Trycycle](https://github.com/danshapiro/trycycle) or [SuperPowers](https://github.com/obra/superpowers) inside the container for long autonomous runs
- Add agent instructions in `private-agent-instructions/CLAUDE.md`
- Add a `CLAUDE.md` to `src/` to give Claude project-specific context which you want shared
- Change the notification method to something else that fits your need, e.g. `aplay "tada.mp3"`

## Operating System

This project was developed and tested on Ubuntu.
To adapt to Mac I believe you need to change the following. Fork and let me know once tested and works:

| File | What to change |
|---|---|
| `notify.sh` | Already handles macOS via `osascript` — no change needed |
| `Prerequisites` | Replace `libnotify-bin` / `notify-send` with nothing (macOS has it built in) |
| `docker-compose.yml` | Remove `DISPLAY` env var (not used on macOS) |
| `listen-notifications.sh` | `ss` may not be available — replace with `lsof -ti tcp:$PORT` to find blocking PIDs |

To adapt to Windows (WSL) I believe you need to change the following. Fork and let me know once tested and works:

| File | What to change |
|---|---|
| `notify.sh` | Replace `notify-send` with a `powershell.exe` toast notification call |
| `listen-notifications.sh` | `ss` and `pkill` behave differently in WSL — test and adjust the stale-process cleanup |
| `go.sh` | `id -u` / `id -g` may return WSL-specific IDs that don't map cleanly into the container |
| `docker-compose.yml` | Remove `DISPLAY` env var unless you have an X server (e.g. VcXsrv) configured |
