# Client Setup

Everything you need to start working with AI-powered development tools, installed in the right order with one command per step.

## How It Works

**Script 0** sets up your machine with all the foundational tools — things like Node.js, Python, Git, and file converters. These are the building blocks that everything else depends on. It also installs Claude Code, the AI coding assistant you'll be using.

**Script 1** *(coming soon)* builds on top of Script 0 by setting up ClaudeFlow — the multi-agent orchestration layer that makes Claude Code dramatically more powerful. It can't run without the tools Script 0 installs, which is why Script 0 comes first.

Run them in order. Each one is a single command you paste into your terminal.

---

## Script 0 — Environment Setup

Sets up your machine with 15 essential development tools. Detects your operating system automatically, skips anything you already have, and installs everything else.

### macOS / Linux

Open Terminal and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/lorecraft-io/client-setup/main/script-0-install.sh | bash
```

### Windows

Open PowerShell and paste:

```powershell
irm https://raw.githubusercontent.com/lorecraft-io/client-setup/main/script-0-install.ps1 | iex
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
| Claude Code | AI coding assistant |

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

## Requirements

- **macOS** 11+ (Big Sur or later)
- **Linux** Ubuntu 20.04+ / Debian 11+ / Fedora 36+
- **Windows** 10 (1709+) or 11
- Internet connection
- Do **not** run as root or admin
