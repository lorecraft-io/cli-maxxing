# Claude Code Cheat Sheet

## Terminal Basics (Read This First)

The terminal works differently from a normal text editor or document. Here's what you need to know:

**Typing and editing:**
- You type commands at the blinking cursor and press **Enter** to run them
- You **can't click** to place your cursor in the middle of a line (Warp lets you do this, but most terminals don't)
- **Highlight and delete doesn't work** — forget what you know from Google Docs or Excel
- **Backspace** deletes one character at a time (that still works normally)
- **Ctrl+U** clears the entire line — this is your best friend when you mess up a command

**Moving around:**
- **Left/Right arrows** move your cursor within the line you're typing
- **Up arrow** brings back the last command you ran (press it again for the one before that)
- **Down arrow** goes forward through your command history

**Important keys:**
- **Ctrl+C** stops whatever is currently running (note: **Ctrl**, not Cmd on Mac)
- **Enter** confirms and runs a command
- **Tab** tries to auto-complete file names and commands

**When the terminal asks you something:**
- `[y/n]` means type **y** for yes or **n** for no, then press Enter
- `Press ENTER to continue` means just hit Enter
- If something looks stuck, try pressing Enter — it might be waiting for you

---

## Launching Claude

| Command | What it does |
|---------|-------------|
| `claude` | Normal mode — asks permission before each action |
| `cskip` | Auto-approve mode — runs without asking (faster) |

To switch modes: type `/exit` to quit, then relaunch with the other command.

## What is auto-approve mode?

`cskip` runs `claude --dangerously-skip-permissions`. This tells Claude to execute commands, edit files, and make changes without asking you first. It's faster for setup scripts and guided sessions. Use normal mode (`claude`) when you want to review each action before it happens.

**Warp Terminal bonus:** If you use Warp, press `Shift+Tab` inside a Claude session to toggle permissions on/off without restarting.

## Inside a Claude Session

| Command | What it does |
|---------|-------------|
| `/exit` | Quit Claude |
| `/help` | Show all available commands |
| `/permissions` | Check current permission settings |
| `/clear` | Clear the conversation |
| `/compact` | Summarize conversation to save context |
| `!command` | Run a shell command without leaving Claude |

## When Claude Asks for Permission

In normal mode, Claude will ask before doing things like editing a file or running a command. You'll see a prompt — type **y** and hit Enter to approve, or **n** to deny. In `cskip` mode or with Shift+Tab on in Warp, this is skipped entirely.

## Tips

- Claude remembers context within a session. If it's getting confused, use `/compact` to reset.
- You can paste file paths, URLs, and error messages directly — Claude will read and understand them.
- To start fresh, just exit and relaunch.
