#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Final Step — Status Line
# Installs the custom status line that shows what's active at a glance
# Run after all other steps are complete
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail()    { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

# -----------------------------------------------------------------------------
# source_runtime_path — load brew/nvm/~/.local/bin into current PATH so that
# health checks (node, claude, jq, etc.) see what's actually installed on disk
# even if the parent shell never sourced its rc files. Idempotent.
# -----------------------------------------------------------------------------
source_runtime_path() {
    # 1. Homebrew shellenv (macOS + Linuxbrew) — adds brew-managed bins to PATH
    if command -v brew &>/dev/null; then
        eval "$(brew shellenv)" 2>/dev/null || true
    elif [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
    elif [ -x "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
    elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
    fi

    # 2. nvm — source the script so `node` / `claude` (if installed via npm -g
    # under a node version) become visible in this shell
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck disable=SC1091
        \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
    fi

    # 3. Prepend ~/.local/bin to PATH (idempotent — skip if already present)
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
}

# Refresh PATH before any health check so we see commands that were installed
# in earlier steps but haven't been picked up by this shell yet.
source_runtime_path

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Final Step — Status Line${NC}"
echo -e "${BLUE}  Final config — status indicators + system health check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check jq is available (needed for status line)
if ! command -v jq &>/dev/null; then
    warn "jq not found — install it with: brew install jq (or run Step 2)"
fi

# Create .claude directory if it doesn't exist
mkdir -p "$HOME/.claude"

# Install statusline.sh
info "Installing status line script..."
cat > "$HOME/.claude/statusline.sh" << 'STATUSLINE_EOF'
#!/bin/bash
# Status Line — real state only
# 2ndBrain (Obsidian) + fidgetflo (MCP) + UIPro + Swarm/Hive activity

input=$(cat)

# Parse Claude Code's JSON input
MODEL=$(echo "$input" | jq -r '.model.display_name // "Opus 4.6"' 2>/dev/null)
CTX=$(echo "$input" | jq -r '.context_window.used_percentage // 0' 2>/dev/null | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0' 2>/dev/null)
CWD=$(echo "$input" | jq -r '.workspace.current_dir // ""' 2>/dev/null)

# Format duration
if [ "$DURATION_MS" != "0" ] && [ "$DURATION_MS" != "null" ]; then
  SECS=$((${DURATION_MS%.*} / 1000))
  MINS=$((SECS / 60))
  REMAINING_SECS=$((SECS % 60))
  if [ "$MINS" -gt 0 ]; then
    TIME_FMT="${MINS}m${REMAINING_SECS}s"
  else
    TIME_FMT="${SECS}s"
  fi
else
  TIME_FMT="0s"
fi

# --- fidgetflo CHECK ---
fidgetflo=""
if pgrep -f "fidgetflo.*mcp" >/dev/null 2>&1 || pgrep -f "fidgetflo/bin/cli" >/dev/null 2>&1 || pgrep -f "fidgetflo" >/dev/null 2>&1; then
  fidgetflo="⚡️ fidgetflo"
fi

# --- UIPRO CHECK (always on — global skill) ---
UIPRO="🎨 UIPro"

# --- SWARM CHECK (only shows when actively running) ---
# Lock file is written by /fswarm skill, removed on completion.
# Agents run as Claude Code subprocesses (not CLI), so pgrep won't find them.
# Auto-clean lock files older than 30 min as stale.
SWARM=""
SWARM_LOCK="/tmp/fidgetflo-swarm-active"
if [ -f "$SWARM_LOCK" ] 2>/dev/null; then
  if [ "$(find /tmp -maxdepth 1 -name 'fidgetflo-swarm-active' -mmin +30 2>/dev/null)" ]; then
    rm -f "$SWARM_LOCK" 2>/dev/null
  else
    AGENT_COUNT=$(cat "$SWARM_LOCK" 2>/dev/null || echo "")
    if [ -n "$AGENT_COUNT" ]; then
      SWARM="🐝 ${AGENT_COUNT}"
    else
      SWARM="🐝"
    fi
  fi
fi

# --- HIVE CHECK (only shows when actively running) ---
# Same approach — trust lock file, auto-clean after 30 min.
HIVE=""
HIVE_LOCK="/tmp/fidgetflo-hive-active"
if [ -f "$HIVE_LOCK" ] 2>/dev/null; then
  if [ "$(find /tmp -maxdepth 1 -name 'fidgetflo-hive-active' -mmin +30 2>/dev/null)" ]; then
    rm -f "$HIVE_LOCK" 2>/dev/null
  else
    HIVE="👑 Hive"
  fi
fi

# --- MINI CHECK (only shows when actively running) ---
# Same approach — trust lock file, auto-clean after 30 min.
MINI=""
MINI_LOCK="/tmp/fidgetflo-mini-active"
if [ -f "$MINI_LOCK" ] 2>/dev/null; then
  if [ "$(find /tmp -maxdepth 1 -name 'fidgetflo-mini-active' -mmin +30 2>/dev/null)" ]; then
    rm -f "$MINI_LOCK" 2>/dev/null
  else
    MINI_AGENT_COUNT=$(cat "$MINI_LOCK" 2>/dev/null || echo "")
    if [ -n "$MINI_AGENT_COUNT" ]; then
      MINI="🍯 ${MINI_AGENT_COUNT}"
    else
      MINI="🍯"
    fi
  fi
fi

# --- BUILD THE LINE ---
PARTS=""
if [ -n "$fidgetflo" ]; then
  PARTS="${fidgetflo}"
fi

if [ -n "$PARTS" ]; then
  PARTS="${PARTS} + ${UIPRO}"
else
  PARTS="${UIPRO}"
fi

# Swarm, Hive, or Mini activity
ACTIVITY=""
if [ -n "$SWARM" ]; then
  ACTIVITY="${SWARM}"
fi
if [ -n "$HIVE" ]; then
  [ -n "$ACTIVITY" ] && ACTIVITY="${ACTIVITY} + "
  ACTIVITY="${ACTIVITY}${HIVE}"
fi
if [ -n "$MINI" ]; then
  [ -n "$ACTIVITY" ] && ACTIVITY="${ACTIVITY} + "
  ACTIVITY="${ACTIVITY}${MINI}"
fi
if [ -n "$ACTIVITY" ]; then
  PARTS="${PARTS} [${ACTIVITY}]"
fi

echo "${PARTS} • ${MODEL} • ⏱ ${TIME_FMT} • ${CTX}% ctx"
STATUSLINE_EOF

chmod +x "$HOME/.claude/statusline.sh"
success "Status line script installed at ~/.claude/statusline.sh"

# Configure settings.json (MERGE, don't overwrite)
info "Configuring Claude Code settings..."
SETTINGS_FILE="$HOME/.claude/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    # Check if statusLine already configured
    if grep -q '"statusLine"' "$SETTINGS_FILE" 2>/dev/null; then
        success "Status line already configured in settings.json"
    else
        # Use jq to merge if available, otherwise warn
        if command -v jq &>/dev/null; then
            jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
            success "Status line added to settings.json"
        else
            warn "jq not available — add this to your ~/.claude/settings.json manually:"
            echo '  "statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}'
        fi
    fi
else
    # Create minimal settings.json
    cat > "$SETTINGS_FILE" << 'SETTINGS_EOF'
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
SETTINGS_EOF
    success "Created settings.json with status line config"
fi

# =============================================================================
# Clean up project-level statusLine overrides
# Ruflo/claude-flow init can write a verbose statusLine into project .claude/settings.json
# files, which overrides our clean global statusline. Remove any we find.
# =============================================================================
info "Checking for project-level statusLine overrides..."
FOUND_OVERRIDES=0
while IFS= read -r PROJECT_SETTINGS; do
    if command -v jq &>/dev/null && jq -e '.statusLine' "$PROJECT_SETTINGS" &>/dev/null 2>&1; then
        jq 'del(.statusLine)' "$PROJECT_SETTINGS" > "${PROJECT_SETTINGS}.tmp" \
            && mv "${PROJECT_SETTINGS}.tmp" "$PROJECT_SETTINGS"
        warn "Removed statusLine override from: $PROJECT_SETTINGS"
        FOUND_OVERRIDES=$((FOUND_OVERRIDES + 1))
    fi
done < <(find "$HOME/Desktop" "$HOME/Documents" -maxdepth 5 -path "*/.claude/settings.json" -not -path "$HOME/.claude/settings.json" 2>/dev/null)
if [ "$FOUND_OVERRIDES" -eq 0 ]; then
    success "No project-level statusLine overrides found"
else
    success "Cleaned $FOUND_OVERRIDES project-level statusLine override(s)"
fi

# =============================================================================
# Health Check — verify all commands from previous steps
# =============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Running Health Check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Detect shell RC
case "${SHELL:-/bin/bash}" in
    */zsh)  SHELL_RC="$HOME/.zshrc" ;;
    */bash) SHELL_RC="$HOME/.bashrc" ;;
    *)      SHELL_RC="$HOME/.bashrc" ;;
esac

HC_PASS=0
HC_FAIL=0
# Optional add-ons (e.g., 2ndbrain-maxxing) are tracked separately so we don't
# tell the user to "re-run a step" when nothing is actually broken.
OPTIONAL_FAIL=0
OPTIONAL_MSGS=()

# --- Shell aliases ---
for alias_check in \
    "cskip:claude --dangerously-skip-permissions" \
    "cc:claude" \
    "ccr:claude --resume" \
    "ccc:claude --continue"; do
    ALIAS_NAME="${alias_check%%:*}"
    ALIAS_CMD="${alias_check#*:}"
    if grep -q "alias ${ALIAS_NAME}=" "$SHELL_RC" 2>/dev/null; then
        success "HEALTH: $ALIAS_NAME alias — configured"
        HC_PASS=$((HC_PASS + 1))
    else
        warn "HEALTH: $ALIAS_NAME alias — missing, adding now..."
        echo "alias ${ALIAS_NAME}='${ALIAS_CMD}'" >> "$SHELL_RC"
        success "HEALTH: $ALIAS_NAME alias — fixed"
        HC_PASS=$((HC_PASS + 1))
    fi
done

# --- ~/.local/bin on PATH ---
if grep -q '\.local/bin' "$SHELL_RC" 2>/dev/null; then
    success "HEALTH: ~/.local/bin on PATH"
    HC_PASS=$((HC_PASS + 1))
else
    warn "HEALTH: ~/.local/bin not on PATH, adding now..."
    echo "" >> "$SHELL_RC"
    echo '# Local bin (cbrain, cbraintg, ctg)' >> "$SHELL_RC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    success "HEALTH: ~/.local/bin PATH — fixed"
    HC_PASS=$((HC_PASS + 1))
fi

# --- cbrain script (optional — installed by 2ndbrain-maxxing) ---
if [ -x "$HOME/.local/bin/cbrain" ]; then
    success "HEALTH: cbrain command — installed"
    HC_PASS=$((HC_PASS + 1))
else
    info "HEALTH: cbrain not installed — optional add-on (install 2ndbrain-maxxing for vault-aware Claude aliases: https://github.com/lorecraft-io/2ndbrain-maxxing)"
    OPTIONAL_FAIL=$((OPTIONAL_FAIL + 1))
    OPTIONAL_MSGS+=("cbrain — install 2ndbrain-maxxing (https://github.com/lorecraft-io/2ndbrain-maxxing) for vault-aware Claude aliases")
fi

# --- cbraintg script (optional — installed by 2ndbrain-maxxing) ---
if [ -x "$HOME/.local/bin/cbraintg" ]; then
    success "HEALTH: cbraintg command — installed"
    HC_PASS=$((HC_PASS + 1))
else
    info "HEALTH: cbraintg not installed — optional add-on (install 2ndbrain-maxxing for vault-aware Claude aliases: https://github.com/lorecraft-io/2ndbrain-maxxing)"
    OPTIONAL_FAIL=$((OPTIONAL_FAIL + 1))
    OPTIONAL_MSGS+=("cbraintg — install 2ndbrain-maxxing (https://github.com/lorecraft-io/2ndbrain-maxxing) for vault-aware Claude aliases")
fi

# --- ctg script (token-guarded — not an alias) ---
# Migrate: remove stale alias if step-1 hasn't cleaned it up yet
if grep -q 'alias ctg=' "$SHELL_RC" 2>/dev/null; then
    sed -i.bak '/alias ctg=/d' "$SHELL_RC"
    warn "HEALTH: removed stale ctg alias from $SHELL_RC — replaced by ~/.local/bin/ctg"
fi
if [ -x "$HOME/.local/bin/ctg" ]; then
    success "HEALTH: ctg command — installed"
    HC_PASS=$((HC_PASS + 1))
else
    warn "HEALTH: ctg not found — run Step 1 again to install"
    HC_FAIL=$((HC_FAIL + 1))
fi

# --- g2/g4 commands (macOS only) ---
if [ "$(uname -s)" = "Darwin" ]; then
    if grep -q 'g2()' "$SHELL_RC" 2>/dev/null; then
        success "HEALTH: g2/g4 window tiling — configured"
        HC_PASS=$((HC_PASS + 1))
    else
        warn "HEALTH: g2/g4 not found — run the Ghostty bonus step to install"
        HC_FAIL=$((HC_FAIL + 1))
    fi
fi

# --- No-flicker mode ---
if grep -q 'CLAUDE_CODE_NO_FLICKER' "$SHELL_RC" 2>/dev/null; then
    success "HEALTH: no-flicker mode — enabled"
    HC_PASS=$((HC_PASS + 1))
else
    warn "HEALTH: no-flicker mode not set — run Step 2 again to enable"
    HC_FAIL=$((HC_FAIL + 1))
fi

# --- Memory hook ---
if [ -f "$HOME/.claude/settings.json" ] && grep -q '"Stop"' "$HOME/.claude/settings.json" 2>/dev/null; then
    success "HEALTH: memory auto-save hook — configured"
    HC_PASS=$((HC_PASS + 1))
else
    warn "HEALTH: memory hook not found — run Step 2 again to configure"
    HC_FAIL=$((HC_FAIL + 1))
fi

# --- Claude Code (fallback-check nvm glob in case PATH is stale) ---
if command -v claude &>/dev/null; then
    success "HEALTH: Claude Code — installed"
    HC_PASS=$((HC_PASS + 1))
else
    NVM_CLAUDE=$(ls -1 "$HOME"/.nvm/versions/node/*/bin/claude 2>/dev/null | head -n1)
    if [ -n "${NVM_CLAUDE:-}" ] && [ -x "$NVM_CLAUDE" ]; then
        info "HEALTH: Claude Code found at $NVM_CLAUDE (not on current shell's PATH — open a new shell or source ~/.zshrc to use it)"
        HC_PASS=$((HC_PASS + 1))
    else
        warn "HEALTH: Claude Code not found — run Step 1 first"
        HC_FAIL=$((HC_FAIL + 1))
    fi
fi

# --- jq ---
if command -v jq &>/dev/null; then
    success "HEALTH: jq — installed"
    HC_PASS=$((HC_PASS + 1))
else
    warn "HEALTH: jq not found — run Step 2 first"
    HC_FAIL=$((HC_FAIL + 1))
fi

echo ""
echo "  Health check: $HC_PASS passed, $HC_FAIL issues found."
if [ "$HC_FAIL" -gt 0 ]; then
    echo ""
    echo -e "  ${YELLOW}Some install items need attention. Scroll up to see which steps to re-run.${NC}"
    echo -e "  ${YELLOW}Or just launch cskip and ask Claude to fix them — it'll figure it out.${NC}"
fi
if [ "$OPTIONAL_FAIL" -gt 0 ]; then
    echo ""
    echo -e "  ${BLUE}Optional add-ons (not installed — everything still works without them):${NC}"
    for msg in "${OPTIONAL_MSGS[@]}"; do
        echo -e "    ${BLUE}•${NC} $msg"
    done
fi

# =============================================================================
# Install /gitfix skill
# =============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Installing /gitfix skill${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

GITFIX_DIR="$HOME/.claude/skills/gitfix"
GITFIX_FILE="$GITFIX_DIR/SKILL.md"
GITFIX_URL="https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/gitfix-skill/SKILL.md"

mkdir -p "$GITFIX_DIR"

if [ -f "$GITFIX_FILE" ]; then
    info "Updating existing /gitfix skill..."
else
    info "Installing /gitfix skill..."
fi

GITFIX_TMP="$GITFIX_FILE.tmp"
if curl -fsSL "$GITFIX_URL" -o "$GITFIX_TMP" 2>/dev/null && [ -s "$GITFIX_TMP" ]; then
    mv "$GITFIX_TMP" "$GITFIX_FILE"
    success "/gitfix skill installed at $GITFIX_FILE"
else
    rm -f "$GITFIX_TMP"
    warn "Download failed — attempting local fallback..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    LOCAL_GITFIX="$(dirname "$SCRIPT_DIR")/gitfix-skill/SKILL.md"
    if [ -f "$LOCAL_GITFIX" ]; then
        cp "$LOCAL_GITFIX" "$GITFIX_FILE"
        success "/gitfix skill installed from local copy"
    else
        warn "Could not install /gitfix skill — download and local fallback both failed"
    fi
fi

echo ""

# =============================================================================
# Self-Test — status line specifically
# =============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Running Status Line Test${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

TEST_PASS=0
TEST_FAIL=0

# Test 1: statusline.sh exists and is executable
if [ -x "$HOME/.claude/statusline.sh" ]; then
    success "TEST: statusline.sh installed and executable"
    TEST_PASS=$((TEST_PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} TEST: statusline.sh not found or not executable"
    TEST_FAIL=$((TEST_FAIL + 1))
fi

# Test 2: settings.json has statusLine
if grep -q '"statusLine"' "$SETTINGS_FILE" 2>/dev/null; then
    success "TEST: settings.json has statusLine config"
    TEST_PASS=$((TEST_PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} TEST: settings.json missing statusLine config"
    TEST_FAIL=$((TEST_FAIL + 1))
fi

# Test 3: Status line produces output
TEST_OUTPUT=$(echo '{"model":{"display_name":"Test"},"context_window":{"used_percentage":10},"cost":{"total_duration_ms":5000},"workspace":{"current_dir":"/test"}}' | "$HOME/.claude/statusline.sh" 2>/dev/null)
if [ -n "$TEST_OUTPUT" ]; then
    success "TEST: status line produces output — $TEST_OUTPUT"
    TEST_PASS=$((TEST_PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} TEST: status line produced no output"
    TEST_FAIL=$((TEST_FAIL + 1))
fi

# Test 4: /gitfix skill installed
if [ -s "$HOME/.claude/skills/gitfix/SKILL.md" ]; then
    success "TEST: /gitfix skill installed at ~/.claude/skills/gitfix/SKILL.md"
    TEST_PASS=$((TEST_PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} TEST: /gitfix skill not found"
    TEST_FAIL=$((TEST_FAIL + 1))
fi

echo ""
echo "  $TEST_PASS tests passed, $TEST_FAIL failed."

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Final Step Complete — Status Line + Health Check${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Installed skills:"
echo "    /gitfix      — full-repo consistency audit: docs, scripts, and code all in sync"
echo ""
echo "  Status line indicators:"
echo "    🧠 2ndBrain  — in Obsidian vault"
echo "    ⚡ Ruflo     — MCP server connected"
echo "    🎨 UIPro     — design skill loaded"
echo "    🐝 Swarm     — swarm active (during /rswarm)"
echo "    👑 Hive      — hive-mind active (during /rhive)"
echo "    🍯 Mini      — mini swarm active (during /rmini)"
echo ""
echo -e "  ${YELLOW}Important: Until you set up Second Brain (2ndbrain-maxxing), use cskip${NC}"
echo -e "  ${YELLOW}instead of cbrain. cbrain requires an Obsidian vault to exist.${NC}"
echo ""
echo "  Restart Claude Code to see your status line."
echo ""

# Mark step complete (best-effort — don't fail the run if mkdir/touch can't write)
mkdir -p "$HOME/.cli-maxxing" 2>/dev/null || true
touch "$HOME/.cli-maxxing/step-final.done" 2>/dev/null || true
