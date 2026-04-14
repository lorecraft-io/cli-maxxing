# README Updates -- Post-Install Review

> **Status: COMPLETED — historical planning doc.** All recommendations below have been merged into README.md. Kept for reference. The observations about Step 6 and Granola are superseded by the 2026-04-14 Step 6 overhaul: Step 6 now installs Notion, Granola, n8n, Google Calendar, Morgen, and Motion Calendar (Obsidian MCP moved to Step 7 where the vault is set up).

This document specifies the changes recommended for README.md based on the live install test on a fresh Mac setup (vault at `~/Desktop/2ndBrain`).

**Key finding:** All 3 reported bugs from the live install have already been fixed in the current codebase. The README updates below are documentation improvements to prevent confusion for future users.

---

## Change 1: Mark Step 8 (Telegram) as Optional (More Prominent)

Step 8 is already described as optional in the body text, but the Quick Nav table and Installation Order table don't call it out. Since this is a step that requires creating an external bot and is completely unneeded for the core workflow, it should be labeled clearly.

### In the Quick Nav table (around line 22)

**Current:**
```
| [Step 8](#step-8---telegram) | Telegram | Message Claude from your phone via Telegram bot | ~2 min |
```

**Recommended:**
```
| [Step 8](#step-8---telegram) | Telegram *(optional)* | Message Claude from your phone via Telegram bot | ~2 min |
```

### In the Installation Order table (around line 1193)

**Current:**
```
| 8 | Telegram | Telegram bot setup -- message Claude from your phone |
```

**Recommended:**
```
| 8 | Telegram *(optional)* | Telegram bot setup -- message Claude from your phone. Skip if you don't use Telegram. |
```

---

## Change 2: Document Vault Path + Naming Convention

The vault detection logic searches a fixed list of candidate paths. Users who name their vault something unexpected or put it in a non-standard location will get a default path or an error. This should be documented.

### In Step 7a, after "Name it something..." (around line 853)

**Current:**
```
3. Name it something you'll remember. "2ndBrain" or "Second-Brain" or "Vault" all work fine.
4. For the location, pick somewhere easy to find. We recommend your **Desktop** or a **Documents** folder. Don't bury it deep in some random directory.
```

**Recommended:**
```
3. Name it something you'll remember. We recommend **"2ndBrain"** -- the scripts and status line look for this name by default. "Second-Brain" or "Vault" also work.
4. For the location, pick **your Desktop**. The scripts search these locations in order:
   - `~/Desktop/WORK/OBSIDIAN/2ndBrain`
   - `~/Desktop/2ndBrain` **(recommended for most people)**
   - `~/Desktop/Second-Brain`
   - `~/Desktop/Vault`
   - `~/Documents/2ndBrain`
   - `~/Documents/Second-Brain`

   If your vault is somewhere else, set the `VAULT_PATH` environment variable before running Step 7:
   ```bash
   export VAULT_PATH=~/path/to/your/vault
   ```
```

---

## Change 3: Status Line Vault Detection Note

### In the Final Step section, after the indicator table (around line 1107)

**Add this paragraph:**
```
The status line detects your vault by checking if your current working directory contains "2ndBrain", "Second-Brain", "Vault", or "MASTER" in the path. If you named your vault something else entirely, the brain indicator won't appear -- but everything still works normally. The detection is automatic and requires no configuration.
```

---

## Change 4: Add Troubleshooting Section

### Add before "You're Ready" (before line 1147)

```markdown
---

## Troubleshooting

[Back to top](#quick-nav)

### Telegram: pressing Enter skips setup

This is intentional. If you press Enter without pasting a token, the script skips Telegram setup and continues. You can always re-run Step 8 later when you have your bot token ready.

### Step 6 (Productivity Tools) skips when run through the update command

Step 6 requires interactive input for API credentials. When run via `curl | bash` (including through the update command), it detects non-interactive mode and exits with instructions.

**Fix:** Run Step 6 directly in your terminal:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-6/step-6-install.sh)
```

### Obsidian MCP returns internal errors

After Step 7d installs the Obsidian MCP server, you might see "internal error" messages when Claude tries to use it. This is usually a temporary issue with the upstream `obsidian-mcp` package.

**Fix:** Try these in order:
1. Close and reopen your Claude session (`Ctrl+C`, then `cskip` or `cbrain`)
2. Re-add the MCP server manually:
   ```bash
   claude mcp add --scope user obsidian -- npx -y obsidian-mcp ~/Desktop/2ndBrain
   ```
   (Replace with your actual vault path)
3. If it still errors, Claude can read and write files in your vault directly -- the Obsidian MCP is a convenience layer, not a hard requirement

### `cbrain` says it can't find my vault

The `cbrain` command searches a fixed list of common locations. If your vault isn't in one of these spots, set the `VAULT_PATH` environment variable:

```bash
VAULT_PATH=~/path/to/your/vault cbrain
```

Or add it permanently to your `~/.zshrc`:
```bash
export VAULT_PATH="$HOME/path/to/your/vault"
```

### Status line doesn't show the brain emoji

The brain indicator appears when your working directory contains "2ndBrain", "Second-Brain", "Vault", or "MASTER" in the path. If you named your vault something different, edit `~/.claude/statusline.sh` and update the detection pattern to include your vault name.

### General: a step failed or something is missing

Run the update command to re-run everything. It skips what's already installed and fills in any gaps:
```bash
curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/update.sh | bash
```

Or open a `cskip` session and describe the problem to Claude. It can diagnose and fix most issues on the spot.
```

---

## Change 5: Note about Granola MCP

~~The bug report mentioned "Granola MCP returned internal errors." Granola is NOT installed by any step in CLI-MAXXING.~~

**Obsolete as of 2026-04-14 Step 6 overhaul:** Granola MCP is now installed by Step 6 (option 2). It uses the HTTP transport against `https://mcp.granola.ai/mcp` and requires the Granola app to be installed and signed in locally. If the MCP returns internal errors, the fix is (1) confirm the Granola desktop app is running, and (2) `claude mcp remove granola && claude mcp add --scope user --transport http granola https://mcp.granola.ai/mcp`.
