# Claude Code Cheat Sheet

## My Favorites (daily drivers)

The commands I reach for most. Full reference below.

| Command | What it does |
|---------|-------------|
| `cskip` | Launch Claude with permissions skipped — the daily driver |
| `cbrain` | Launch Claude inside your 2ndBrain vault *(requires vault setup — see [2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging))* |
| `g2` | Tile 2 Ghostty windows side by side (macOS) |
| `/fswarm <task>` | Launch a 15-agent FidgetFlo swarm — describe the task in plain English |
| `/fmini <task>` | Compact 5-agent FidgetFlo swarm for focused work |
| `/w4w` | Word-for-word, line-for-line. Max attention, zero skipping, no summarizing |
| `/safetycheck` | Security audit — scans for exposed keys, injection vectors, supply-chain risks |
| `/gitfix` | Full repo sync — reads every file, fixes doc drift, makes reality match the README |
| `/save` | Capture a conversation into your 2ndBrain vault *(requires [2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging))* |

---

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
| `cbrain` | Launch Claude Code in your 2ndBrain vault with skip-permissions *(requires vault setup — see [2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging))* |
| `cbraintg` | Same as `cbrain` but with Telegram channel connected |
| `ctg` | Skip-permissions + Telegram channel connected (any directory) |
| `g2` | Tile 2 Ghostty windows side by side, filling your screen *(requires Ghostty — Bonus step, macOS only)* |
| `g4` | Tile 4 Ghostty windows in a 2x2 grid *(requires Ghostty — Bonus step, macOS only)* |

> **Tip:** After running any setup script, run `source ~/.zshrc` to activate new commands. The scripts do this automatically, but just in case.
>
> **Note:** Until you set up Second Brain ([2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging)), use `cskip` instead of `cbrain`. The `cbrain` command requires an Obsidian vault to exist — if you haven't created one yet, it will error. Everything else works right away with `cskip`.

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
| `/resume` | Pick up right where you left off — reloads your last session's context |
| `!command` | Run a shell command without leaving Claude (e.g., `!ls`) |

---

## Claude Code Skills (slash commands)

These are custom skills installed by the setup scripts. Type them inside a Claude session.

| Command | Installed in | What it does |
|---------|-------------|-------------|
| `/fswarm do the thing` | Step 3 | Launch a 15-agent FidgetFlo swarm — just describe what you want in plain English after `/fswarm` |
| `/fmini do the thing` | Step 3 | Launch a compact 5-agent FidgetFlo swarm — same power, tighter team |
| `/fswarm1 <task>` | Step 3 | 15-agent swarm with light extended thinking (~4k budget per agent) — `Think.` appended to every Agent prompt |
| `/fswarm2 <task>` | Step 3 | 15-agent swarm with hard/deep thinking (~10k budget per agent) — `Think hard.` appended |
| `/fswarm3 <task>` | Step 3 | 15-agent swarm with harder/deeper thinking (~31k budget per agent) — `Think harder.` appended |
| `/fswarmmax <task>` | Step 3 | 15-agent swarm at MAX thinking (~32k budget per agent) — `Ultrathink.` appended |
| `/fmini1 <task>` | Step 3 | 5-agent swarm with light extended thinking (~4k budget per agent) — `Think.` appended |
| `/fmini2 <task>` | Step 3 | 5-agent swarm with hard/deep thinking (~10k budget per agent) — `Think hard.` appended |
| `/fmini3 <task>` | Step 3 | 5-agent swarm with harder/deeper thinking (~31k budget per agent) — `Think harder.` appended |
| `/fminimax <task>` | Step 3 | 5-agent swarm at MAX thinking (~32k budget per agent) — `Ultrathink.` appended |
| `/fhive <goal>` | Step 3 | Launch a queen-led autonomous FidgetFlo hive-mind with raft consensus |
| `/w4w` | Step 3 | Maximum attention to detail — word for word, line for line. No skipping, no summarizing. Also works without the slash — just type `w4w` |
| `/safetycheck` | Step 9 | Security audit — scans any project for exposed keys, missing rate limiting, input sanitization gaps, dependency vulnerabilities, and insecure configurations. Also responds to "run a safety check" in plain English |
| `/gitfix` | Final Step | Full repo sync — reads every install script, skill file, and doc in the repo, finds every inconsistency between the code and the documentation, and fixes all of it. Run this any time you've made changes to a repo and need the README, cheatsheet, and all other docs to reflect reality |

### 2ndBrain-mogging skills *(requires [2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging) installed)*

| Command | What it does |
|---------|-------------|
| `/save` | Capture a conversation, passage, or ADR into the vault — alias-driven classification, commits with `[bot:save]` |
| `/wiki` | Add / audit / heal / find across the vault — ingest sources, repair dead links, run graph audits |
| `/challenge` | Adversarial vault agent — argues against an idea using your own past notes and memory |
| `/emerge` | Surface rising topics, killed ideas, and new links across a time window |
| `/backfill` | Ingest historical Claude CLI transcripts into the vault with chunked summarization + dedupe |
| `/aliases` | Manage the alias classifier — add, edit, or audit entries in `Claude-Memory/aliases.yaml` |
| `/autoresearch` | Fetch a URL, summarize to `02-Sources/`, spawn linked concept stubs in `03-Concepts/` |
| `/canvas` | Generate/maintain Obsidian Canvas files from vault queries |
| `/tether` | Repair orphaned notes, bidirectionally link projects and hubs |
| `/connect` | Bridge two notes — surfaces structural analogies, transfer opportunities, collision ideas |

> These are **explicit triggers** — you type the command to activate the skill. This is different from the auto-triggered tools below, which respond to natural language. Exception: `/w4w` also works without the slash — just type `w4w` anywhere in your message. `/fmini` is the compact version of `/fswarm` — 5 agents instead of 15. `/safetycheck` also works in natural language ("run a safety check"). `/gitfix` also works in natural language ("fix the github", "sync the repo", "update the readme"). Slash commands: `/fswarm`, `/fswarm1`–`/fswarmmax`, `/fmini`, `/fmini1`–`/fminimax`, `/fhive`, `/w4w`, `/safetycheck`, `/gitfix` — all require you to type the command (or its natural-language equivalent where noted).

---

## Auto-Triggered Tools (natural language — no command needed)

These activate on their own when Claude detects a relevant task via natural language. You never type a command — just describe what you want and Claude picks up the right tool.

| Tool | Installed in | How it activates | Example prompt |
|------|-------------|-----------------|----------------|
| UI/UX Pro Max | creativity-maxxing | Natural language — asks about UI, design, layouts, interfaces | "Build me a dashboard with a sidebar" |
| Taste Skill (7 variants) | creativity-maxxing | Natural language — anything frontend/design. Stops generic AI "slop" output. Name a variant to force it: "use minimalist-skill", "redesign this with soft-skill" | "Build a premium landing page" · "Redesign this dashboard with taste-skill" |
| 21st.dev Magic | creativity-maxxing | Natural language — building components, pulls from 21st.dev library | "Create a hero section with a CTA" |
| Context Hub (`get-api-docs`) | Step 3 | Natural language — Claude writes code that calls external APIs | "Use the Stripe API to create a checkout" |
| Remotion | creativity-maxxing | Natural language — video, animation, motion graphics | "Make a 30-second intro video" |
| YouTube Transcripts | creativity-maxxing | Natural language — paste a YouTube link and ask for the transcript | "Get the transcript of this video: https://youtube.com/..." |
| IG/Social Transcription | creativity-maxxing | Natural language — paste an Instagram, TikTok, or social media link | "Transcribe this reel: https://instagram.com/reel/..." |
| Notion | Step 6 | Natural language — pages, databases, knowledge management | "Search my Notion for the meeting notes" |
| Granola | Step 6 | Natural language — meeting transcripts and notes | "What did we cover in my last meeting?" |
| n8n (your own) | Step 6 | Natural language — trigger and inspect your own n8n workflows | "Run my lead-qualification workflow on this email" |
| Google Calendar | Step 6 | Natural language — direct Google Calendar access (secondary — use if Morgen not installed) | "What's on my Google calendar this week?" |
| Morgen *(recommended)* | Step 6 | Natural language — unified calendar + tasks across Google/Outlook/iCloud/native | "What's on my calendar this week?" · "Add a task called 'Review contracts' due Friday" |
| Motion Calendar | Step 6 | Natural language — Motion-specific features (teammate visibility, full event search) | "Who on my team has a conflict at 3pm?" |
| Playwright | Step 6 | Natural language — browser automation for web apps with no API (real Chromium, accessibility-tree snapshots — not a session hijack) | "Open Higgsfield and generate a video with prompt X" |
| Obsidian | 2ndBrain-mogging | Natural language — read/write/search a local Obsidian vault (set up via [lorecraft-io/2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging)) | "Search my vault for notes about machine learning" |
| No-Flicker Mode | Step 2 | Automatic — fullscreen rendering, no screen jumping while Claude works | (always on — set via environment variable) |
| Memory Hook | Step 2 | Automatic on session end — saves context from the conversation | (no prompt needed — runs automatically) |
| Telegram | Step 8 | Automatic when launched with `ctg` or `cbraintg` — reads and replies to Telegram messages | (messages arrive automatically from connected chats) |
| Canva | Add-on | Natural language — create or edit designs, social posts, presentations | "Design a social media post for our launch" |
| Figma | Add-on | Natural language or paste a Figma URL — design-to-code, inspect designs | "Turn this Figma into React components" |
| Excalidraw | Add-on | Natural language — diagrams, flowcharts, whiteboard sketches | "Draw a system architecture diagram" |
| Gamma | Add-on | Natural language — presentations, documents, webpages | "Create a pitch deck for my startup" |

> **Key distinction:** Slash commands (`/fswarm`, `/fswarm1`–`/fswarmmax`, `/fmini`, `/fmini1`–`/fminimax`, `/fhive`, `/w4w`, `/safetycheck`, `/gitfix`, plus the 2ndBrain-mogging `/save`, `/wiki`, `/challenge`, `/emerge`, `/backfill`, `/aliases`, `/autoresearch`, `/canvas`, `/tether`, `/connect`) require you to type the command. Everything in this table works by just talking to Claude naturally.
>
> **Add-on tools** are not part of the step-by-step setup — they're optional MCP servers you can connect separately. Claude auto-detects them when they're installed.

---

## Taste Skill — Variants & Knobs (creativity-maxxing)

Installed by creativity-maxxing via `npx skills add Leonxlnx/taste-skill`. The pack ships **7 variants** as separate skill folders under `~/.claude/skills/`. They're passive skills — Claude activates the right one based on what you ask for. You can also name a variant explicitly in your prompt ("use soft-skill", "redesign this with minimalist-skill") to force a specific style.

| Variant | When Claude uses it | Example prompt |
|---------|---------------------|----------------|
| `taste-skill` | Default premium frontend rules — layout, typography, color, spacing, motion | "Build a premium SaaS landing page" |
| `redesign-skill` | Upgrading an existing project — audits current design, then fixes problems | "Redesign this dashboard — it looks generic" |
| `soft-skill` | Expensive, soft UI look — premium fonts, whitespace, depth, spring animations | "Make this feel expensive, soft, Apple-ish" |
| `output-skill` | Anti-laziness — stops placeholder comments, skipped blocks, half-finished outputs | "Give me the full component, no TODOs" |
| `minimalist-skill` | Clean editorial style — monochrome, crisp borders, Notion/Linear inspired | "Build a minimalist admin panel" |
| `brutalist-skill` *(beta)* | Raw mechanical interfaces — Swiss typographic print fused with CRT terminal aesthetics | "Make it brutalist, terminal-style" |
| `stitch-skill` | Google Stitch-compatible semantic design rules; exports a `DESIGN.md` | "Set up stitch-compatible design rules for this project" |

### Taste Skill Knobs (`taste-skill` variant only)

The main `taste-skill` file has three numeric knobs at the top you can tune from **1-10**. Edit `~/.claude/skills/taste-skill/SKILL.md` and change the numbers, or tell Claude "set DESIGN_VARIANCE to 9 for this build".

| Knob | 1-3 | 4-7 | 8-10 |
|------|-----|-----|------|
| **DESIGN_VARIANCE** | Clean, centered | Balanced | Asymmetric, modern |
| **MOTION_INTENSITY** | Simple hover | Smooth transitions | Magnetic, scroll-triggered |
| **VISUAL_DENSITY** | Spacious, luxury | Balanced | Dense dashboards |

> **No slash commands.** Taste Skill activates automatically on design work, or when you reference a variant by name. There are no `/taste-skill`-style commands to memorize. If you want Claude to NOT use it, say so — e.g. "skip taste-skill for this one, just give me raw HTML."

---

## Status Line Indicators

When these tools are active, you may see indicators in your Claude session:

| Indicator | Meaning |
|-----------|---------|
| 🧠 2ndBrain | Working inside your Obsidian vault |
| ⚡ FidgetFlo | FidgetFlo MCP server is connected |
| 🎨 UIPro | Design skill is loaded (always on after creativity-maxxing) |
| 🐝 Swarm | Swarm is active — shows agent count (after `/fswarm`) |
| 🍯 Mini | Mini swarm is active — shows agent count (after `/fmini`) |
| 👑 Hive | Hive-mind is active (after `/fhive`) |

---

## When Claude Asks for Permission

In normal mode, Claude will ask before doing things like editing a file or running a command. You'll see a prompt — type **y** and hit Enter to approve, or **n** to deny. In `cskip` mode or with Shift+Tab toggled on, this is skipped entirely.

---

## FidgetFlo Commands (Step 3)

These are available in your terminal after Step 3 installs the FidgetFlo CLI.

| Command | What it does |
|---------|-------------|
| `npx fidgetflo@latest doctor --fix` | Diagnose and fix FidgetFlo installation issues |
| `npx fidgetflo@latest daemon start` | Start the FidgetFlo background daemon |
| `npx fidgetflo@latest swarm status` | Check the status of any running swarm |
| `npx fidgetflo@latest memory search --query "..."` | Search your agent memory for past context |
| `npx fidgetflo@latest memory list` | List all stored memory entries |

---

## Update & Maintenance

| Command | What it does |
|---------|-------------|
| `bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/update.sh)` | Re-run all steps, skip what is installed, pick up anything new |
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
| Swarm not responding | Run `npx fidgetflo@latest doctor --fix` to diagnose |
| MCP tools not connecting | Exit Claude, run `claude mcp list` to check connections, then relaunch |
| `cbrain` not working | Run `cskip` instead, then tell Claude: "cbrain isn't working — can you figure out why and fix it?" Claude will find the problem, fix it, and get it working for future sessions. |
| Obsidian vault not found | Vault setup lives in [2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging). Once set up, tell Claude the full path to your vault (e.g., `~/Desktop/2ndBrain`) |
| Shift+Return acts like Enter | Try Option+Enter as an alternative for multi-line input |

---

## Reset PATH (stuck install)

If you ran the installer, opened a fresh terminal, and `claude --version` still says "command not found" — your `~/.zshrc` is probably missing the lines that wire Homebrew, nvm, `~/.local/bin`, and the cli-maxxing aliases together. This is the exact block we used on marina@Mac to unstick her install. Paste it verbatim into your terminal — it creates `~/.zshrc` if it doesn't exist, appends the four things that need to be on PATH, then sources it and verifies `claude` works.

```bash
cat > ~/.zshrc <<'EOF'
# Homebrew (Apple Silicon default; also works on Intel via brew --prefix)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# nvm (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# User-local binaries (cbrain, ctg, cbraintg land here)
export PATH="$HOME/.local/bin:$PATH"

# cli-maxxing aliases
alias cskip='claude --dangerously-skip-permissions'
alias cc='claude'
alias ccr='claude --resume'
alias ccc='claude --continue'
EOF

source ~/.zshrc
claude --version
```

**What to expect:** `claude --version` should print something like `2.1.112 (Claude Code)`. If it does, you're unstuck — close this terminal, open a fresh one, and continue from where you left off. If it still errors, the issue is upstream of PATH (Claude Code itself didn't install, or Node is broken) — paste the error into a `cskip` session and Claude can diagnose.

> **Using bash instead of zsh?** Swap `~/.zshrc` for `~/.bashrc` in the block above. Everything else is identical.

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
