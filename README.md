# AI Superuser Setup

Everything you need to start working with AI-powered development tools, installed in the right order with one command per step.

## How It Works

**Script 0** sets up your machine with all the foundational tools — things like Node.js, Python, Git, and file converters. These are the building blocks that everything else depends on. It also installs Warp Terminal and Claude Code, the AI coding assistant you'll be using.

**Script 1** *(coming soon)* builds on top of Script 0 by setting up ClaudeFlow — the multi-agent orchestration layer that makes Claude Code dramatically more powerful. It can't run without the tools Script 0 installs, which is why Script 0 comes first.

Run them in order. Each one is a single command you paste into your terminal.

---

## Script 0 — Environment Setup

Sets up your machine with 16 essential tools. Detects your operating system automatically, skips anything you already have, and installs everything else.

### macOS / Linux

Open Terminal and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-superuser-setup/main/script-0/script-0-install.sh | bash
```

### Windows

Open PowerShell and paste:

```powershell
irm https://raw.githubusercontent.com/lorecraft-io/ai-superuser-setup/main/script-0/script-0-install.ps1 | iex
```

### What Script 0 Installs

| Tool | What it does |
|------|-------------|
| Homebrew (Mac) / winget (Win) | Installs other software for you |
| Git | Tracks and manages code changes |
| Node.js (v18+) | Runs JavaScript — needed for Claude Code |
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
| Warp Terminal | Modern terminal with Shift+Tab permissions toggle |
| Claude Code | AI coding assistant |

### Why Warp Terminal?

Script 0 installs [Warp](https://www.warp.dev) as your terminal. Here's why:

- **Shift+Tab to toggle permissions** — When Claude is running, press Shift+Tab to switch between normal mode (Claude asks before doing anything) and auto-approve mode (Claude just does it). No need to exit and relaunch.
- **Built for AI workflows** — Warp is designed around working with AI in the terminal. It handles long-running output, code blocks, and multi-step processes better than a standard terminal.
- **Works on Mac, Linux, and Windows** — Same experience everywhere.

After Script 0 finishes, **open Warp and run all future scripts from there.** You can keep using your old terminal for other things, but Warp is where Claude works best.

### After Script 0

The script will tell you to log in to Claude Code:

```bash
claude auth login
```

This opens a browser — sign in with your Anthropic account. Once that's done, you're ready for Script 1.

---

## Script 1 — ClaudeFlow Setup *(coming soon)*

Installs and configures ClaudeFlow, the multi-agent orchestration system that coordinates multiple AI agents to work on complex tasks together. Requires Script 0 to be completed first.

---

## [Cheat Sheet](CHEATSHEET.md)

Quick reference for launching Claude, useful commands, and tips. **Read this after running Script 0.**

---

## Before You Start

- Your computer needs to be from roughly **2020 or later** (macOS Big Sur+, Windows 10+, or a recent Linux)
- You need an **internet connection** — the script downloads everything live
- **Don't run it as admin/root** — just open your terminal normally and paste the command
- If anything is already installed on your machine, the script will skip it automatically
