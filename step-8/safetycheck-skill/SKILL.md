---
name: safetycheck
description: "Comprehensive security audit — scans any project for exposed API keys, missing rate limiting, input sanitization gaps, dependency vulnerabilities, and insecure configurations. Auto-activates 12 MCP-specific checks on MCP projects."
user_invocable: true
---

# Security Safety Check

When this skill is invoked, run a comprehensive security audit on the current working directory. Detect the project type automatically and run all applicable checks.

## Invocation

This skill activates when the user types `/safetycheck`, or says "run a safety check", "security audit", "safetycheck", or "check this project for security issues".

## Execution

### Step 0 — Run precheck.sh (if present)

Before any other check, look for a `scripts/precheck.sh` in the git repo root:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

If `$REPO_ROOT/scripts/precheck.sh` exists:
1. Run it: `bash "$REPO_ROOT/scripts/precheck.sh"`
2. Capture exit code and output
3. If exit code is non-zero, report each failing check as **CRITICAL** (secrets) or **HIGH** (other) in the final results table — label the source as "precheck.sh"
4. Print the precheck.sh output verbatim under a `### Precheck Results` header before the main audit begins
5. Continue with Steps 1–4 regardless of precheck result (don't abort — surface everything)

If `scripts/precheck.sh` does not exist, skip Step 0 silently.

---

### Step 1 — Detect Project Type

Determine what kind of project this is by checking for:
- `package.json` → Node.js
- `requirements.txt` / `pyproject.toml` → Python
- `*.sh` files at root → Shell scripts
- `Cargo.toml` → Rust
- `go.mod` → Go
- If none match, treat as generic and run filesystem-level checks only

**MCP Detection** — After detecting the base project type, check for MCP signals:
- `@modelcontextprotocol/sdk` or `fastmcp` in package.json dependencies
- `from mcp import` or `from mcp.server` in Python files
- `new McpServer(`, `server.tool(`, `McpServer` in JS/TS files
- `.mcp.json`, `claude_desktop_config.json`, `.cursor/mcp.json` file presence
- `@mcp.tool` decorator in Python

If MCP detected: activate Phase 0 + Checks 9-20, AND add MCP subsections to Checks 1, 3, 5, 6, 8.

Two scan modes:
- **MCP Server Mode** — codebase IS an MCP server (SDK imports, tool registrations found)
- **MCP Consumer Mode** — project has `.mcp.json` or `claude_desktop_config.json` config files

A project can be both.

### Step 2 — Run All Checks

Run each check against the current working directory. Use Grep, Read, Glob, and Bash tools. Report findings in a severity-rated table at the end.

---

#### Check 1: Exposed API Keys

Scan source files and git history for hardcoded secrets.

**Source scan** — Grep all source files for these patterns:
- `AIzaSy[a-zA-Z0-9_-]{30,}` (Firebase/Google API keys)
- `sk-[a-zA-Z0-9]{20,}` (OpenAI keys)
- `pk_live_`, `sk_live_`, `pk_test_`, `sk_test_` (Stripe keys)
- `ghp_[a-zA-Z0-9]{36}`, `gho_`, `github_pat_` (GitHub tokens)
- `AKIA[0-9A-Z]{16}` (AWS access keys)
- `xox[bpsa]-[a-zA-Z0-9-]+` (Slack tokens)
- Hardcoded `Bearer` tokens with actual values
- Any `password = "..."` or `secret = "..."` with literal values (not env vars)

Exclude: test fixtures, example files, regex patterns in security scanners, `.env.example` files with placeholder values.

**Git history scan** — Run:
```bash
git log -p --all -S "API_KEY" -S "SECRET" -S "TOKEN" -S "sk-" --max-count=30 2>/dev/null | grep -E "^\+" | grep -ivE "(process\.env|os\.environ|\.env\.example|placeholder|your_|example|test)" | head -20
```

**Tracked .env check** — Run:
```bash
git ls-files 2>/dev/null | grep -iE "\.env$"
```

**MCP Config scan** (if MCP detected) — Scan `.mcp.json`, `claude_desktop_config.json`, `.cursor/mcp.json` for hardcoded secrets in `env` blocks:
```bash
grep -rn '"env"' . --include=".mcp.json" --include="claude_desktop_config.json" 2>/dev/null | grep -iE '(sk-[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|AIzaSy[a-zA-Z0-9_-]{30,}|xox[bpsa]-[a-zA-Z0-9-]+)'
```

Check if MCP configs are tracked in git:
```bash
git ls-files 2>/dev/null | grep -iE "(\.mcp\.json|claude_desktop_config\.json)"
```

**Severity**: CRITICAL if real keys found in source, git history, or MCP config env blocks. HIGH if .env or MCP config is tracked. PASS if clean.

---

#### Check 2: Rate Limiting

**Detect endpoints** — Grep for: `express`, `fastify`, `http.createServer`, `app.listen`, `app.get(`, `app.post(`, `router.`

**If endpoints exist**, check for rate limiting:
- Grep for: `rate-limit`, `rateLimit`, `throttle`, `@upstash/ratelimit`, `bottleneck`, `p-queue`
- Check package.json dependencies for rate-limit packages

**Detect outbound APIs** — Grep for: `fetch(`, `axios`, `http.request`, `got(`
- If outbound calls exist, check for retry/backoff logic and 429 handling

Note: For MCP servers using HTTP transport, the same rate-limit checks apply to the HTTP layer.

**Severity**: HIGH if public endpoints exist without rate limiting. MEDIUM if outbound APIs lack 429 handling. N/A if no endpoints.

---

#### Check 3: Input Sanitization

Scan for dangerous patterns:
- `eval(` with non-constant arguments
- `execSync(` or `exec(` with string concatenation (not `execFileSync` with array)
- `innerHTML` assignments without `escapeHtml` or DOMPurify
- SQL queries built with string concatenation (`"SELECT * FROM " + table`)
- Template literals in URL paths with unsanitized variables: `` `/api/${userInput}` ``
- `child_process.exec(` with template literals or string concat
- `dangerouslySetInnerHTML` without sanitization
- `source` of untrusted files in shell scripts

Check for validation:
- Grep for: `zod`, `joi`, `yup`, `ajv`, `validator`, `encodeURIComponent`, `escapeHtml`, `sanitize`

**MCP Tool Handler scan** (if MCP Server Mode) — Grep for tool handlers using arguments directly without validation:
```bash
# Tool handlers passing args to dangerous sinks
grep -rniE '(args\.\w+|arguments\.\w+)' --include="*.ts" --include="*.js" --include="*.py" . | grep -E "(exec|execSync|spawn|readFile|writeFile|query|SQL|eval)"

# Tool handlers without inputSchema (missing 2nd arg in server.tool)
grep -rniE 'server\.tool\([^,]+,\s*(?:async\s*)?\(' --include="*.ts" --include="*.js" .

# No validation library when server.tool() calls exist
```

Check if any validation library (zod, joi, ajv, pydantic, BaseModel) is present when `server.tool()` calls exist.

**Severity**: CRITICAL for eval/exec with user input or unvalidated MCP tool args flowing to exec/SQL/filesystem. HIGH for unsanitized URL paths. MEDIUM for missing validation library. PASS if clean.

---

#### Check 4: RLS / Database Security

**Detect database usage** — Check package.json and source for: `supabase`, `prisma`, `drizzle`, `knex`, `sequelize`, `typeorm`, `pg`, `mysql`, `sqlite`, `mongoose`, `mongodb`

**If Supabase**: Check for migration files, look for `ENABLE ROW LEVEL SECURITY` in SQL files, check for policy definitions.

**If any database**: Check for parameterized queries vs string concatenation.

**Severity**: CRITICAL if database found without RLS/access control. HIGH if queries use string concat. N/A if no database.

---

#### Check 5: Dependency Vulnerabilities

**Node.js**: Run `npm audit --json 2>/dev/null` — parse results for high/critical vulnerabilities.
**Python**: Run `pip audit 2>/dev/null` if available.
**Check lockfile**: Verify `package-lock.json`, `yarn.lock`, or equivalent exists.
**Check outdated**: Run `npm outdated 2>/dev/null | head -10`

**MCP SDK version check** (if MCP detected):
```bash
node -e "const p=require('./package.json'); const v=p.dependencies?.['@modelcontextprotocol/sdk']||p.devDependencies?.['@modelcontextprotocol/sdk']; if(v) console.log('MCP SDK version: '+v);" 2>/dev/null
```
- TypeScript SDK < 1.4.0 → CRITICAL: CVE-2025-66414 (DNS rebinding, host header validation disabled by default)
- Python SDK (any version prior to fix) → HIGH: CVE-2025-66416 (DNS rebinding)
- Flag `@modelcontextprotocol/sdk` version 1.3.x or below

Check for typosquatted MCP packages:
```bash
grep -E '"(model-context-protocol|mcp-sdk|fast-mcp)"' package.json 2>/dev/null
```

**Severity**: CRITICAL if known high/critical vulns or vulnerable MCP SDK. MEDIUM if no lockfile. LOW if outdated packages. PASS if clean.

---

#### Check 6: Gitignore Hygiene

Read `.gitignore` and verify it includes:
- `.env` and `.env.*`
- `*.pem`, `*.key`, `*.cert`
- `node_modules/` (Node.js)
- `.DS_Store`
- IDE folders (`.vscode/`, `.idea/`)

Check for files that SHOULD be ignored but are tracked:
```bash
git ls-files 2>/dev/null | grep -iE "\.(env|pem|key|cert|p12|pfx|keystore)$"
```

If the project is published to npm, check for `files` field in package.json or `.npmignore`.

**MCP Config gitignore check** (if MCP Consumer Mode) — Verify MCP config files are in .gitignore:
```bash
git ls-files 2>/dev/null | grep -iE "(\.mcp\.json|claude_desktop_config\.json)"
```
- `.mcp.json` should be in .gitignore (may contain API keys in env blocks)
- `claude_desktop_config.json` should be in .gitignore

**Severity**: HIGH if .env or MCP config files are tracked in git. MEDIUM if *.pem/*.key missing. LOW if minor patterns missing. PASS if complete.

---

#### Check 7: CI/CD and GitHub Security

Check for:
- `.github/workflows/` directory — any CI at all?
- `.github/dependabot.yml` — automated dependency updates?
- `SECURITY.md` — vulnerability disclosure policy?
- `.github/CODEOWNERS` — code ownership rules?
- Branch protection (if `gh` CLI available): `gh api repos/{owner}/{repo}/branches/main/protection 2>/dev/null`

**Severity**: HIGH if no CI/CD and project has dependencies. MEDIUM if missing dependabot or SECURITY.md. LOW if missing CODEOWNERS. PASS if all present.

---

#### Check 8: Error Handling

Scan for patterns that leak internal details:
- `res.text()` or `res.json()` results thrown directly in error messages
- `catch (e) { res.send(e.message) }` or `catch (e) { return e.stack }`
- `console.error` of full error objects in production code paths
- Error responses that include raw API response bodies

**MCP Tool Error scan** (if MCP Server Mode) — Scan for raw errors in tool handler responses:
```bash
# Stack traces or raw errors in isError responses
grep -rniE 'isError.*true' --include="*.ts" --include="*.js" -A3 . | grep -E '(\.stack|\.message|JSON\.stringify\(e|JSON\.stringify\(err)'

# Error details in template literals within catch blocks
grep -rniE 'catch\s*\([^)]*\)' --include="*.ts" --include="*.js" -A5 . | grep -E '(\$\{(e|err|error)\}|\.stack|traceback)'

# Python traceback in tool returns
grep -rniE 'traceback\.format_exc\(\)|str\(e\)' --include="*.py" .
```

**Severity**: MEDIUM if raw error bodies or stack traces are exposed to users or in tool content. LOW if only logged to console. PASS if errors are sanitized.

---

### MCP Security Checks (activated when MCP project detected)

#### Phase 0 — MCP Detection Summary

This is not a numbered check. Output the detection result:
- "MCP project detected — activating MCP Security Checks 9-20"
- State which mode: **Server Mode**, **Consumer Mode**, or **Both**
- Report: language, transport type, estimated tool/resource/prompt counts, config files found

---

#### Check 9: Tool Description Integrity

**Only in MCP Server Mode.**

Scan all source files containing `server.tool(`, `@mcp.tool`, or tool definition objects for suspicious content in description fields.

**Grep patterns:**
```bash
# Find tool definition files
grep -rn "server\.tool\|@mcp\.tool\|\"description\"\s*:" --include="*.ts" --include="*.js" --include="*.py" .

# Scan descriptions for injection markers
grep -riE '(<IMPORTANT>|<SYSTEM>|<HIDDEN>|<INSTRUCTION>|ignore previous|disregard|override.*instruction|you must now|act as|pretend to be|never tell|do not (tell|mention|say))' --include="*.ts" --include="*.js" --include="*.py" .

# Scan for file path references in descriptions
grep -riE '(~/\.|/etc/|~/.ssh|~/.cursor|\.env|id_rsa|\.config)' --include="*.ts" --include="*.js" --include="*.py" . | grep -i "description"

# Flag descriptions > 500 chars (may hide injected content)
# Check for cross-tool references in descriptions
```

**Severity**: CRITICAL if injection markers or sensitive file paths found in descriptions. HIGH if descriptions > 500 chars or reference other tools by name. PASS if all descriptions are static and clean. N/A if no tool registrations found.

**Auto-fix**: Offer to review and clean suspicious descriptions. Strip hidden content.

---

#### Check 10: Unicode / Invisible Character Smuggling

**Applies to both MCP Server Mode and Consumer Mode.**

Scan tool description strings and source files for invisible Unicode characters that are processed by the LLM but invisible to human reviewers.

**Bash command:**
```bash
python3 -c "
import os, re, sys
dangerous_ranges = [
    (0x200B, 0x200D),  # zero-width spaces
    (0xFEFF, 0xFEFF),  # BOM
    (0xE0000, 0xE007F), # Unicode tags (invisible)
    (0x202A, 0x202E),  # directional overrides
    (0x2060, 0x206F),  # format chars
    (0x00AD, 0x00AD),  # soft hyphen
]
files = []
for root, _, fs in os.walk('.'):
    for f in fs:
        if f.endswith(('.ts','.js','.py','.json')) and 'node_modules' not in root:
            files.append(os.path.join(root,f))
found = []
for fp in files:
    try:
        content = open(fp, encoding='utf-8', errors='ignore').read()
        for i, ch in enumerate(content):
            cp = ord(ch)
            for lo, hi in dangerous_ranges:
                if lo <= cp <= hi:
                    found.append((fp, hex(cp)))
                    break
    except: pass
if found:
    for f, c in found[:10]: print(f'FOUND {c} in {f}')
else:
    print('PASS')
" 2>/dev/null
```

**Severity**: CRITICAL if Unicode tag characters (U+E0000-U+E007F) found in tool descriptions (invisible to humans, processed by LLM). HIGH for other invisible Unicode (directional overrides, zero-width chars). PASS if clean.

---

#### Check 11: Encoded Payloads in Tool Metadata

**Only in MCP Server Mode.**

Scan tool description and parameter definition strings for encoded content that could be decoded and executed by the LLM.

**Grep patterns:**
```bash
# Base64 in description fields (30+ chars of base64)
grep -rniE '[A-Za-z0-9+/]{30,}={0,2}' --include="*.ts" --include="*.js" --include="*.py" . | grep -i "description"

# Hex encoding patterns
grep -rniE '(\\x[0-9a-fA-F]{2}){4,}|0x[0-9a-fA-F]{8,}' --include="*.ts" --include="*.js" --include="*.py" .

# Decode/execute instructions in descriptions
grep -rniE '(decode|execute|eval|interpret|run this)' --include="*.ts" --include="*.js" --include="*.py" . | grep -i "description"
```

**Severity**: HIGH if Base64 or hex-encoded patterns found in tool metadata. MEDIUM if descriptions reference decoding operations. PASS if clean.

**Auto-fix**: Offer to decode and inspect suspicious strings for review.

---

#### Check 12: MCP Transport Security

**Only in MCP Server Mode.**

Verify TLS is enforced and DNS rebinding protection is active.

**Checks:**
```bash
# Check for HTTP (non-HTTPS, non-localhost) in MCP configs
grep -rniE '"url"\s*:\s*"http://' . --include=".mcp.json" --include="claude_desktop_config.json" 2>/dev/null | grep -vE '(localhost|127\.0\.0\.1|::1)'

# Check for 0.0.0.0 binding without auth
grep -rniE '(0\.0\.0\.0|host:\s*["'"'"']0\.0\.0\.0)' --include="*.ts" --include="*.js" --include="*.py" .

# Check for DNS rebinding protection
grep -rn "enableDnsRebindingProtection\|localhostHostValidation\|hostHeaderValidation\|createMcpExpressApp" --include="*.ts" --include="*.js" .

# Check MCP SDK version for DNS rebinding CVE
node -e "const v=require('./package.json').dependencies?.['@modelcontextprotocol/sdk']; if(v) console.log(v);" 2>/dev/null
```

MCP TypeScript SDK < 1.4.0 = CRITICAL: CVE-2025-66414 (DNS rebinding protection disabled by default).

**Severity**: CRITICAL for HTTP URLs to remote servers + SDK < 1.4.0. HIGH for 0.0.0.0 binding without auth or missing DNS rebinding protection. N/A for stdio-only servers.

**Auto-fix**: Offer to add `hostHeaderValidation` middleware. Offer to upgrade SDK.

---

#### Check 13: MCP Authentication

**Only in MCP Server Mode + HTTP transport detected.**

First detect HTTP transport:
```bash
grep -rn "StreamableHTTPServerTransport\|SSEServerTransport\|createMcpExpressApp\|app\.listen\|app\.post.*mcp\|app\.get.*sse" --include="*.ts" --include="*.js" .
```

If HTTP transport found, check for auth:
```bash
grep -rn "mcpAuthRouter\|requireBearerAuth\|OAuthServerProvider\|verifyAccessToken\|bearerAuth\|express-jwt\|passport\|jsonwebtoken\|jwt\.verify" --include="*.ts" --include="*.js" .
```

If HTTP transport exists but NO auth patterns found: **CRITICAL**.
If only stdio transport (StdioServerTransport): **N/A**.

**Severity**: CRITICAL if HTTP-based MCP server has no authentication. N/A for stdio-only.

**Auto-fix**: Offer to add basic bearer token auth middleware.

---

#### Check 14: Token Scope & Lifecycle

**Applies to MCP Consumer Mode.**

Check for over-privileged tokens, missing expiration, and insecure storage.

```bash
# Check for wildcard/broad OAuth scopes in MCP config or auth code
grep -rniE '(mail\.google\.com/|calendar\.google\.com/|drive\.google\.com/|scope.*\*|scope.*"all"|scope.*"full")' --include="*.ts" --include="*.js" --include="*.py" --include=".mcp.json" . 2>/dev/null

# Check for access tokens stored in plaintext
grep -rniE '("access_token"\s*:\s*"[^"]{20,}"|token\s*=\s*["'"'"'][^"'"'"']{20,})' . --include=".mcp.json" --include="claude_desktop_config.json" 2>/dev/null

# Check for long-lived tokens (no expiry)
grep -rniE '(expires_in.*86400|expires_in.*[0-9]{6,}|no.*expir|never.*expir)' --include="*.ts" --include="*.js" .
```

**Severity**: CRITICAL for plaintext access tokens in config files. HIGH for broad OAuth scopes or tokens with no expiry. PASS if scoped and rotated.

---

#### Check 15: MCP Input Schema Validation

**Only in MCP Server Mode.**

Verify all tools define and enforce input schemas.

```bash
# Find all tool registrations
grep -n "server\.tool\|@mcp\.tool\|setRequestHandler.*ListTools" --include="*.ts" --include="*.js" --include="*.py" -r .

# Check for inputSchema / validation library usage
grep -rn "inputSchema\|z\.object\|Joi\.object\|ajv\.compile\|BaseModel\|pydantic" --include="*.ts" --include="*.js" --include="*.py" .

# Check for additionalProperties: false (strict schemas)
grep -rn "additionalProperties.*false" --include="*.ts" --include="*.js" --include="*.json" .

# Unvalidated args flowing to dangerous operations
grep -rniE '(args\.\w+|arguments\.\w+)' --include="*.ts" --include="*.js" . | grep -E "(exec|execSync|spawn|readFile|writeFile|query|SQL|eval)"
```

**Severity**: CRITICAL if unvalidated args flow to exec/SQL/filesystem. HIGH if tools exist without inputSchema. MEDIUM if schemas lack constraints (no maxLength, no enum). PASS if all tools have strict schemas.

**Auto-fix**: Offer to add zod schema stubs to tool definitions.

---

#### Check 16: Tool Response Sanitization

**Only in MCP Server Mode.**

Verify tool handlers do not leak raw errors, stack traces, or internal paths in tool results.

```bash
# Raw error in isError responses
grep -rniE 'isError.*true' --include="*.ts" --include="*.js" -A3 . | grep -E '(\.stack|\.message|JSON\.stringify\(e|JSON\.stringify\(err|\$\{e\}|\$\{err\})'

# Stack traces in catch blocks returning content
grep -rniE 'catch\s*\([^)]*\)' --include="*.ts" --include="*.js" -A5 . | grep -E '(\.stack|stacktrace|traceback)'

# Full error serialization
grep -rniE 'JSON\.stringify\((e|err|error)\b' --include="*.ts" --include="*.js" .

# Python traceback in tool returns
grep -rniE 'traceback\.format_exc\(\)|str\(e\)' --include="*.py" .
```

**Severity**: MEDIUM for stack traces or raw error objects in tool responses. Same criteria as Check 8.

---

#### Check 17: CORS / Origin Validation

**Only in MCP Server Mode + HTTP transport detected.**

```bash
# Dangerous CORS: wildcard origin
grep -rniE 'cors\(\s*\)|cors\(\s*\{\s*origin\s*:\s*["'"'"']\*["'"'"']|cors\(\s*\{\s*origin\s*:\s*true' --include="*.ts" --include="*.js" .

# Wildcard Access-Control-Allow-Origin header
grep -rniE 'Access-Control-Allow-Origin.*\*' --include="*.ts" --include="*.js" .

# Python FastAPI wildcard
grep -rniE 'allow_origins\s*=\s*\["?\*"?\]' --include="*.py" .

# PASS indicators: SDK built-in protections
grep -rn "hostHeaderValidation\|localhostHostValidation\|createMcpExpressApp" --include="*.ts" --include="*.js" .
```

**Severity**: CRITICAL if `origin: '*'` combined with `credentials: true`. HIGH for `origin: '*'` on HTTP MCP server. N/A for stdio-only.

---

#### Check 18: MCP Supply Chain & Config Hygiene

**Applies to both MCP Server Mode and Consumer Mode.**

```bash
# @latest floating versions in MCP config (rug-pull risk)
grep -rniE '"@latest"|npx.*@latest' . --include=".mcp.json" --include="claude_desktop_config.json" 2>/dev/null

# npx -y without pinned version (auto-install from potentially poisoned package)
grep -rniE 'npx.*-y' . --include=".mcp.json" --include="claude_desktop_config.json" 2>/dev/null | grep -vE '@[0-9]'

# Lockfile check
ls package-lock.json yarn.lock pnpm-lock.yaml bun.lockb 2>/dev/null || echo "NO_LOCKFILE"

# files whitelist in package.json (if published MCP server)
node -e "const p=require('./package.json'); console.log(p.files ? 'HAS_FILES_WHITELIST' : 'NO_FILES_WHITELIST');" 2>/dev/null

# Shell metacharacters in MCP config args (command injection via config)
grep -rniE '"args"\s*:\s*\[' . --include=".mcp.json" --include="claude_desktop_config.json" 2>/dev/null | grep -E '[;|&\$\`]'
```

**Severity**: HIGH for `@latest` in MCP config. HIGH for no lockfile. HIGH for shell metacharacters in args arrays. MEDIUM for no files whitelist on published MCP server. PASS if pinned and locked.

**Auto-fix**: Offer to pin all @latest references to current resolved version numbers.

---

#### Check 19: Audit Logging

**Only in MCP Server Mode.**

Verify tool invocations are logged with structured data.

```bash
# Check for structured logging library
grep -rn "winston\|pino\|bunyan\|log4js\|structlog\|logging\.getLogger" . --include="package.json" --include="requirements.txt" 2>/dev/null

# Check for MCP logging notifications
grep -rn "sendLoggingMessage\|LoggingMessageNotification\|setLoggingLevel\|notifications/message" --include="*.ts" --include="*.js" .

# Check for observability integration
grep -rn "opentelemetry\|datadog\|sentry\|splunk\|elastic-apm" . --include="package.json" 2>/dev/null
```

Compare: count tool registrations (`server.tool` / `@mcp.tool`) vs structured logging references. If tools > 0 and structured logging = 0, flag it.

**Severity**: MEDIUM if MCP server has tool handlers but no structured logging. LOW if has logging but no observability integration. PASS if structured logging with audit trail.

---

#### Check 20: Rug-Pull & Tool Mutation Defense

**Applies to MCP Consumer Mode (config files present).**

Check for floating version references that enable rug-pull attacks.

```bash
# @latest in any MCP config
grep -rniE '"@latest"' . --include=".mcp.json" --include="claude_desktop_config.json" 2>/dev/null

# npx without pinned version in MCP config commands
grep -rniE '"command"\s*:\s*"npx"' . --include=".mcp.json" --include="claude_desktop_config.json" 2>/dev/null

# Verify packages have pinned versions (not @latest)
grep -rniE '@[a-z0-9-]+/[a-z0-9-]+' . --include=".mcp.json" --include="claude_desktop_config.json" 2>/dev/null | grep -v '@[0-9]' | grep -v '@latest'

# Check if any MCP server hashes tool definitions (integrity verification)
grep -rn "createHash\|sha256\|sha-256\|integrity\|checksum" --include="*.ts" --include="*.js" . | grep -iE "(tool|description|schema)"
```

**Severity**: HIGH for `@latest` floating versions. MEDIUM for unpinned packages without `@latest`. LOW if no hash/integrity verification for tool definitions (informational). PASS if all pinned with lockfile.

**Auto-fix**: Offer to pin all @latest references to current version numbers.

---

### Step 3 — Report Findings

Output a markdown table:

```
| # | Check | Status | Findings |
|---|-------|--------|----------|
| 1 | Exposed API Keys | PASS/CRITICAL/HIGH/MEDIUM/LOW | Details... |
| 2 | Rate Limiting | ... | ... |
| ... | ... | ... | ... |
```

For MCP projects, split into two tables: **Core Checks** (1-8) and **MCP-Specific Checks** (9-20).

MCP checks show N/A if project is not an MCP project.

Then list specific findings with file paths and line numbers.

### Step 4 — Offer Fixes

For each finding that has an auto-fixable solution, offer to fix it:
- Missing .gitignore patterns → offer to add them
- Missing SECURITY.md → offer to create one
- Missing dependabot.yml → offer to create one
- execSync with string concat → offer to replace with execFileSync
- Missing input validation → offer to add validation functions

**MCP-specific fixes:**
- Pinning @latest versions → offer to look up current versions and pin them
- Missing DNS rebinding protection → offer to add hostHeaderValidation middleware
- Missing inputSchema → offer to add zod schema to tool definitions
- Hardcoded secrets in .mcp.json → offer to move to environment variable references
- HTTP without auth → offer to add bearer token auth middleware
- MCP config tracked in git → offer to add to .gitignore

Ask the user before making any changes.
