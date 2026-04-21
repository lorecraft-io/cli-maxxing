<a id="top"></a>

# CLI Maxxing

**Everything you need to start working with AI-powered development tools; one command per step.**

> [!NOTE]
> **Heads up — this was fidgetcoded.** I'm no expert, but I tried — nominally — my best. Getting this stack running end-to-end on a clean machine took a lot of trial and error, and it still might not be perfect.
>
> <hr>
>
> **fidg·et·cod·ing** \ ˈfij-ət-ˌkō-diŋ \   *verb*   ·   **fidgetcoded**; **fidgetcode**<br>
> **1** : to code as self-regulation — the ADHD dopamine loop<br>
> **2** : to build software through relentless tinkering by someone with no formal training and too many browser tabs open
>
> <hr>
>
> **Read everything carefully as you go (or don't, entirely your call).** If something breaks mid-install, don't panic (or do, also your call):
>
> 1. **Get Claude CLI up first (Step 1).** Once it's running, you can paste any error straight into it and Claude will help you troubleshoot EVERYTHING downstream.
> 2. **Re-run the install step.** A lot of first-pass failures quietly clear themselves on the second try — re-running is almost always the right first move before anything fancier.

## The Trilogy

This is one of three repos in the cli-maxxing stack:

| Repo | What it does |
|------|-------------|
| **`cli-maxxing`** | **This repo** — Foundation — Claude Code, shell aliases, FidgetFlo, dev tools, productivity MCPs |
| [`creativity-maxxing`](https://github.com/lorecraft-io/creativity-maxxing) | Design skills + video/audio pipeline |
| [`task-maxxing`](https://github.com/lorecraft-io/task-maxxing) | Three-way task sync — Obsidian ↔ Notion ↔ Morgen (requires [`2ndBrain-mogging`](https://github.com/lorecraft-io/2ndBrain-mogging)) |

Install `cli-maxxing` first. `creativity-maxxing` and `task-maxxing` can be installed in either order after that.

## Quick Navigation

| | Section | What it does | Time |
|---|------|-------------|------|
| [Before You Start](#before-you-start) | Requirements | What you need before running anything | |
| [How It Works](#how-it-works) | Overview | How the steps fit together | |
| [Install Everything](#install-everything) | One-shot | Run all steps at once | ~20 min |
| [Keyboard + Command Cheat Sheet](#keyboard--command-cheat-sheet) | Commands & Shortcuts | Hotkeys, typing, and commands for your terminal | |
| [Step 1](#step-1---cli-tools) | CLI Tools | Git, Node.js, Claude Code, shell aliases — the foundation | ~10 min |
| [Step 2](#step-2---bonus-software) | Bonus Software | Ghostty (terminal) + Arc (browser) — optional but highly recommended | ~4 min |
| [Step 3](#step-3---developer--utility-tools) | Developer & Utility Tools | Adds file converters, search, utilities, and no-flicker mode | ~3 min |
| [Step 4](#step-4---fidgetflo) | FidgetFlo | Multi-agent orchestration — swarms, hives, persistent memory, Opus locked | ~3 min |
| [Step 5](#step-5---productivity-tools) | Productivity Tools | Notion + Granola + n8n + GCal + Morgen + Motion + Playwright + SwiftKit (pick what you use; Morgen recommended) | ~5 min |
| [Step 6](#step-6---telegram) | Telegram | Message Claude from your phone via Telegram bot | ~2 min |
| [Step 7](#step-7---github) | GitHub | GitHub MCP + /gitfix skill — repos, issues, PRs, code search, full-repo doc sync (requires PAT) | ~2 min |
| [Step 8](#step-8---safety-check) | Safety Check | Security auditing — scan any project for vulnerabilities + full MCP security checks | ~2 min |
| [Final Step](#final-step---status-line) | Status Line | Final config — status indicators for active swarms, vault, MCP | ~2 min |
| [You're Ready](#youre-ready) | **Start here after setup** | Your daily command and what to do next | |
| [Video Tutorials (coming soon)](#video-tutorials-coming-soon) | Walkthroughs | Shows you exactly how to do everything, screen by screen | |
| [Staying Up to Date](#staying-up-to-date) | Update command | Re-run everything, catch new steps | |
| [Uninstall](#uninstall) | Remove everything | Reverses all steps, cleans up tools and config | |

---

## Before You Start

[Back to top](#quick-navigation)

> [!IMPORTANT]
> **You need a paid [claude.ai](https://claude.ai) subscription before anything below is useful.**
>
> The Claude Code CLI installs for free — but USING Claude requires a paid plan. If you don't have one yet, [sign up first](https://claude.ai) (Claude Pro is the minimum tier at $20/mo; Max is recommended for heavy use). Otherwise the installer downloads ~500 MB of tooling that has nothing to talk to.
>
> The installer will prompt you upfront — press Enter if you're subscribed, Ctrl+C to bail and sign up first.

- Your computer needs to be from roughly **2020 or later** (macOS Big Sur+ or a recent Linux).
- You need an **internet connection** since the scripts download everything live.
- **Don't run it as root.** Just open your terminal normally and paste the command.
- If anything is already installed on your machine, the scripts will detect that and skip it automatically.

> **Windows:** Not supported. MacOS and Linux only (frankly, I'm not 100% certain Linux is supported).

---

## How It Works

[Back to top](#quick-navigation)

Run the steps in order. Each one builds on the last.

**[Step 1 — CLI Tools](#step-1---cli-tools)** is the only part that feels "techy." This step gets the bare essentials on your machine so Claude (your AI assistant) can run — Git, Node.js, Claude Code, and shell aliases. You paste one command and it handles the rest, but there are a few manual steps after it finishes, like logging into Claude. This is the most hands-on part of the entire process. After Step 1, you can ask Claude questions at any point. If something doesn't make sense, just ask. That's the whole point.

**[Step 2 — Bonus Software](#step-2---bonus-software)** is optional but highly recommended. It installs two tools that make your day-to-day flow noticeably smoother: **Ghostty**, a GPU-accelerated terminal with Cmd+Click support for URLs and file paths, and **Arc**, a Chromium-based browser with a sidebar instead of a tab bar, Spaces for context switching, and built-in ad blocking. You don't need either to continue — everything works in any terminal and any browser — but if you want the best terminal + browser setup, this is it.

**[Step 3 — Developer & Utility Tools](#step-3---developer--utility-tools)** is where you install the rest of your development tools. Things like file converters, search tools, and utilities. You run this from your terminal after Step 1 is done. Much more straightforward.

**[Step 4 — FidgetFlo](#step-4---fidgetflo)** is where you set up [FidgetFlo](https://github.com/lorecraft-io/fidgetflo), the multi-agent orchestration layer that turns Claude into a full team of AI agents — `/fswarm`, `/fmini`, `/fhive`, persistent memory, Opus-locked.

**[Step 5 — Productivity Tools](#step-5---productivity-tools)** connects Claude to your productivity tools — notes, calendars, meetings, workflows, browser automation, and hosted toolkits. Pick the ones you use: Notion, Granola, your own n8n instance, Google Calendar, Morgen (recommended), Motion Calendar, Playwright, or SwiftKit. All optional, install only what you need.

**[Step 6 — Telegram](#step-6---telegram)** connects Claude to Telegram so you can message it straight from your phone. You create a free bot through Telegram (takes about two minutes), the script handles the rest, and then you use `ctg` or `cbraintg` to launch Claude with Telegram connected — messages show up in your session in real time. This step is completely optional; everything else works without it.

**[Step 7 — GitHub](#step-7---github)** is the GitHub bundle — for developers. It installs the GitHub MCP so Claude can read and write your repos, issues, pull requests, and search code across your GitHub organizations (requires a GitHub Personal Access Token), plus the `/gitfix` skill that reads every file in a repo and fixes any drift between your code and your docs. Skip this step if you don't use GitHub with Claude.

**[Step 8 — Safety Check](#step-8---safety-check)** installs a security auditing skill that lets Claude scan any project for exposed keys, missing rate limiting, input sanitization gaps, dependency vulnerabilities, and more. Just point Claude at a project and ask it to run a safety check. It catches the stuff that slips through code review.

**[Final Step — Status Line](#final-step---status-line)** is the wrap-up. It installs a custom status line that shows you what's active at a glance — your vault, MCP connection, design tools, and any running swarms, mini swarms, or hive-minds.

After the Final Step, head to **[You're Ready](#youre-ready)** — it tells you the one command you need going forward and what to do next.

Between Steps 1 and 2, make sure to read the **[Keyboard + Command Cheat Sheet](#keyboard--command-cheat-sheet)** so you know how to type, navigate, and use hotkeys in your terminal.

**[Video tutorials](#video-tutorials-coming-soon)** walking through every step are coming soon.

Already done with everything? Use the **[Staying Up to Date](#staying-up-to-date)** command to catch any new steps or updates that have been added since your last visit.

If you ever want to start fresh or remove everything this setup installed, there's a one-command **[Uninstall](#uninstall)** that reverses all steps. It won't touch your Obsidian vault or notes.

### Already have Claude Code installed?

If you already have Claude Code working on your machine, you can skip Step 1 entirely. Just jump straight to [Step 3](#step-3---developer--utility-tools). Everything will work the same. You can paste the install commands directly in your terminal, or if you prefer, download this repo as a ZIP from GitHub, unzip it, and tell Claude to run the scripts from whatever folder they landed in.

### Bonus

Want to get better at using the terminal in general? Check out [Terminal Academy](https://github.com/lorecraft-io/terminal-academy), a gamified way to learn terminal commands and workflows. It makes the learning curve way less painful.

---

## Install Everything

[Back to top](#quick-navigation)

If you already know your way around a terminal and just want everything installed at once:

> [!IMPORTANT]
> **Paste this into your terminal:**
> ```
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/install.sh)
> ```

This runs Steps 1, 2, 3, 9, and the Final Step automatically, plus both bonuses (Ghostty and Arc Browser). Arc is macOS-only and will be skipped on Linux. Everything is idempotent — already-installed tools are skipped.

---

## [Keyboard + Command Cheat Sheet](CHEATSHEET.md)

[Back to top](#quick-navigation)

This is a quick reference for terminal hotkeys, typing basics, launching Claude, and useful commands. **Read this before starting the steps**, especially if you're new to working in a terminal.

**[Open the full Cheat Sheet →](CHEATSHEET.md)**

Here are the commands you'll use most:

| Command | What it does |
|---------|-------------|
| `cskip` | Start with all permissions skipped (fastest, no prompts) |
| `cbrain` | Jump straight into your 2ndBrain vault with permissions skipped *(requires [2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging))* |
| `Shift+Tab` | Toggle permissions on/off mid-session without restarting |
| `/fswarm *write task here*` | Launch a 15-agent FidgetFlo swarm — just describe what you want in plain English after `/fswarm` |
| `/fmini *write task here*` | Launch a compact 5-agent FidgetFlo swarm — same power, tighter team. Describe your task after `/fmini` |
| `/w4w` | Maximum attention to detail mode — word for word, line for line. No skipping, no summarizing, zero regard for credit burn |
| `Ctrl+C` | Stop whatever is running or exit Claude |
| `/resume` | Pick up right where you left off — reloads your last session's context |

Everything else — aliases, slash commands, natural-language tools, troubleshooting — is in the **[full Cheat Sheet](CHEATSHEET.md)**.

---

## Step 1 - CLI Tools

[Back to top](#quick-navigation)

This step installs the minimum needed to get Claude Code running on your machine. It's the most hands-on part of the setup — everything after this can be handled by Claude itself.

### macOS / Linux

Open Terminal: **Cmd+Space → "Terminal"** on Mac, or **Ctrl+Alt+T** on Linux.

> [!IMPORTANT]
> **Paste this in and hit Enter:**
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-1/step-1-install.sh)
> ```

> The script will ask for your Mac password to install system tools. When you see `Password:`, type it and hit Enter — you won't see the characters, that's normal.

> **Xcode Command Line Tools dialog (Mac).** Early in the install, macOS pops up a system dialog to download Apple's Command Line Tools. Click **Install** (and **Agree** on the license prompt) the moment it appears. The dialog will claim "About an hour remaining" — **ignore it.** The actual download is ~3–5 minutes and the timer never refreshes. Just leave the dialog open, let it finish, and the install script picks right back up.

### What This Step Installs

| Tool | What it does |
|------|-------------|
| Xcode CLT (Mac) / build-essential (Linux) | Build tools that other installers need. |
| Homebrew (Mac) / apt or dnf (Linux) | Package manager — installs other software. |
| Git | Tracks and manages code changes. |
| nvm + Node.js (v18+) | Node Version Manager + the JavaScript runtime Claude Code needs. |
| Claude Code | Your AI coding assistant. The main tool. |
| Shell aliases | `cskip`, `cc`, `ccr`, `ccc` — faster ways to launch Claude. |
| cbrain | Launches Claude pointed at your Obsidian vault. Daily driver after setting up [2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging). |
| ctg | Launches Claude with Telegram connected from any directory. |
| cbraintg | `cbrain` + Telegram. |

### After the script finishes

1. **Close this terminal and open a new one.** Homebrew, nvm, and the new aliases only load in a fresh shell. `claude` won't be on your PATH until you restart.
2. **Run `claude --version`** — you should see something like `2.1.112 (Claude Code)`. If you get "command not found," try `source ~/.zshrc` (or `~/.bashrc`). Still stuck? See [Troubleshooting](#troubleshooting).
3. **Press Ctrl+C to exit Claude, then run `cskip`** — this starts Claude in auto-approve mode (no permission prompts), the recommended way to run the rest of the setup.

> **Shift+Tab** toggles between permission-asking mode and auto-approve mode inside any running Claude session — no need to restart.

### Set Up Your Claude Account

Sign up at [claude.ai](https://claude.ai) before Step 3. Claude Code is free to install but requires a paid plan to actually use.

**Why Claude?** Anthropic consistently ships the strongest model for complex reasoning + code, and they lead on safety research instead of chasing hype. Claude is careful, honest, and doesn't BS you when it doesn't know something — it's the smartest tool in the room, built by people who care about getting this right.

#### Subscription Plans

| Plan | Cost | What you get |
|------|------|-------------|
| **Claude Pro** | $20/month | Everyday tasks — writing code, editing files, Q&A. You'll hit limits on long sessions. |
| **Claude Max 5x** | $100/month | 5× Pro usage. Best for daily users and multi-step workflows. |
| **Claude Max 20x** | $200/month | 20× Pro usage. Full codebase refactors, multi-agent swarms, all-day sessions. |

**My recommendation:** Start with **Pro** ($20/month). If you hit rate limits, upgrade to Max — you'll know pretty quickly which tier fits your workflow.

That's it for Step 1. Continue to [Step 2 — Bonus Software](#step-2---bonus-software) for Ghostty + Arc, or jump straight to [Step 3 — Developer & Utility Tools](#step-3---developer--utility-tools).

---

## Step 2 - Bonus Software

[Back to top](#quick-navigation)

Optional but highly recommended. Installs **Ghostty** (GPU-accelerated terminal with clickable links + `g2`/`g4` window tiling) and **Arc** (sidebar-tab browser with Spaces, split view, built-in ad blocking). Everything else in this setup works without them — skip if you're happy with your current terminal + browser.

### Run both at once

> [!IMPORTANT]
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-2/step-2-install.sh)
> ```

Prefer to do one at a time? Run either script individually:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-2/ghostty-install.sh)
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-2/arc-install.sh)
```

---

### Ghostty Terminal

GPU-accelerated (Metal on Mac, OpenGL on Linux). **Cmd+Click** any URL or file path to open it. Comes tuned: JetBrains Mono font, dark theme, tabbed windows, plus `g2`/`g4` aliases to tile 2 or 4 Ghostty windows across your screen in one keystroke — great for running multiple Claude sessions side-by-side.

**Docs:** [ghostty.org/docs](https://ghostty.org/docs) · **Config:** `~/Library/Application Support/com.mitchellh.ghostty/config` (Mac) or `~/.config/ghostty/config` (Linux)

<details>
<summary><strong>Script failed? Install Ghostty manually</strong></summary>

1. Go to [ghostty.org/download](https://ghostty.org/download) → **Download for macOS** (or your Linux package).
2. Open the `.dmg`, drag **Ghostty.app** into **Applications**, eject the image.
3. Open Ghostty (Cmd+Space → `Ghostty`) → click **Open** on the macOS warning.
4. Re-run the Ghostty install script above to pick up the font + theme + `g2`/`g4` config. It's idempotent.

</details>

---

### Arc Browser

Chromium-based with a sidebar instead of a tab bar, Spaces for context switching, split view, built-in ad blocking, and a Cmd+T command bar that replaces the URL bar. Imports from Chrome in 30 seconds — bookmarks, passwords, history, and all your extensions come along.

**Download:** [arc.net](https://arc.net) · macOS + Windows only (Linux skips this step automatically)

<details>
<summary><strong>Script failed? Install Arc manually</strong></summary>

1. Go to [arc.net](https://arc.net) → **Download Arc** (auto-detects your OS).
2. Open the downloaded file → drag **Arc.app** into **Applications** (Mac), or run the `.exe` (Windows).
3. Open Arc → click **Open** on the macOS warning.
4. Sign up for a free Arc account (required for sync) and accept the Chrome import prompt.
5. Set Arc as default browser when asked — or later via **System Settings → Desktop & Dock → Default web browser**.

</details>

---

## Step 3 - Developer & Utility Tools

[Back to top](#quick-navigation)

Installs the dev tools Claude leans on when working on your projects — file converters, search tools, PDF/doc utilities — plus **no-flicker mode** (fullscreen rendering, no screen jumping) and a **memory auto-save hook** (Claude remembers context between sessions).

### Run Step 3

In a fresh terminal, launch Claude in auto-approve mode:

```bash
cskip
```

First time? Claude opens a browser to log in with your Anthropic account. Once you're inside the session, paste this:

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to install my dev tools: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-3/step-3-install.sh)
> ```

Claude runs the install. If it asks you to restart your terminal, close the window, reopen, `cskip` again, and tell Claude to pick up where it left off.

> **Why `cskip`?** Auto-approve mode lets Claude run this install (10+ tools) in one smooth pass instead of asking permission for every action. Press **Shift+Tab** anytime to toggle it off without restarting. Normal `claude` mode is fine for daily use — `cskip` is just for setup.

### What This Step Installs

| Tool | What it does |
|------|-------------|
| Python 3 + pip | Runs Python scripts and tools. |
| Pandoc | Converts Word / PowerPoint / Markdown between formats. |
| xlsx2csv | Converts spreadsheets to readable CSV. |
| pdftotext | Extracts text from PDFs. |
| jq | Reads and edits JSON config files. |
| ripgrep | Fast code search — Claude Code uses it internally. |
| GitHub CLI | Manage GitHub from your terminal. |
| tree | Shows your folder structure visually. |
| fzf | Fuzzy-finder for files and commands. |
| wget | Downloads files from the web. |
| weasyprint | Converts HTML to PDF (Claude uses this to generate docs). |
| No-flicker mode | Fullscreen rendering in Claude Code — screen stops jumping while Claude works. Scroll speed set to 3. |
| Memory auto-save hook | Claude auto-saves important context when a session ends, so it remembers across sessions. |

<details>
<summary><strong>No-flicker mode details</strong></summary>

Research-preview feature (Claude Code v2.1.89+). Without it, the input box bounces while Claude streams output. With it on, input stays pinned to the bottom and everything updates cleanly.

Sets `CLAUDE_CODE_NO_FLICKER=1` and `CLAUDE_CODE_SCROLL_SPEED=3` in your shell profile. Scroll with mouse wheel, PgUp/PgDn, or Ctrl+Home/End. Click collapsed tool results to expand, click URLs to open.

To disable: remove both `export` lines from `~/.zshrc` (or `~/.bashrc`) and restart your terminal. Or set `CLAUDE_CODE_NO_FLICKER=0` for a temporary off-switch.

</details>

<details>
<summary><strong>Memory auto-save hook details</strong></summary>

A "stop hook" fires every time you end a Claude session (Ctrl+C or `/exit`). Claude reviews the conversation and saves anything important to memory — decisions, preferences, project context. Next session, it already knows. Nothing to configure; just keep using Claude and memory builds up over time.

</details>

---

## Step 4 - FidgetFlo

[Back to top](#quick-navigation)

[**FidgetFlo**](https://github.com/lorecraft-io/fidgetflo) is a fork of [ruvnet's Ruflo](https://github.com/ruvnet/ruflo), tuned for Claude Opus 4.7. It turns Claude Code from a single assistant into a coordinated team of AI agents: multi-agent swarms on demand, persistent memory, self-healing workflows, and all agents Opus-locked by default (no silent downgrade to Haiku/Sonnet).

### Run Step 4

Still in a `cskip` session? Good. Paste this:

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to set up FidgetFlo: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-4/step-4-install.sh)
> ```

If Claude tells you to restart your terminal, close the window, reopen, `cskip` again, and tell Claude to pick up where it left off.

### Commands

| Command | What it does |
|---------|-------------|
| `/fswarm <task>` | Launches 15 agents in parallel — architect, backend devs, testers, security auditor, etc. Brute-force execution. |
| `/fmini <task>` | Launches 5 agents — architect, dev, tester, reviewer, researcher. Tighter team for focused work. |
| `/fhive <goal>` | Queen agent takes full control — decides what workers to spawn and how to coordinate. Set the goal, step back. |
| `/w4w` | Word-for-word, line-for-line. Maximum attention, zero skipping. |

#### Thinking tiers

Subagents inherit the parent's model (Opus stays Opus) but **not** its `/effort` setting — the slider doesn't tether to spawned agents. These tier variants bake the trigger into each Agent prompt:

| Tier | Mini (5 agents) | Swarm (15 agents) | Trigger appended | Budget |
|------|-----------------|-------------------|------------------|--------|
| 0    | `/fmini`        | `/fswarm`         | *(none)*         | 0      |
| 1    | `/fmini1`       | `/fswarm1`        | `Think.`         | ~4k    |
| 2    | `/fmini2`       | `/fswarm2`        | `Think hard.`    | ~10k   |
| 3    | `/fmini3`       | `/fswarm3`        | `Think harder.`  | ~31k   |
| max  | `/fminimax`     | `/fswarmmax`      | `Ultrathink.`    | ~32k   |

Natural-language aliases work too: "hard"/"deep" → tier 2, "harder"/"deeper" → tier 3, "max"/"mega"/"ultra" → max. All variants are Opus-only and fire the 🐝 `/fswarm*` / 🍯 `/fmini*` statusline indicators.

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| FidgetFlo CLI + daemon | Coordinates agents, memory, and tasks in the background. |
| MCP Server | Wires FidgetFlo into Claude Code. |
| Memory System | Persistent, searchable memory shared across agents + sessions. |
| Opus Lock | All tasks and spawned agents run on Opus — no silent downgrade to Haiku/Sonnet. |
| Swarm + Hive + `/w4w` skills | The commands above. |
| TypeScript + agentic-flow | Required deps (embeddings, advanced routing). |
| Statusline | Live indicators for swarms, hives, model, session time, and context usage. |

**Want the deep dive?** Architecture, agent catalog (60+ types), memory system, hook pipeline, topology options — all in the [FidgetFlo repo →](https://github.com/lorecraft-io/fidgetflo)

### After Step 4

Your core tools are installed. Continue to Step 5 for productivity tools — or open a new `cskip` session and try something ambitious. FidgetFlo kicks in automatically when the task calls for it.

<details>
<summary><strong>What's an MCP?</strong></summary>

MCP stands for Model Context Protocol — a plugin system for Claude. Connect an MCP once and Claude gets access to a new tool or data source, which it picks up automatically when relevant.

</details>

<details>
<summary><strong>Verify the FidgetFlo MCP is connected</strong></summary>

```bash
claude mcp list
```

If FidgetFlo isn't listed, re-add it:

```bash
claude mcp add fidgetflo -- npx -y fidgetflo@latest
```

</details>

---

## Step 5 - Productivity Tools

[Back to top](#quick-navigation)

Connects Claude to the productivity tools you already use. Everything's optional — install only the ones that match your workflow. Once connected they all work through natural language:

> *"What's on my calendar this week?"* · *"Add a task called 'Review contracts' due Friday"* · *"Create a Notion page called Project Roadmap"* · *"What were the key points from my last meeting?"* · *"Triage my inbox"* · *"Trigger my lead-qualification workflow for this email"*

Claude picks the right tool automatically based on what you ask. Pick whichever apply:

1. **Notion** · 2. **Granola** · 3. **n8n** · 4. **Google Calendar** · 5. **Morgen** ⭐ · 6. **Motion Calendar** · 7. **Playwright** · 8. **SwiftKit** · 9. **Superhuman**

> **Morgen (5) is the recommended default** — it unifies Google, Outlook, iCloud, and native calendars + tasks behind a single API key. Google Calendar (4) and Motion (6) are secondary — install only if you need those accounts directly.
>
> **Obsidian MCP** lives in [2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging), not here. Install mogging after this repo completes — it handles vault setup AND registers the Obsidian MCP with Claude Code.

### Run Step 5

In a `cskip` session, paste this:

> [!IMPORTANT]
> ```
> run this command to install productivity tools: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-5/step-5-install.sh)
> ```

The script asks which tools you want, then walks you through each one's credentials. Skip anything you don't use — re-run the script later to add more.

### What each tool does

| # | Tool | What it does | Needs |
|---|------|--------------|-------|
| 1 | **Notion** ([@notionhq](https://github.com/makenotion/notion-mcp-server)) | Search, read, create pages + databases in your Notion workspace. Official, 22 tools. | Integration token from [notion.so/profile/integrations](https://www.notion.so/profile/integrations); share specific pages via page `...` → Connections. |
| 2 | **Granola** | Search your Granola meeting transcripts + notes through conversation. | [Granola](https://granola.ai) installed + signed in on Mac. No key. |
| 3 | **n8n** | HTTP bridge to **your own** n8n instance — trigger and inspect workflows you built. Not a hosted service. | An n8n workflow with an **MCP Server Trigger** node; copy its Production URL. Optional Bearer token. |
| 4 | **Google Calendar** | Direct Google Calendar access via OAuth. *Secondary — only install if you need a specific Google account bypassing Morgen.* | Google account + ~5min to create OAuth creds (script walks you through). |
| 5 | **Morgen** ⭐ ([@lorecraft-io](https://github.com/lorecraft-io/morgen-mcp)) | Unified calendar + tasks across Google/Outlook/iCloud/native. Natural-language dates/recurrence, auto-schedule, day reflow. One key for everything. | API key from [platform.morgen.so/developers-api](https://platform.morgen.so/developers-api). |
| 6 | **Motion Calendar** ([@lorecraft-io](https://github.com/lorecraft-io/motion-mcp)) | Teammate visibility + full event search that Morgen's API doesn't expose. *Motion-specific features only.* | Motion API key + Firebase key + refresh token + user ID (script walks you through). |
| 7 | **Playwright** ([Microsoft](https://github.com/microsoft/playwright-mcp)) | Lets Claude log into and operate web apps with no API. Runs its own Chromium (not your real browser), reads via accessibility-tree snapshots — fast + reliable. | Node 18+ (from Step 1) + ~hundreds of MB disk for Chromium. No credentials. |
| 8 | **SwiftKit** ([swiftkit.sh](https://swiftkit.sh)) | Hosted MCP toolkit for **iOS / macOS / Swift development** — 100+ tools for writing, building, and shipping Apple-platform code behind one HTTP endpoint. Default for anything iPhone/iOS/Swift-related. Nothing to install locally. | Account + API key (`sk_live_` or `sk_test_`). |
| 9 | **Superhuman** ([superhuman.com](https://superhuman.com)) | Email triage + drafting from Claude via Superhuman's official remote MCP. | Active Superhuman subscription. One-time browser OAuth on first use. |
| — | **Google Drive** ([local MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/gdrive) or claude.ai connector) | Browse, search, and read Google Drive files — Docs, Sheets, PDFs, shared folders. | **Easiest path:** enable the [claude.ai](https://claude.ai) connector (avatar → **Settings** → **Connectors** → **Google Drive** → **Connect**). **Local MCP path:** set up Google Cloud OAuth creds (same flow as Google Calendar) and run `claude mcp add gdrive -- npx -y @modelcontextprotocol/server-gdrive`. Not auto-installed by this script yet. |

> **Playwright scope note:** Microsoft explicitly says "Playwright MCP is not a security boundary." Treat anything Claude loads through it the same as any browser session you'd drive manually.

### After Step 5

Your productivity stack is wired up. Ask about your schedule, add a task, query Notion, trigger a workflow — all from your terminal. Skipped something? Re-run Step 5 later. For Obsidian vault access, install [2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging).

---

## Step 6 - Telegram

[Back to top](#quick-navigation)

This step connects Claude to Telegram so you can message it from your phone. You create a bot on Telegram using @BotFather (free, takes about 2 minutes), then the script configures it locally. After setup, you can send Claude messages, photos, and files from any device with Telegram installed. Optional, but it makes Claude accessible from your pocket.

Two launcher commands come with it (both installed back in Step 1):

- **`ctg`** — launches Claude with Telegram connected from any directory. Use this when you want to drive a regular Claude session from your phone.
- **`cbraintg`** — same as `ctg`, but also opens your 2ndBrain vault on launch. Use this when you want Claude to have vault context while answering Telegram messages. *(Requires [2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging) installed.)*

### What It Sets Up

| Component | What it does |
|-----------|--------------|
| Telegram Bot | Your personal bot created via @BotFather on Telegram |
| Bot Token | Stored locally at `~/.claude/channels/telegram/.env` |
| Access Policy | Controls who can message your bot (default: ask before accepting) |
| `ctg` command | Launch Claude with Telegram from any directory (installed in Step 1) |
| `cbraintg` command | Launch Claude with Telegram inside your 2ndBrain vault (installed in Step 1) |

### Run Step 6

> [!NOTE]
> Step 6 is interactive — it will ask you to create a bot on Telegram and paste the token. The whole process takes about 2 minutes.

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to set up Telegram: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-6/step-6-install.sh)
> ```

### After Step 8

Open a new terminal and run `ctg` to launch Claude with Telegram connected. Inside your Claude session, tell it to pair your Telegram bot. Once paired, messages you send from Telegram will appear in your Claude session in real time. You can also use `cbraintg` to launch with both Telegram and your 2ndBrain vault loaded.

> **If you see repeating `TELEGRAM_BOT_TOKEN required` warnings that won't stop:** Press **Ctrl+C** to exit. Your token isn't being detected — Claude Code keeps restarting the Telegram channel in a loop. Use `cskip` instead of `ctg` to continue setup, and troubleshoot Telegram separately later. See [Troubleshooting → Telegram: stuck in a warning loop](#telegram-stuck-in-a-warning-loop-after-setup).

---

## Step 7 - GitHub

[Back to top](#quick-navigation)

This step is the GitHub bundle — for developers who want Claude to have direct access to their repos + a skill that keeps every repo's docs in sync with its code. It's completely optional. Skip it if you don't use GitHub with Claude, and everything else still works.

### What It Installs

Two things:

- **GitHub MCP server** ([`@modelcontextprotocol/server-github`](https://github.com/modelcontextprotocol/servers/tree/main/src/github)) — Claude gets a structured tool interface for reading and writing GitHub resources: repos, issues, PRs, files, code search, branches, commits. Once it's installed, you can ask Claude things like *"list open PRs on lorecraft-io/cli-maxxing"*, *"create an issue for this bug"*, or *"search my repos for any file that uses `MORGEN_API_KEY`"* and it just works.
- **`/gitfix` skill** — a Claude Code skill that does a full-repo doc sync. Type `/gitfix` inside any Claude session and it reads every install script, skill file, and documentation file in the repo, finds every gap between the code and the docs, and fixes all of it. Use it any time you've made changes and need the README, cheatsheet, and all other docs to reflect reality.

### Before You Run It

You need a GitHub Personal Access Token (classic PAT) for the MCP part. Create one at [github.com/settings/tokens/new](https://github.com/settings/tokens/new):

- **Token name:** `claude-github-mcp`
- **Expiration:** No expiration (or pick whatever you're comfortable with)
- **Scopes:** check only `repo`, `read:org` (under `admin:org`), and `gist`

Click **Generate token** and copy the `ghp_...` value. You'll paste it into the install script.

The `/gitfix` skill needs no token — it runs locally against whatever repo you point Claude at.

### Run Step 7

```
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-7/step-7-install.sh)
```

The script prompts for your PAT, registers the GitHub MCP with Claude Code, injects the token into `~/.claude.json` (same place every other MCP credential lives), and drops the `/gitfix` skill into `~/.claude/skills/gitfix/`.

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| GitHub MCP (`@modelcontextprotocol/server-github`) | Claude Code MCP server that exposes GitHub API operations as tools — read/write repos, issues, PRs, code search, branches, commits. |
| `/gitfix` skill | Claude Code skill — full-repo doc sync. Reads every file, fixes drift between code and docs. Works on any repo, no token needed. |

### After Step 7

Ask Claude to *"list my open GitHub issues"* or *"create a PR on cli-maxxing"* and the MCP tools kick in automatically. Type `/gitfix` (or just ask *"sync the repo"* / *"fix the github"* in plain English) after any significant change to make the docs match the code again. If you ever need to rotate the PAT, re-run Step 7 — it'll overwrite the entry in your MCP config.

---

## Step 8 - Safety Check

[Back to top](#quick-navigation)

This step installs a security auditing skill that lets Claude scan any project for vulnerabilities. Exposed API keys, missing rate limiting, input sanitization gaps, dependency vulnerabilities, insecure configurations — the stuff that slips through code review. For MCP projects, it automatically activates 12 additional checks covering tool poisoning, prompt injection vectors, transport security, authentication, and supply chain attacks. You point Claude at a project and tell it to run a safety check. It does the rest.

### What It Does

The `/safetycheck` skill gives Claude a structured security audit framework. Instead of asking Claude to "look for security issues" and hoping for the best, this skill runs a systematic scan across the categories that actually matter:

**API Security (all projects):**
- **Exposed secrets.** API keys, tokens, passwords hardcoded in source files, git history, or MCP config files.
- **Missing rate limiting.** Endpoints that accept unlimited requests without throttling.
- **Input sanitization gaps.** User input flowing into queries, commands, file paths, or MCP tool handlers without validation.
- **Dependency vulnerabilities.** Known CVEs in npm/pip packages, including MCP SDK version checks.
- **Insecure configurations.** CORS misconfigurations, missing .gitignore entries, untracked secrets.

**MCP Security (auto-activated for MCP projects):**
- **Tool description integrity.** Hidden instructions, file path references, and injection markers in tool descriptions.
- **Unicode smuggling.** Invisible Unicode characters used to hide malicious instructions from human reviewers.
- **MCP transport security.** DNS rebinding vulnerabilities, HTTP vs HTTPS, known CVEs (CVE-2025-66414, CVE-2025-66416).
- **MCP authentication.** Missing bearer auth on HTTP-based MCP servers.
- **Supply chain hygiene.** `@latest` floating versions, rug-pull risk, unverified packages in MCP configs.
- **Tool response sanitization.** Stack traces and raw errors leaking through tool results.
- **Audit logging.** Missing structured logging for tool invocations.

This isn't a replacement for a full security audit. It's a first line of defense — the kind of check you should run before every deploy, every PR, every time you hand code off to someone else.

### Run Step 8

You should still have a Claude session open. If you closed it, open your terminal and type `cskip` to start a new Claude session.

Once you're inside the Claude session, paste this and hit Enter:

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to install the safety check skill: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-8/step-8-install.sh)
> ```

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| Safety Check Skill (`/safetycheck`) | A Claude Code skill that runs 8 API security checks on any project, plus 12 MCP-specific checks when an MCP project is detected. Covers tool poisoning, prompt injection vectors, DNS rebinding CVEs, supply chain attacks, and more. |

### After Step 8

Open any project in Claude and type `/safetycheck` to run a security audit. For standard projects, Claude runs 8 checks and reports findings by severity. For MCP projects, it automatically detects the project type and activates 12 additional MCP-specific checks. You can also ask Claude to "run a safety check" in plain English — the skill kicks in automatically.

---

## Final Step - Status Line

[Back to top](#quick-navigation)

This is the wrap-up step. It installs a custom status line that shows you what's active at a glance — your vault, MCP connection, design tools, and any running swarms, mini swarms, or hive-minds.

### What It Sets Up

**Status line indicators:**

| Component | What it shows |
|-----------|--------------|
| ⚡ FidgetFlo | The FidgetFlo MCP server is connected |
| 🎨 UIPro | Design skill is loaded (installed with [creativity-maxxing](https://github.com/lorecraft-io/creativity-maxxing)) |
| 🐝 Swarm | A swarm is active (shows agent count during `/fswarm`) |
| 🍯 Mini | A mini swarm is active (shows agent count during `/fmini`) |
| 👑 Hive | A hive-mind is active (during `/fhive`) |

The status line also shows your current model, session duration, and context window usage.

> **🧠 2ndBrain indicator.** This statusline lights up a 🧠 icon when your CWD is inside the Obsidian vault that [`2ndBrain-mogging`](https://github.com/lorecraft-io/2ndBrain-mogging) registered. Mogging's installer writes `~/.claude/.mogging-vault` with the vault's absolute path; this script reads that file. No mogging installed → marker doesn't exist → indicator stays hidden (everything else still works). To re-point at a different vault without re-running mogging: `echo "$NEW_VAULT" > ~/.claude/.mogging-vault`.

### Run Final Step

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to set up your status line: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-final/step-final-install.sh)
> ```

Or manually:
1. Copy `statusline.sh` to `~/.claude/statusline.sh`
2. Add to your `~/.claude/settings.json`:
```json
"statusLine": {
  "type": "command",
  "command": "~/.claude/statusline.sh"
}
```
3. Restart Claude Code

### Verify Everything Works

After the status line installs, run a quick check to make sure every command, skill, and tool from the setup was installed correctly.

> [!IMPORTANT]
> **Open a new `cskip` session and paste this:**
> ```
> Open the cheat sheet at CHEATSHEET.md in this repo and go through every command, skill, and tool listed there. For each one, verify it's installed and working on my machine. If anything is missing, broken, or not configured, fix it. Give me a summary of what passed and what you had to fix.
> ```

This tells Claude to cross-reference the cheatsheet against your actual system and fill in any gaps. It's the final sanity check — if a skill didn't install, an MCP didn't connect, or an alias didn't register, Claude will catch it and fix it right there.

> **Note:** Use `cskip` for this step, not `cbrain`. The `cbrain` command requires your Obsidian vault to exist. If you haven't run 2ndBrain-mogging yet, or if something went wrong during vault setup, `cbrain` will error out. `cskip` always works.

### After Final Step

Setup is complete. Head to **[You're Ready](#youre-ready)** below for your daily command.

---

## Troubleshooting

[Back to top](#quick-navigation)

### I ran the installer but `claude` command is not found

First install has a catch: the installer adds Homebrew, nvm, and the shell aliases to your config files, but those only load when a brand new shell starts. On top of that, the script may have been running in bash while your default shell on modern macOS is zsh — so even `source`-ing the file the script wrote can miss.

**Fix:**
1. Fully close the terminal window (Cmd+Q on Mac works too).
2. Open a fresh terminal.
3. Run `claude --version`. You should see something like `2.1.112 (Claude Code)`.

If it's still missing after a fresh terminal, paste the **Reset PATH (stuck install)** block from [CHEATSHEET.md](CHEATSHEET.md#reset-path-stuck-install) — it rewires `~/.zshrc` with Homebrew shellenv, nvm, `~/.local/bin`, and the four aliases in one shot.

### Some steps say "Homebrew not found" during install

Step 1 installs Homebrew mid-pipeline and the downstream steps in the same shell session don't see it yet — the installer hadn't refreshed PATH for subsequent commands. Known issue, fixed 2026-04-17.

**Fix:** close the terminal, open a fresh one, and re-run the installer:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/install.sh)
```
It's idempotent — anything already installed gets skipped.

### I see the zsh/bash shell prompt change after install

The installer detects your default shell and writes integrations accordingly. On modern macOS, zsh is the default even if `/etc/passwd` still says bash (Terminal.app overrides passwd with the "default login shell" preference), so you may notice your prompt looks different after a fresh terminal.

**Fix:** confirm which shell you're actually in:
```bash
echo $SHELL
```
If you want your passwd entry to match what Terminal.app uses, run:
```bash
chsh -s /bin/zsh
```
This is optional — everything works fine either way. The installer writes to both `~/.zshrc` and `~/.bashrc` so both shells pick up the aliases.

### xlsx2csv failed to install

Python 3.9 (the macOS default) ships with PEP 668 restrictions that block `pip install` into the system Python. The installer now uses `pipx` to work around this.

**Fix:** re-run Step 2:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-3/step-3-install.sh)
```
If it's still failing, install manually:
```bash
brew install pipx
pipx install xlsx2csv
```

### I want to completely remove everything

Run the uninstall script:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/uninstall.sh)
```

This removes the cli-maxxing aliases (`cskip`, `cc`, `ccr`, `ccc`), the `ctg`/`cbrain`/`cbraintg` scripts in `~/.local/bin/`, all MCP servers, skills, and breadcrumbs this setup dropped. See the [Uninstall](#uninstall) section below for the full list.

It does **not** remove Homebrew, nvm, Node.js, or Claude Code itself — those are general-purpose tools you might use outside of cli-maxxing. The uninstall script will show you how to remove them manually if you want a completely clean machine.

### Telegram: pressing Enter skips setup

This is intentional. If you press Enter without pasting a token, the script skips Telegram setup and continues. You can always re-run Step 6 later when you have your bot token ready.

### Telegram: stuck in a warning loop after setup

If you launch Claude with `ctg` or `cbraintg` and see a stream of repeating messages like `telegram channel: TELEGRAM_BOT_TOKEN required` that never stops — your bot token isn't being detected.

**What's happening:** Claude Code is trying to start the Telegram channel, the server exits immediately because there's no token, and then Claude Code restarts it — over and over. This creates an infinite loop of warning messages in your terminal.

**Fix:**
1. Press **Ctrl+C** to kill the session
2. Continue with the remaining setup steps using `cskip` (no Telegram) instead of `ctg`
3. Come back to Telegram troubleshooting later — type `cskip`, then ask Claude: *"My Telegram bot token isn't being detected — can you check my config at ~/.claude/channels/telegram/ and fix it?"*

The most common cause is the token file being missing or in the wrong format. Re-running Step 6 (`bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-6/step-6-install.sh)`) and re-entering your token usually resolves it.

### Step 5 (Productivity Tools) skips when run through the update command

Step 5 requires interactive input for API credentials. When run via `curl | bash` (including through the update command), it detects non-interactive mode and exits with instructions.

**Fix:** Run Step 5 directly in your terminal:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-5/step-5-install.sh)
```

### Obsidian MCP returns internal errors

See the [2ndBrain-mogging troubleshooting guide](https://github.com/lorecraft-io/2ndBrain-mogging#troubleshooting). The Obsidian MCP is installed and configured by 2ndBrain-mogging.

### `cbrain` says it can't find my vault

See [2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging) — vault setup is handled there. If your vault exists but isn't found, set `VAULT_PATH=/path/to/your/vault cbrain`.


### A step failed or something is missing

Run the update command to re-run everything. It skips what's already installed and fills in any gaps:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/update.sh)
```

Or open a `cskip` session and describe the problem to Claude. It can diagnose and fix most issues on the spot.

---

## You're Ready

[Back to top](#quick-navigation)

### Quick MCP Check

Before you dive into `cbrain`, take 30 seconds to verify your MCP connections are live. Open a new terminal and run:

```
cskip
```

Once you're inside Claude, type:

```
/mcp
```

This shows every MCP server and its connection status. Everything you installed — FidgetFlo, Notion, Granola, n8n, Morgen, Motion Calendar, Google Calendar, Playwright, SwiftKit, Obsidian (from 2ndBrain-mogging), design tools (from creativity-maxxing) — should show as **Connected**. If anything shows as failed or disconnected, just tell Claude:

> "One of my MCP servers isn't connecting — can you troubleshoot it?"

Claude will diagnose and fix it on the spot. Once everything is green, you're ready.

---

Everything is installed, configured, and wired together. From now on, this is the only command you need:

> [!IMPORTANT]
> **Your daily command:**
> ```
> cbrain
> ```

That's it. `cbrain` opens Claude Code directly inside your 2ndBrain vault with all permissions skipped. Your vault is your home base — every tool, skill, and MCP server you just installed is available the moment you type it.

> **Haven't run 2ndBrain-mogging yet?** Use `cskip` instead of `cbrain` until your Second Brain vault is set up. `cbrain` requires the Obsidian vault to exist — it will error if you haven't created one. Once [2ndBrain-mogging](https://github.com/lorecraft-io/2ndBrain-mogging) is complete, switch to `cbrain` as your daily driver.

**What `cbrain` gives you:**
- Drops you into your Obsidian vault automatically — no `cd`-ing around
- All permissions skipped — Claude acts immediately, no approval prompts
- Full access to everything: `/fswarm` (+ tiers `1`/`2`/`3`/`max`), `/fmini` (+ tiers `1`/`2`/`3`/`max`), `/fhive`, `/w4w`, `/safetycheck`, `/gitfix`, FidgetFlo, Context Hub, Morgen, Motion, Notion, Obsidian, Granola, n8n, design tools, video tools — all of it
- Your status line shows what's active at a glance

**When to use something else:**
- `cskip` — when you need to work outside your vault (a different project, a random folder)
- `cbraintg` — same as `cbrain` but with your Telegram channel connected
- `ctg` — skip-permissions + Telegram from any directory

But for day-to-day use? Just type `cbrain` and go.

---

## Installation Order

[Back to top](#quick-navigation)

Run the steps in this order:

| Step | Name | What it does |
|------|------|-------------|
| 1 | CLI Tools | Git, Node.js, Claude Code, shell aliases |
| 2 | Bonus Software | Ghostty (GPU-accelerated terminal) + Arc (power-user browser). Optional but recommended. |
| 3 | Developer & Utility Tools | Python, Pandoc, jq, ripgrep, no-flicker mode, etc. |
| 4 | FidgetFlo + Context Hub | Multi-agent orchestration + API docs |
| 5 | Productivity Tools | Notion + Granola + n8n + Google Calendar + Morgen + Motion Calendar + Playwright + SwiftKit (all optional — pick what you use; Morgen recommended) |
| 6 | Telegram | Telegram bot setup — message Claude from your phone. Press Enter to skip if you don't have a bot yet. |
| 7 | GitHub | GitHub MCP (repos, issues, PRs, code search — requires PAT) + `/gitfix` skill for full-repo doc sync |
| 8 | Safety Check | Security auditing — 8 API checks + 12 MCP checks for tool poisoning, DNS rebinding, supply chain attacks |
| **Final** | **Status Line** | **Status indicators + system health check** |

> **Note:** Step 5 (Productivity Tools) is all optional — install only the tools you use. Step 6 (Telegram) is optional — press Enter to skip if you don't have a bot token yet; you can always re-run it later. Step 7 (GitHub) is optional — skip it if you don't use GitHub with Claude. Step 8 (Safety Check) installs a security auditing skill — 8 standard checks for any project, plus 12 MCP-specific checks that auto-activate when an MCP project is detected. The Final Step (Status Line) is the wrap-up — it wires your status indicators and runs a system health check.

---

## Video Tutorials *(coming soon)*

[Back to top](#quick-navigation)

Video walkthroughs for every step are coming soon. These will show you exactly what to do, screen by screen, so you can follow along at your own pace.

---

## Staying Up to Date

[Back to top](#quick-navigation)

This command re-runs every step, skips anything already installed, and picks up anything new. It covers everything in this repo as of right now. If new steps get added in the future, the update command will include them too.

Open your terminal and run `cskip` to start a Claude session, then paste the update command. Or if you prefer, just paste it directly into your terminal without Claude.

> [!IMPORTANT]
> **Paste this into your terminal:**
> ```
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/update.sh)
> ```


---

## Uninstall

[Back to top](#quick-navigation)

If you need to remove everything installed by this setup, the uninstall script reverses all steps. It removes Claude Code, MCP servers, skills, shell aliases, dev tools, and brew packages. Your Obsidian vault and notes are never touched.

> [!IMPORTANT]
> **Paste this into your terminal:**
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/uninstall.sh)
> ```

**What it removes:**
- Claude Code + shell aliases (`cskip`, `cc`, `ccr`, `ccc`) and scripts (`ctg`, `cbrain`, `cbraintg` in `~/.local/bin/`)
- All MCP servers (FidgetFlo, Notion, Granola, n8n, Morgen, Motion Calendar, Playwright, SwiftKit) — Magic, YouTube Transcript, yt-dlp, Whisper, and Obsidian are managed by the companion repos
- All skills (fswarm, fmini, fhive, w4w, get-api-docs, gitfix, safetycheck) — UI/UX Pro Max, Taste Skill pack, and Remotion are managed by creativity-maxxing
- Dev tools (pandoc, jq, ripgrep, gh, tree, fzf, wget, weasyprint, ffmpeg, xlsx2csv, poppler)
- Whisper models (~/.whisper/)
- Motion Calendar config (~/.motion-mcp/)
- Google Calendar config (~/.google-calendar-mcp/)
- Arc Browser (if installed via the bonus script)
- Ghostty config (the app itself is kept — only the config file installed by this setup is removed)
- Status line config

**What it does NOT remove:**
- Homebrew, Git, Node.js (other tools may depend on these — the script shows you how to remove them manually if you want)
- Your Obsidian vault and notes
- Your Claude account

---

## More Coming Soon

[Back to top](#quick-navigation)

This setup is a living project. New steps, tools, and workflows will be added as they're ready. If you have the update command above, you'll always be able to catch up with one paste.

---

## License

MIT — see [LICENSE](LICENSE).

---

Built by [Nate Davidovich / Lorecraft](https://github.com/lorecraft-io)

[⤴ back to top](#top)
