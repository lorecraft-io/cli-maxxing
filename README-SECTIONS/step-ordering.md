## Installation Order

Run the steps in this order:

| Step | Name | What it does |
|------|------|-------------|
| 1 | CLI Tools | Git, Node.js, Claude Code, shell aliases |
| 2 | Bonus Software | Ghostty (GPU-accelerated terminal) + Arc (power-user browser). Optional but recommended. |
| 3 | Developer & Utility Tools | Python, Pandoc, jq, ripgrep, no-flicker mode, memory hook, etc. |
| 4 | FidgetFlo | Multi-agent orchestration — swarms, hives, persistent memory, Opus-locked |
| 5 | Productivity Tools | Notion + Granola + n8n + Google Calendar + Morgen + Motion Calendar + Playwright + SwiftKit + Superhuman + Google Drive + Vercel (all optional — pick what you use; Morgen recommended) |
| 6 | Telegram | Telegram bot setup — message Claude from your phone. Press Enter to skip if you don't have a bot yet. |
| 7 | GitHub | GitHub CLI (`gh`) + GitHub MCP (repos, issues, PRs, code search — MCP requires PAT) + `/gitfix` skill for full-repo doc sync |
| 8 | Safety Check | Security auditing — 8 API checks + 12 MCP checks for tool poisoning, DNS rebinding, supply chain attacks |
| **Final** | **Status Line** | **Status indicators + system health check** |

> **Note:** Step 5 (Productivity Tools) is all optional — install only the tools you use. Step 6 (Telegram) is optional — press Enter to skip if you don't have a bot token yet; you can always re-run it later. Step 7 (GitHub) is optional — skip it if you don't use GitHub with Claude. Step 8 (Safety Check) installs a security auditing skill — 8 standard checks for any project, plus 12 MCP-specific checks that auto-activate when an MCP project is detected. The Final Step (Status Line) is the wrap-up — it wires your status indicators and runs a system health check.
