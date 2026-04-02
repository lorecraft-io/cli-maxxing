# Claude Code Cheat Sheet

## Terminal Basics (Read This First)

The terminal works differently from a normal text editor or document. Here's what you need to know:

**Typing and editing:**
- You type commands at the blinking cursor and press **Enter** to run them
- You **can't click** to place your cursor in the middle of a line — the terminal isn't a text editor
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

## Shell Commands (installed by Step 1)

These aliases are added to your `~/.zshrc` (or `~/.bashrc`) and available in any terminal session.

| Command | What it does |
|---------|-------------|
| `claude` | Normal mode — asks permission before each action |
| `cskip` | Launch Claude Code with all permissions skipped (`claude --dangerously-skip-permissions`) |
| `cc` | Short alias for `claude` |
| `ccr` | Resume last Claude conversation (`claude --resume`) |
| `ccc` | Continue last Claude conversation (`claude --continue`) |
| `cbrain` | Launch Claude Code in your 2ndBrain vault with skip-permissions *(requires Obsidian — Step 6)* |
| `cbraintg` | Same as `cbrain` but with Telegram channel connected |
| `ctg` | Skip-permissions + Telegram channel connected (any directory) |
| `g2` | Tile 2 Ghostty windows side by side, filling your screen *(requires Ghostty — Bonus step, macOS only)* |
| `g4` | Tile 4 Ghostty windows in a 2x2 grid *(requires Ghostty — Bonus step, macOS only)* |

> **Tip:** After running any setup script, run `source ~/.zshrc` to activate new commands. The scripts do this automatically, but just in case.
>
> **Note:** Until you set up Second Brain (Step 6), use `cskip` instead of `cbrain`. The `cbrain` command requires an Obsidian vault to exist — if you haven't created one yet, it will error. Everything else works right away with `cskip`.

## What is auto-approve mode?

`cskip` runs `claude --dangerously-skip-permissions`. This tells Claude to execute commands, edit files, and make changes without asking you first. It's faster for setup scripts and guided sessions. Use normal mode (`claude`) when you want to review each action before it happens.

**Tip:** Press `Shift+Tab` inside a Claude session to toggle permissions on/off without restarting.

---

## Terminal Hotkeys

These work inside your terminal when a Claude session is active.

| Hotkey | What it does |
|--------|-------------|
| **Shift+Tab** | Toggle auto-approve permissions on/off without restarting Claude |
| **Ctrl+C** | Stop whatever is running, exit Claude, or clear everything you've typed in the input box |
| **Ctrl+U** | Clear the entire line you are typing |
| **Up Arrow** | Recall previous command from history |
| **Tab** | Auto-complete file names and commands |

---

## Inside a Claude Session

| Command | What it does |
|---------|-------------|
| `/exit` | Quit Claude |
| `/help` | Show all available commands |
| `/permissions` | Check current permission settings |
| `/clear` | Clear the conversation |
| `/compact` | Summarize conversation to save context window |
| `/voice` | Enable voice input mode |
| `!command` | Run a shell command without leaving Claude (e.g., `!ls`) |

---

## Claude Code Skills (slash commands)

These are custom skills installed by the setup scripts. Type them inside a Claude session.

| Command | Installed in | What it does |
|---------|-------------|-------------|
| `/rswarm do the thing` | Step 3 | Launch a 15-agent swarm — just describe what you want in plain English after `/rswarm` |
| `/rhive <goal>` | Step 3 | Launch a queen-led autonomous hive-mind with raft consensus |
| `/w4w` | Step 3 | Maximum attention to detail — word for word, line for line. No skipping, no summarizing. Also works without the slash — just type `w4w` |
| `/pretext <request>` | Step 4 | Text measurement and layout via @chenglou/pretext |

> These are **explicit triggers** — you type the command to activate the skill. This is different from the auto-triggered tools below, which respond to natural language. Exception: `/w4w` also works without the slash — just type `w4w` anywhere in your message.

---

## Auto-Triggered Tools (natural language — no command needed)

These activate on their own when Claude detects a relevant task via natural language. You never type a command — just describe what you want and Claude picks up the right tool.

| Tool | Installed in | How it activates | Example prompt |
|------|-------------|-----------------|----------------|
| UI/UX Pro Max | Step 4 | Natural language — asks about UI, design, layouts, interfaces | "Build me a dashboard with a sidebar" |
| 21st.dev Magic | Step 4 | Natural language — building components, pulls from 21st.dev library | "Create a hero section with a CTA" |
| Context Hub | Step 3 | Natural language — Claude writes code that calls external APIs | "Use the Stripe API to create a checkout" |
| Remotion | Step 5 | Natural language — video, animation, motion graphics | "Make a 30-second intro video" |
| YouTube Transcripts | Step 5 | Natural language — paste a YouTube link and ask for the transcript | "Get the transcript of this video: https://youtube.com/..." |
| IG/Social Transcription | Step 5 | Natural language — paste an Instagram, TikTok, or social media link | "Transcribe this reel: https://instagram.com/reel/..." |
| Motion Calendar | Step 7 | Natural language — calendar, schedule, availability, events | "What's on my calendar today?" |
| Notion | Step 7 | Natural language — pages, databases, knowledge management | "Search my Notion for the meeting notes" |
| No-Flicker Mode | Step 2 | Automatic — fullscreen rendering, no screen jumping while Claude works | (always on — set via environment variable) |
| Memory Hook | Step 2 | Automatic on session end — saves context from the conversation | (no prompt needed — runs automatically) |
| Obsidian | Step 6 | Natural language — anything about notes, vault, search, or knowledge management | "Search my vault for notes about machine learning" |
| Canva | Add-on | Natural language — create or edit designs, social posts, presentations | "Design a social media post for our launch" |
| Figma | Add-on | Natural language or paste a Figma URL — design-to-code, inspect designs | "Turn this Figma into React components" |
| Excalidraw | Add-on | Natural language — diagrams, flowcharts, whiteboard sketches | "Draw a system architecture diagram" |
| Gamma | Add-on | Natural language — presentations, documents, webpages | "Create a pitch deck for my startup" |
| Google Calendar | Add-on | Natural language — calendar events, meeting times, availability | "Find a free slot for a meeting tomorrow" |
| Telegram | Add-on | Automatic when launched with `ctg` or `cbraintg` — reads and replies to Telegram messages | (messages arrive automatically from connected chats) |

> **Key distinction:** Slash commands (`/rswarm`, `/rhive`, `/pretext`) require you to type the command. Everything in this table works by just talking to Claude naturally.
>
> **Add-on tools** are not part of the 8-step setup — they're optional MCP servers you can connect separately. Claude auto-detects them when they're installed.

---

## Status Line Indicators

When these tools are active, you may see indicators in your Claude session:

| Indicator | Meaning |
|-----------|---------|
| 2ndBrain | Working inside your Obsidian vault |
| Ruflo | Ruflo MCP server is connected |
| UIPro | Design skill is loaded (always on after Step 4) |
| 15 agents | Swarm is active with 15 agents (after `/rswarm`) |
| Hive | Hive-mind is active (after `/rhive`) |

---

## When Claude Asks for Permission

In normal mode, Claude will ask before doing things like editing a file or running a command. You'll see a prompt — type **y** and hit Enter to approve, or **n** to deny. In `cskip` mode or with Shift+Tab toggled on, this is skipped entirely.

---

## Ruflo Commands (Step 3)

These are available in your terminal after Step 3 installs the Ruflo CLI.

| Command | What it does |
|---------|-------------|
| `npx @claude-flow/cli@latest doctor --fix` | Diagnose and fix Ruflo installation issues |
| `npx @claude-flow/cli@latest daemon start` | Start the Ruflo background daemon |
| `npx @claude-flow/cli@latest swarm status` | Check the status of any running swarm |
| `npx @claude-flow/cli@latest memory search --query "..."` | Search your agent memory for past context |
| `npx @claude-flow/cli@latest memory list` | List all stored memory entries |

---

## Update & Maintenance

| Command | What it does |
|---------|-------------|
| `curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/update.sh \| bash` | Re-run all steps, skip what is installed, pick up anything new |
| `source ~/.zshrc` | Reload shell config to activate new aliases |
| `claude update` | Update Claude Code itself to the latest version |
| `brew update && brew upgrade` | Update Homebrew and all installed packages (macOS) |

---

## Quick Troubleshooting

| Problem | Fix |
|---------|-----|
| `cskip` not recognized | Run `source ~/.zshrc` to reload your shell config |
| Claude asks for login | Run `claude` once normally and complete the browser login flow |
| Shift+Tab does nothing | Make sure you are inside an active Claude session (not at a normal shell prompt) |
| Swarm not responding | Run `npx @claude-flow/cli@latest doctor --fix` to diagnose |
| MCP tools not connecting | Exit Claude, run `claude mcp list` to check connections, then relaunch |
| `cbrain` not working | Run `cskip` instead, then tell Claude: "cbrain isn't working — can you figure out why and fix it?" Claude will find the problem, fix it, and get it working for future sessions. |
| Obsidian vault not found | Tell Claude the full path to your vault (e.g., `~/Desktop/2ndBrain`) |
| Shift+Return acts like Enter | Try Option+Enter as an alternative for multi-line input |

---

## Tips

- Claude remembers context within a session. If it's getting confused, use `/compact` to reset.
- You can paste file paths, URLs, and error messages directly — Claude will read and understand them.
- Say "yes" when Claude asks for permission, or use the `!` prefix to run commands directly without leaving the session.
- Voice commands work in Claude Code — use `/voice` to enable microphone input.
- If Claude seems confused or slow, run `/compact` to summarize the conversation and free up context.
- You can drag and drop files into your terminal to paste their full file path.
- Press **Up Arrow** to recall and re-run previous commands without retyping them.
- To start fresh, just exit and relaunch.
