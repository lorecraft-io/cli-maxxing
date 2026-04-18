# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| latest  | Yes       |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do NOT open a public GitHub issue.**
2. Email: nate@lorecraft.io
3. Include: description of the vulnerability, steps to reproduce, and potential impact.
4. You will receive acknowledgment within 48 hours.

## Credential Handling

CLI-MAXXING install scripts collect API credentials interactively. Some are persisted to local `.env` files with restrictive permissions (`chmod 700` dir, `chmod 600` file); the rest live inside Claude Code's MCP config via `claude mcp add -e`. Credentials are never committed to this repository.

**Persisted to `.env` files (edit by re-running the step):**
- Motion Calendar: `~/.motion-mcp/.env` — Motion API key, Firebase API key, Firebase refresh token, Motion user ID
- Google Calendar: `~/.google-calendar-mcp/.env` — Google OAuth Client ID and Client Secret
- Telegram Bot: `~/.claude/channels/telegram/.env` — Telegram bot token

**Stored inside Claude Code's MCP config (revoke via `claude mcp remove <name>` then re-run the step):**
- Notion: integration token (via `-e NOTION_TOKEN`)
- Morgen: API key and timezone (via `-e MORGEN_API_KEY`, `-e MORGEN_TIMEZONE`)
- n8n (user's own instance): optional Bearer token (via `-H "Authorization: Bearer ..."`)

**No credentials collected by this repo:**
- Granola: auth is handled by the Granola desktop app, not by this script.
- Playwright (`@playwright/mcp`): no API keys or tokens. Any web-app credentials Claude uses through Playwright are typed into the separate Chromium instance it launches and are stored inside Playwright's own user-data directory, independent of this repo.

**Revocation:** run `./uninstall.sh` to remove every MCP server and wipe both the local `.env` files and the MCP-config entries. For individual removal, use `claude mcp remove <name>` and delete the relevant `~/.<tool>-mcp/.env` directory.

## Playwright MCP — Scope Note

Playwright MCP launches a real Chromium browser instance that Claude can drive (navigate, click, type, screenshot, read accessibility-tree snapshots). Per Microsoft's own guidance, **Playwright MCP is not a security boundary** — treat any page Claude opens through it with the same trust model as any browser tab you'd drive manually. In particular:

- Claude can load, follow, and interact with any URL you ask it to. Prompt injection in page content can influence Claude's next actions just like any other untrusted input.
- Authenticated sessions Claude creates inside the Playwright Chromium instance persist in Playwright's own user-data directory, not in your normal browser profile.
- Playwright MCP does not sandbox the sites it visits beyond what Chromium itself provides; it is built for productivity, not for isolating hostile content.

If you want Claude to automate a sensitive web app (banking, admin consoles, financial actions), drive it yourself or approve each step manually — don't hand Playwright a blank check.

## Scope

- Shell scripts in this repository
- Installation workflows
- GitHub Actions workflows
