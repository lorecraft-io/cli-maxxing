# Git Fix — Full Repo Sync

When this skill is invoked, perform a comprehensive audit of the current GitHub repository — reading every relevant local file, cross-referencing all documentation, and fixing every inconsistency so the repo is fully in sync.

## Invocation

This skill activates when the user types `/gitfix`, or says "gitfix", "fix the github", "sync the repo", "update the readme", "the github is out of date", or "make sure the repo matches the code".

## What This Skill Does

`/gitfix` is a full-repo consistency pass. It reads everything — install scripts, skill files, config files, the README, the cheatsheet, troubleshooting sections, tables, step descriptions, and any other documentation — and fixes every place where the docs don't match reality.

This is not a partial update. When `/gitfix` runs, every section of every doc file gets checked against the actual state of the repo.

## Execution

### Phase 1 — Understand the Repo Structure

Before reading any file, build a complete map of the repo:

1. List all top-level directories and files
2. For each `step-*/`, `bonus-*/`, `gitfix-skill/`, and other feature folders, list their contents
3. Note every install script (`*.sh`), skill file (`SKILL.md`), and documentation file (`*.md`)
4. Identify the primary documentation files: `README.md`, `CHEATSHEET.md`, `SECURITY.md`, and any files in `README-SECTIONS/` or `docs/`

Do not skip any folder. The map must be complete before Phase 2 begins.

### Phase 2 — Read Everything

Read every file that could affect documentation accuracy:

**Install scripts** — Read each `step-*/install*.sh` and `step-final/step-final-install.sh`:
- What does each step actually install?
- What commands, aliases, or scripts does it create?
- What credentials or prerequisites does it require?
- What are the exact command names (aliases, scripts in `~/.local/bin/`, etc.)?

**Skill files** — Read every `*/SKILL.md` and `~/.claude/skills/*/SKILL.md`:
- What is the skill's invocation trigger?
- What does it do?
- Which step installs it?

**The one-shot script** (`update.sh`) — Read it completely:
- Which steps does it run?
- Which steps are skipped in non-interactive mode and why?
- What does it print at the end?

**Bonus scripts** — Read `bonus-*/`:
- What do they install?
- Are they optional or required?

**Config and utility files** — Read `uninstall.sh`, any files in `docs/`, `README-SECTIONS/`, `templates/`, and `tests/` that contain documentation-relevant content.

### Phase 3 — Read All Documentation

Read the full content of every documentation file:

- `README.md` — every section: Quick Nav, overview blurbs, step-by-step sections, troubleshooting, "You're Ready", Installation Order table, Staying Up to Date, Appendix
- `CHEATSHEET.md` — every table and section
- `SECURITY.md` — verify it reflects current security practices
- Any `.md` files in `README-SECTIONS/`, `docs/`, or bonus folders

Read them fully. Do not skim.

### Phase 4 — Cross-Reference and Find Every Gap

Compare what the code actually does (Phase 2) against what the docs say (Phase 3). Find every discrepancy:

**Step descriptions** — Does the README describe each step accurately?
- Correct name and number?
- Correct description of what it installs?
- Correct time estimate?
- Correct prerequisites?

**Quick nav table** — Does it list every step, bonus, and section that exists?

**Install commands in docs** — Are all `curl` install commands accurate? Do they point to the right script paths?

**Command tables** — Does the cheatsheet list every alias, script, and command that step-1 actually installs? (`cskip`, `cc`, `ccr`, `ccc`, `ctg`, `cbrain`, `cbraintg` — check all)

**Skills table** — Does the cheatsheet list every skill? Is the "Installed in" column accurate for each?

**Step detail sections** — For each step's full section in the README:
- Do the tool descriptions match what's actually installed?
- Are the "What it does" bullet points accurate?
- Are any new tools missing?
- Are any removed tools still listed?

**Troubleshooting section** — Is every known issue documented? Are the fix instructions accurate?

**One-shot / update.sh coverage** — Does `update.sh` run every step? Are any new steps missing from it?

**Installation Order table** — Does it list every step including any added since it was last updated?

**"You're Ready" section** — Is the daily command still `cbrain`? Are the command descriptions accurate?

**CHEATSHEET auto-triggered tools table** — Does it reflect the actual MCP servers installed across all steps?

**Cross-references between docs** — Does the README point to the right section anchors? Do links resolve?

### Phase 5 — Fix Everything

Fix every gap found in Phase 4. Apply edits in this order:

1. Quick nav table — add/remove/correct entries
2. Overview blurbs — update step descriptions to match reality
3. Step detail sections — fix tool descriptions, add missing tools, remove stale ones
4. Troubleshooting — add missing issues, update stale fix instructions
5. CHEATSHEET command table — sync with actual aliases and scripts
6. CHEATSHEET skills table — add new skills, update install step references
7. CHEATSHEET auto-triggered tools — sync with actual MCP servers
8. Installation Order table — ensure all steps listed
9. "You're Ready" section — verify accuracy
10. `update.sh` — add any missing step calls, fix any stale step references
11. Any other file where a discrepancy was found

For each fix, make the edit precisely. Do not rewrite sections that are already accurate. Do not add padding or filler. Match the existing tone and formatting exactly.

### Phase 6 — Verify and Report

After all fixes are applied:

1. Re-read the modified sections to confirm edits are correct
2. Check that no new inconsistencies were introduced
3. Produce a concise summary report:

```
/gitfix complete

Fixed:
- [list each change made, one line each]

Verified (no changes needed):
- [list sections that were checked and already accurate]
```

Do not produce the report until all fixes are applied.

### Phase 7 — Push to Live

After the report is produced, check for unpushed commits:

```bash
git log origin/main..HEAD --oneline
```

If there are unpushed commits:

1. List every unpushed commit in order, oldest first, with its hash and message
2. Ask the user: **"Ready to push these X commits to main? (yes/no)"**
3. Wait for explicit confirmation before pushing
4. If confirmed: run `git push origin main`
5. Report the push result

If there are no unpushed commits, skip Phase 7 entirely — do not mention it.

Never push without asking first. Never skip listing the commits. The user must see exactly what is going out before it goes out.

## Rules

- **Read before fixing.** Never edit a file you haven't fully read in this session.
- **Precision over coverage.** A precise fix to the right line is better than a sweeping rewrite of a section.
- **Match the existing style.** Every repo has a voice. Match it. Don't introduce new formatting patterns.
- **No invented content.** If you don't know the current state of something, read the file. Don't guess.
- **Flag what you can't verify.** If something requires running a command or checking an external URL, flag it in the Watch list rather than silently skipping it.
- **Touch every section.** The value of `/gitfix` is that nothing gets missed. If a section is fine, say so in the report. If it's wrong, fix it.
