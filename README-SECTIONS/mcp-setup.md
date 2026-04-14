## MCP Server Setup

Claude Code can connect to MCP (Model Context Protocol) servers for extended capabilities. After running Step 3 (Ruflo), the MCP server is configured automatically.

For manual MCP setup or troubleshooting, see the [Claude Code MCP documentation](https://docs.anthropic.com/en/docs/claude-code/mcp-servers).

### Verify MCP Connection

After setup, verify the MCP server is connected:
```bash
claude mcp list
```

If the Ruflo MCP server isn't showing, re-add it:
```bash
claude mcp add ruflo -- npx -y ruflo@latest
```
