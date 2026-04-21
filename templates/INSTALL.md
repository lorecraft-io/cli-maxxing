# Status Line Installation

## Overview

The `statusline.sh` script provides a dynamic status line for Claude Code that displays real-time state for 2ndBrain (Obsidian), FidgetFlo (MCP), UIPro, and any active Swarm/Hive sessions.

## Prerequisites

- `jq` must be installed (`brew install jq` on macOS)
- Claude Code must be installed and configured

## Installation Steps

### 1. Copy the script

```bash
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

### 2. Update Claude Code settings

Edit `~/.claude/settings.json` and add (or update) the `statusline` field:

```json
{
  "statusline": {
    "command": "bash ~/.claude/statusline.sh"
  }
}
```

If the file already has other settings, merge the `statusline` key into the existing JSON object.

### 3. Restart Claude Code

Close and reopen Claude Code for the status line to take effect.

## What It Shows

| Indicator | Meaning |
|-----------|---------|
| 🧠 2ndBrain | Working directory is inside an Obsidian vault (2ndBrain or MASTER) |
| ⚡️ fidgetflo | FidgetFlo MCP server is running |
| 🎨 UIPro | Always shown (global skill, always available) |
| 🐝 Swarm | Active swarm session (with agent count if available) |
| 👑 Hive | Active hive-mind session |
| 🍯 Mini | Active mini swarm session |

## Swarm/Hive Lock Files

The script uses lock files to detect active sessions:

- `/tmp/fidgetflo-swarm-active` — Created when a swarm starts. Contents hold the agent count as a plain integer (e.g., `15`).
- `/tmp/fidgetflo-mini-active` — Created when a mini swarm starts. Contents hold the agent count as a plain integer (e.g., `5`).
- `/tmp/fidgetflo-hive-active` — Created when a hive-mind starts.

Stale lock files (where no matching process is running) are automatically cleaned up by the script.

### Creating lock files from your automation

When starting a swarm:
```bash
echo 15 > /tmp/fidgetflo-swarm-active
```

When starting a mini swarm:
```bash
echo 5 > /tmp/fidgetflo-mini-active
```

When starting a hive-mind:
```bash
touch /tmp/fidgetflo-hive-active
```

When stopping:
```bash
rm -f /tmp/fidgetflo-swarm-active
rm -f /tmp/fidgetflo-mini-active
rm -f /tmp/fidgetflo-hive-active
```

## Troubleshooting

- **Status line not appearing**: Verify `~/.claude/settings.json` has the correct `statusline` config and restart Claude Code.
- **jq errors**: Ensure `jq` is installed: `which jq`
- **Indicators not updating**: The script runs on each prompt. Check that the relevant processes are running with `pgrep -f "fidgetflo"`.
