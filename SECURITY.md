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
- Motion Calendar: `~/.motion-calendar-mcp/.env` — Motion API key, Firebase API key, Firebase refresh token, Motion user ID
- Google Calendar: `~/.google-calendar-mcp/.env` — Google OAuth Client ID and Client Secret
- Telegram Bot: `~/.claude/channels/telegram/.env` — Telegram bot token

**Stored inside Claude Code's MCP config (revoke via `claude mcp remove <name>` then re-run the step):**
- Notion: integration token (via `-e NOTION_TOKEN`)
- Morgen: API key and timezone (via `-e MORGEN_API_KEY`, `-e MORGEN_TIMEZONE`)
- n8n (user's own instance): optional Bearer token (via `-H "Authorization: Bearer ..."`)
- Obsidian: no credentials — vault path only, passed as a positional argument

**Revocation:** run `./uninstall.sh` to remove every MCP server and wipe both the local `.env` files and the MCP-config entries. For individual removal, use `claude mcp remove <name>` and delete the relevant `~/.<tool>-mcp/.env` directory.

## Scope

- Shell scripts in this repository
- Installation workflows
- GitHub Actions workflows
