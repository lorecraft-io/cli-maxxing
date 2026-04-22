## MCP Server Setup

Claude Code connects to MCP (Model Context Protocol) servers for extended capabilities. Three steps in the install sequence add MCP servers:

- **Step 4 (FidgetFlo)** — adds the FidgetFlo MCP server automatically. This gives Claude its multi-agent orchestration, swarm tools, and persistent memory.
- **Step 5 (Productivity Tools)** — interactive menu, pick what you use: Notion, Granola, n8n, Google Calendar, Morgen (recommended), Motion Calendar, Playwright, SwiftKit, Superhuman, Google Drive, Vercel. All optional, all wired automatically when you select them.
- **Step 7 (GitHub)** — installs the GitHub CLI (`gh` terminal binary, no credentials required — run `gh auth login` once after install) and adds the GitHub MCP server (requires a Personal Access Token). Together they give Claude access to repos, issues, PRs, and code search via both the `gh` binary in Bash and direct tool calls. Also installs the `/gitfix` skill for full-repo doc sync.

For manual MCP setup or troubleshooting, see the [Claude Code MCP documentation](https://docs.anthropic.com/en/docs/claude-code/mcp-servers).

### Verify MCP Connections

After setup, list all registered MCP servers:
```bash
claude mcp list
```

If the FidgetFlo MCP server isn't showing, re-add it:
```bash
claude mcp add fidgetflo -- npx -y fidgetflo@latest
```

For productivity tools or GitHub MCP, re-run the relevant step script — each installer auto-detects what's already registered and skips it.
