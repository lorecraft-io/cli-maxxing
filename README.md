# AI Super User Setup

Everything you need to start working with AI-powered development tools, installed in the right order with one command per step.

## How It Works

There are three scripts. Run them in order — each one builds on the last.

**Script 0** gets the bare essentials on your machine — just enough to get Claude Code (your AI assistant) and Warp Terminal (your new terminal) up and running. This is the fastest script. It needs to run first because everything else depends on it.

**Script 1** installs the rest of your development tools — file converters, search tools, and utilities that Claude will use when working on your projects. You run this from inside Warp after Script 0 is done.

**Script 2** *(coming soon)* sets up ClaudeFlow — the multi-agent orchestration layer that makes Claude dramatically more powerful.

---

## Script 0 — Get Claude Running

Installs the minimum needed to get Claude Code working on your machine. Detects your operating system automatically.

### macOS / Linux

Open Terminal and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/script-0/script-0-install.sh | bash
```

### Windows

Open PowerShell and paste:

```powershell
irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/script-0/script-0-install.ps1 | iex
```

### What Script 0 Installs

| Tool | What it does |
|------|-------------|
| Homebrew (Mac) / winget (Win) | Installs other software for you |
| Git | Tracks and manages code changes |
| Node.js (v18+) | Runs JavaScript — needed for Claude Code |
| Warp Terminal | Your new terminal (see below) |
| Claude Code | AI coding assistant |

### Why Warp Terminal?

Script 0 installs [Warp](https://www.warp.dev) as your terminal. Here's why:

- **Shift+Tab to toggle permissions** — When Claude is running, press Shift+Tab to switch between normal mode (Claude asks before doing anything) and auto-approve mode (Claude just does it). No need to exit and relaunch.
- **Built for AI workflows** — Warp is designed around working with AI in the terminal. It handles long-running output, code blocks, and multi-step processes better than a standard terminal.
- **Works on Mac, Linux, and Windows** — Same experience everywhere.

After Script 0 finishes, **close your old terminal and open Warp.** Everything from here on happens in Warp.

### After Script 0

#### 1. Open Warp

Open **Warp** (it was just installed by Script 0).

- Warp will ask you to create an account — go ahead and sign up. **The free plan is all you need.** No payment required for Warp.

#### 2. Configure Warp

Before doing anything else, change one setting:

1. Open Warp settings (**Cmd+Comma** on Mac, **Ctrl+Comma** on Windows/Linux)
2. Go to **Features**
3. The very first setting is **Default Mode** — make sure it's set to **Terminal**, not Agent

This keeps Warp acting as a normal terminal so Claude Code runs properly.

> **If you see "Agent Oz" instead of a terminal:** Press the **Esc** key. This switches you back to the normal terminal view. That's also why we changed the default to Terminal — so this doesn't keep happening.

#### 3. Set Up Your Claude Account (Do This Before Step 4)

You need a Claude account with an active subscription before you can log in. **Do this now if you haven't already** — the login in Step 4 won't work without it.

Sign up at [claude.ai](https://claude.ai).

#### Why Claude?

We use Claude because it's genuinely the best AI platform for the kind of work we do. It's not just marketing — Claude consistently outperforms other models at understanding complex instructions, writing clean code, and reasoning through multi-step problems without losing the thread.

But beyond the tech, we chose Anthropic for how they build. Their CEO Dario Amodei left OpenAI specifically to take a more responsible approach to AI development. Anthropic leads on safety research, they're transparent about what their models can and can't do, and they build tools that are designed to be genuinely helpful rather than just impressive. That philosophy shows up in how Claude actually works — it's careful, honest, and doesn't try to BS you when it doesn't know something.

In short: Claude is the smartest tool in the room, built by people who actually care about getting this right.

#### Subscription Plans

Claude Code requires a paid plan. The install is free, but to actually use it you'll need one of these:

| Plan | Cost | What you get |
|------|------|-------------|
| **Claude Pro** | $20/month | Good for getting started. Handles everyday tasks — writing code, editing files, answering questions. You'll hit usage limits if you run long sessions or do heavy back-to-back work. |
| **Claude Max 5x** | $100/month | 5x the usage of Pro. Best for people who use Claude throughout the day or run multi-step workflows. You can work for hours without hitting a wall. |
| **Claude Max 20x** | $200/month | 20x the usage of Pro. For power users running complex, long-running tasks — things like full codebase refactors, multi-agent swarms, or all-day sessions. Virtually unlimited for most people. |

**Our recommendation:** Start with **Pro** ($20/month). If you find yourself getting rate-limited or waiting for usage to reset, upgrade to Max. You'll know pretty quickly which tier fits your workflow.

#### 4. Log in to Claude Code

In Warp, paste:

```bash
claude auth login
```

This opens a browser — sign in with your Anthropic account.

#### 5. Verify it works

```bash
claude --version
```

If you see a version number, you're set. Move on to Script 1.

---

## Script 1 — Dev Tools

Installs the development tools that Claude uses when working on your projects — file converters, search tools, and utilities. You run this in Warp using `cskip` (auto-approve mode).

### Why auto-approve mode?

When Claude runs in normal mode, it asks your permission before every single action — every file it reads, every command it runs. During a setup script that installs 10+ tools, that means dozens of approval prompts. There's no sound or notification when Claude is waiting for you, so if you look away for a moment, the whole process just sits there frozen until you come back and type "y".

**Auto-approve mode (`cskip`) lets Claude run without stopping to ask.** It will install everything in one smooth pass. You can watch it work in real time — you just don't have to babysit it.

You can always switch back to normal mode later for regular work. This is just for setup.

### Run Script 1

In Warp, paste:

```bash
curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/script-1/script-1-install.sh | bash
```

**Windows** — in Warp or PowerShell:

```powershell
irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/script-1/script-1-install.ps1 | iex
```

### What Script 1 Installs

| Tool | What it does |
|------|-------------|
| Python 3 + pip | Runs Python scripts and tools |
| Pandoc | Converts documents (Word, PowerPoint → text) |
| xlsx2csv | Converts spreadsheets to readable format |
| pdftotext | Extracts text from PDFs |
| jq | Reads and edits config files |
| ripgrep | Searches code fast — used by Claude Code |
| GitHub CLI | Manage GitHub from your terminal |
| tree | Shows folder structure visually |
| fzf | Find files and commands quickly |
| wget | Downloads files from the web |

---

## Script 2 — ClaudeFlow Setup *(coming soon)*

Installs and configures ClaudeFlow, the multi-agent orchestration system that coordinates multiple AI agents to work on complex tasks together. Requires Scripts 0 and 1 to be completed first.

---

## [Cheat Sheet](CHEATSHEET.md)

Quick reference for terminal basics, launching Claude, useful commands, and tips. **Read this after running Script 0** — especially if you're new to working in a terminal.

---

## Before You Start

- Your computer needs to be from roughly **2020 or later** (macOS Big Sur+, Windows 10+, or a recent Linux)
- You need an **internet connection** — the script downloads everything live
- **Don't run it as admin/root** — just open your terminal normally and paste the command
- If anything is already installed on your machine, the script will skip it automatically
