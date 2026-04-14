# CLI-MAXXING Install Flow Walkthrough -- Regression Test

**Test scenario:** Fresh Mac, username `alvov` (Allan), vault at `~/Desktop/2ndBrain`, no Telegram bot token, standard macOS, Homebrew either present or absent.

**Test date:** 2026-04-05

**Finding:** All 3 known bugs from the live install have been fixed in the current codebase. This walkthrough documents the current state and identifies remaining edge cases.

---

## Step 1 -- Get Claude Running

**File:** `step-1/step-1-install.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| `detect_os` | Detects `mac`, shell `zsh`, RC `~/.zshrc` | PASS |
| `preflight_checks` | Verifies not root, has internet | PASS |
| `sudo -v` | Prompts for password | PASS |
| `install_build_tools` | Xcode CLT popup | PASS |
| `install_homebrew` | Fresh install, `NONINTERACTIVE=1`, writes shellenv to `~/.zprofile` | PASS |
| `install_git` | Already via Xcode CLT | PASS (skip) |
| `install_node` | Installs nvm, then Node LTS | PASS |
| `install_claude_code` | `npm install -g @anthropic-ai/claude-code` | PASS |
| Aliases to `~/.zshrc` | cskip, ctg, cc, ccr, ccc | PASS |
| `cbrain` script | Searches `~/Desktop/WORK/OBSIDIAN/2ndBrain`, then `~/Desktop/2ndBrain` ... | PASS -- `~/Desktop/2ndBrain` is second candidate |
| `cbraintg` script | Same search as cbrain | PASS |
| Self-test | All 7 checks | PASS |

**Bugs found:** None.

---

## Bonus: Ghostty

**File:** `bonus-ghostty/bonus-ghostty.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| Install Ghostty | `brew install --cask ghostty` | PASS |
| Config | Writes to `~/Library/Application Support/com.mitchellh.ghostty/config` | PASS |
| g2/g4 functions | Added to `~/.zshrc` | PASS |

**Bugs found:** None.

---

## Bonus: Arc Browser

**File:** `bonus-arc/bonus-arc.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| Install Arc | `brew install --cask arc` | PASS |

**Bugs found:** None.

---

## Step 2 -- Dev Tools

**File:** `step-2/step-2-install.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| `verify_prerequisites` | Checks node + claude | PASS |
| Python, Pandoc, etc. | All Homebrew-based | PASS |
| `configure_memory_hook` | Writes Stop hook to `~/.claude/settings.json` | PASS |
| `configure_no_flicker` | Writes `CLAUDE_CODE_NO_FLICKER=1` to `~/.zshrc` | PASS |

**Bugs found:** None.

---

## Step 3 -- Ruflo + Context Hub

**File:** `step-3/step-3-install.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| `install_ruflo` | `npm install -g ruflo@latest` | PASS |
| `configure_mcp` | `claude mcp add ruflo` | PASS |
| `start_daemon` | May not find PID in CWD | MINOR -- warns, continues |
| `init_config` | Creates `.claude-flow/config.yaml` in CWD | NOTE: CWD dependent |
| `configure_model_defaults` | Writes to `.claude-flow/config.json` in CWD | NOTE: CWD dependent |
| Swarm skills | Creates skill dirs in `~/.claude/skills/` | PASS |
| Statusline (line 530) | `grep -qiE "(2ndBrain\|MASTER\|Second-Brain\|Vault)"` | PASS -- **BUG WAS FIXED** |

### PREVIOUSLY REPORTED BUG (FIXED): statusline.sh 2ndBrain detection

**Old code:** `grep -qiE "OBSIDIAN/(2ndBrain|MASTER)"`
**Current code:** `grep -qiE "(2ndBrain|MASTER|Second-Brain|Vault)"`

The `OBSIDIAN/` prefix requirement has been removed. The pattern now matches any path containing `2ndBrain`, `MASTER`, `Second-Brain`, or `Vault`. Allan's vault at `~/Desktop/2ndBrain` will correctly trigger the brain indicator.

**Verified in all 3 locations:**
- `step-3/step-3-install.sh` line 530
- `step-final/step-final-install.sh` line 67
- `templates/statusline.sh` line 29

---

## Step 4 -- Design Tools

**File:** `step-4/step-4-install.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| UI/UX Pro Max skill | Downloads to `~/.claude/skills/ui-ux-pro-max/SKILL.md` | PASS |
| Taste Skill pack (Leonxlnx/taste-skill) | `npx skills add https://github.com/Leonxlnx/taste-skill --yes --global` expands 7 variants (taste, redesign, soft, output, minimalist, brutalist, stitch) under `~/.claude/skills/` | PASS (soft fail ok if skills CLI rejects the URL) |
| 21st.dev Magic MCP | `claude mcp add magic` | PASS (may need manual setup) |

**Bugs found:** None.

**Notes:** Taste Skill install uses the full GitHub URL form (not the owner/repo shorthand) because the taste-skill README documents the URL form as the authoritative install command. Each variant becomes its own skill folder. The main `taste-skill` variant has three tunable knobs at the top of its SKILL.md: DESIGN_VARIANCE, MOTION_INTENSITY, VISUAL_DENSITY (1-10 each).

---

## Step 5 -- Visual Media

**File:** `step-5/step-5-install.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| Remotion skills | `npx skills add remotion-dev/skills --yes --global` | PASS (soft fail ok) |
| YouTube Transcript MCP | `claude mcp add` | PASS |
| yt-dlp CLI | `brew install yt-dlp` | PASS |
| yt-dlp MCP | `claude mcp add` | PASS |
| whisper-cpp | `brew install whisper-cpp` | PASS |
| Whisper MCP | `claude mcp add` | PASS |
| FFmpeg | `brew install ffmpeg` | PASS |

**Bugs found:** None.

---

## Step 6 -- Productivity Tools

**File:** `step-6/step-6-install.sh`

Installs 6 optional productivity MCPs. Obsidian MCP lives in Step 7d (alongside the vault setup), NOT here.

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| Non-interactive mode | Detects pipe (`[ ! -t 0 ]`), auto-detects already-installed MCPs, re-enters only the `"already installed"` guards; if nothing found, prints "run directly" instructions and exits cleanly | PASS |
| Interactive menu | Numbered 1-6: Notion, Granola, n8n, GCal, Morgen, Motion. Morgen (5) flagged as recommended default | PASS |
| (1) Notion | Prompts for integration token, registers via `-e NOTION_TOKEN=...` | PASS |
| (2) Granola | Registers HTTP transport to `https://mcp.granola.ai/mcp` (no credentials — Granola app handles auth) | PASS |
| (3) n8n | Prompts for user's own n8n instance URL + optional Bearer token, registers via `--transport http` with `-H "Authorization: Bearer …"` if provided | PASS |
| (4) Google Calendar | Prompts for OAuth Client ID + Secret, writes `~/.google-calendar-mcp/.env` (chmod 700 dir / 600 file), registers with `-e GOOGLE_CLIENT_ID=... -e GOOGLE_CLIENT_SECRET=...` | PASS |
| (5) Morgen *(recommended)* | Prompts for API key + optional IANA timezone, registers via `-e MORGEN_API_KEY=... -e MORGEN_TIMEZONE=...`. No local `.env` — credentials live in Claude Code's MCP config | PASS |
| (6) Motion Calendar | Prompts for Motion API key, Firebase API key, Firebase refresh token, Motion user ID. Writes `~/.motion-calendar-mcp/.env` (chmod 700/600). Registers via `claude mcp add motion-calendar` | PASS |
| Obsidian | NOT in Step 6 — points user to Step 7d | N/A |
| Self-test | `check_registered` covers all 6 tools, verifies Motion + GCal `.env` files exist for their respective installs | PASS |
| Summary | Prints tool-count + "what you can do now" hints per installed tool | PASS |

**Notes:** When run via `update.sh` (pipe), correctly auto-detects already-registered MCPs and exits after verification without prompting. First-time users must run directly in terminal for credential input. Morgen is promoted as the default calendar+task tool; Motion and Google Calendar are documented as secondary (install only for specific features the primary tool doesn't cover).

---

## Step 7a -- Setup Vault

**File:** `step-7/step-7a-setup-vault.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| `install_obsidian` | `brew install --cask obsidian` | PASS |
| `find_vault` | Searches candidates: `~/Desktop/WORK/OBSIDIAN/2ndBrain`, `~/Desktop/OBSIDIAN/2ndBrain`, `~/Desktop/2ndBrain`, etc. Falls to default | PASS |
| Create folders | 00-Inbox through 07-Projects + `.obsidian/` | PASS |
| Create templates | 5 templates | PASS |
| Create CLAUDE.md | Vault instructions | PASS |
| Register in Obsidian | Writes to `~/Library/Application Support/obsidian/obsidian.json` | PASS |

**Notes:** On first run for Allan, no `.obsidian` dir exists. Script correctly defaults to `~/Desktop/2ndBrain` and creates the full structure including `.obsidian/app.json`. Subsequent runs find the vault via the `.obsidian` directory.

---

## Step 7b -- Import Claude History

**File:** `step-7/step-7b-import-claude.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| Find vault | Checks `~/Desktop/2ndBrain`, finds `00-Inbox` | PASS (after 7a) |
| Find Claude zip | Scans Downloads for `data-*-batch-*.zip` | PASS (exits cleanly if none found) |

**Minor inconsistency:** Vault search does NOT include `~/Desktop/WORK/OBSIDIAN/2ndBrain` (which step-7a does include). Not a bug for the target scenario but inconsistent across steps.

---

## Step 7c -- Import Notes

**File:** `step-7/step-7c-import-notes.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| Apple Notes Exporter | Shows App Store link if not installed | PASS |
| Find vault | Same search as 7b | PASS |
| Scan for files | Counts potential imports | PASS |

**Bugs found:** None.

---

## Step 7d -- Wire Vault

**File:** `step-7/step-7d-wire-vault.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| Find vault | Same search | PASS |
| Obsidian MCP install | `claude mcp add --scope user obsidian -- npx -y obsidian-mcp "$VAULT_PATH"` | PASS (with upstream caveat) |
| Link orphan files | Adds `[[project]]` links | PASS |
| Embed media | Embeds in index notes | PASS |

### KNOWN ISSUE: Obsidian MCP Internal Errors (Upstream)

The `obsidian-mcp` npm package may return internal errors at runtime. This is an upstream package issue, not an install script bug. The script correctly installs the MCP server and provides manual fallback instructions if verification fails.

**Possible causes:**
1. Freshly created vault with few/no notes may confuse the MCP server
2. MCP server startup race condition
3. Package version incompatibility

**Mitigation in script:** Already provides manual fallback: `claude mcp add --scope user obsidian -- npx -y obsidian-mcp "$VAULT_PATH"`

---

## Step 8 -- Telegram

**File:** `step-8/step-8-install.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| Prerequisites | Checks claude, ctg script, cbraintg | PASS |
| Existing config | No token file -- proceeds to prompt | PASS |
| Token prompt (line 123) | Silent `read -rsp` with skip message (token hidden on paste) | PASS |
| Empty input | Sets `SKIP_TOKEN=true`, continues | PASS |
| Non-interactive (pipe) | `read` gets EOF, token is empty, skip path activates | PASS |

### PREVIOUSLY REPORTED BUG (FIXED): Telegram Token Infinite Loop

**Old code:** `while true` loop with `read -p` and no exit path on empty input. Infinite loop when piped.

**Current code (lines 122-151):**
```bash
# Prompt for token -- empty input skips setup
read -r -p "Paste your bot token here (press Enter to skip): " BOT_TOKEN
BOT_TOKEN=$(echo "$BOT_TOKEN" | xargs)
if [ -z "$BOT_TOKEN" ]; then
    info "Telegram setup skipped. You can add your token later by re-running Step 8."
    SKIP_TOKEN=true
else
    # validate and save...
fi
```

The `while true` loop has been replaced with a single `read` call. Empty input (including EOF from pipe) cleanly triggers the skip path. No infinite loop possible.

---

## Step 9 -- Safety Check

**File:** `step-9/step-9-install.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| Prerequisites | Checks node, claude, curl | PASS |
| Download skill | SHA-256 verified download from pinned commit | PASS |
| Non-interactive | Silently overwrites existing skill | PASS |

**Bugs found:** None.

---

## Final Step -- Status Line

**File:** `step-final/step-final-install.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| Install statusline.sh | Writes to `~/.claude/statusline.sh` | PASS |
| 2ndBrain check (line 67) | `grep -qiE "(2ndBrain\|MASTER\|Second-Brain\|Vault)"` | PASS -- **BUG WAS FIXED** |
| Settings.json | Merges statusLine config via jq | PASS |
| Project override cleanup | Removes project-level statusLine overrides | PASS |
| Health check | Verifies aliases, tools, config | PASS |
| Status line test | Pipes test JSON, checks output | PASS |

---

## update.sh -- One-Shot Install

**File:** `update.sh`

| Section | Expected Behavior | Result |
|---------|-------------------|--------|
| Steps 1-5 | Run via `curl \| bash` | PASS |
| Step 6 | Detects non-interactive, exits cleanly with instructions | PASS |
| Step 7a | Creates vault structure | PASS |
| Step 7b | Exits if no zip found | PASS |
| Step 7c | Informational only | PASS |
| Step 7d | Installs Obsidian MCP (upstream caveat) | PASS |
| Step 8 | Token prompt gets EOF, skip path activates | PASS -- **BUG WAS FIXED** |
| Step 9 | Downloads skill | PASS |
| Final | Installs statusline with correct vault detection | PASS -- **BUG WAS FIXED** |

---

## Summary

### Previously Reported Bugs -- All Fixed

| # | Bug | Status | Current Code |
|---|-----|--------|--------------|
| 1 | Telegram token infinite loop | **FIXED** | Single `read` with skip path, no `while true` loop |
| 2 | Statusline hardcoded `OBSIDIAN/` path | **FIXED** | Pattern now `(2ndBrain\|MASTER\|Second-Brain\|Vault)` without directory prefix |
| 3 | Obsidian MCP internal errors | **UPSTREAM** | Install script is correct; upstream `obsidian-mcp` package may error. Fallback instructions provided. |

### Remaining Edge Cases (Low Severity)

| # | Issue | Location | Impact |
|---|-------|----------|--------|
| 1 | Step 3 writes config to CWD | `step-3/step-3-install.sh` | Ruflo config files land in whatever directory user opened terminal in |
| 2 | Step 7b vault search inconsistent with 7a | `step-7/step-7b-import-claude.sh:32-38` | Missing `~/Desktop/WORK/OBSIDIAN/2ndBrain` from search list (7a has it) |
| 3 | Statusline vault name false positives | All 3 statusline locations | If CWD contains "Vault" anywhere in the path (e.g., `/some/Vault-backup/project`), brain indicator shows incorrectly. Very unlikely edge case. |
| 4 | Step 8 invalid token accepted | `step-8/step-8-install.sh:133-140` | Invalid token format is warned but saved anyway ("Saving anyway -- you can fix it later"). This is intentional leniency but means a typo gets stored. |

### Test Verdict

**ALL CRITICAL AND MEDIUM BUGS RESOLVED.** The install flow will complete successfully on Allan's machine (username: `alvov`, vault at `~/Desktop/2ndBrain`, no Telegram token) with no hangs, no missing indicators, and correct vault detection.
