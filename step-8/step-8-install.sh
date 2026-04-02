#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 8 — Status Line
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

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Step 8 — Status Line${NC}"
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
# 2ndBrain (Obsidian) + Ruflo (MCP) + UIPro + Swarm/Hive activity

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

# --- 2ndBRAIN CHECK ---
BRAIN=""
if echo "$CWD" | grep -qiE "OBSIDIAN/(2ndBrain|MASTER)" 2>/dev/null; then
  BRAIN="🧠 2ndBrain"
fi

# --- RUFLO CHECK ---
RUFLO=""
if pgrep -f "claude-flow.*mcp" >/dev/null 2>&1 || pgrep -f "@claude-flow/cli" >/dev/null 2>&1 || pgrep -f "ruflo" >/dev/null 2>&1; then
  RUFLO="⚡ Ruflo"
fi

# --- UIPRO CHECK (always on — global skill) ---
UIPRO="🎨 UIPro"

# --- SWARM CHECK (only shows when actively running) ---
SWARM=""
SWARM_LOCK="/tmp/ruflo-swarm-active"
if [ -f "$SWARM_LOCK" ] 2>/dev/null; then
  if pgrep -f "swarm.*init|claude-flow.*swarm|ruflo.*swarm" >/dev/null 2>&1; then
    AGENT_COUNT=$(cat "$SWARM_LOCK" 2>/dev/null || echo "")
    if [ -n "$AGENT_COUNT" ]; then
      SWARM="🐝 ${AGENT_COUNT}"
    else
      SWARM="🐝"
    fi
  else
    rm -f "$SWARM_LOCK" 2>/dev/null
  fi
fi

# --- HIVE CHECK (only shows when actively running) ---
HIVE=""
HIVE_LOCK="/tmp/ruflo-hive-active"
if [ -f "$HIVE_LOCK" ] 2>/dev/null; then
  if pgrep -f "hive-mind|claude-flow.*hive|ruflo.*hive" >/dev/null 2>&1; then
    HIVE="🍯 Hive"
  else
    rm -f "$HIVE_LOCK" 2>/dev/null
  fi
fi

# --- BUILD THE LINE ---
PARTS=""
if [ -n "$BRAIN" ] && [ -n "$RUFLO" ]; then
  PARTS="${BRAIN} + ${RUFLO}"
elif [ -n "$BRAIN" ]; then
  PARTS="${BRAIN}"
elif [ -n "$RUFLO" ]; then
  PARTS="${RUFLO}"
fi

if [ -n "$PARTS" ]; then
  PARTS="${PARTS} + ${UIPRO}"
else
  PARTS="${UIPRO}"
fi

if [ -n "$SWARM" ] && [ -n "$HIVE" ]; then
  PARTS="${PARTS} [${SWARM} + ${HIVE}]"
elif [ -n "$SWARM" ]; then
  PARTS="${PARTS} [${SWARM}]"
elif [ -n "$HIVE" ]; then
  PARTS="${PARTS} [${HIVE}]"
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
# Self-Test
# =============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Running Self-Test${NC}"
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

# Test 3: jq available
if command -v jq &>/dev/null; then
    success "TEST: jq available (required by status line)"
    TEST_PASS=$((TEST_PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} TEST: jq not found (run Step 2 first)"
    TEST_FAIL=$((TEST_FAIL + 1))
fi

# Test 4: Status line produces output
TEST_OUTPUT=$(echo '{"model":{"display_name":"Test"},"context_window":{"used_percentage":10},"cost":{"total_duration_ms":5000},"workspace":{"current_dir":"/test"}}' | "$HOME/.claude/statusline.sh" 2>/dev/null)
if [ -n "$TEST_OUTPUT" ]; then
    success "TEST: status line produces output — $TEST_OUTPUT"
    TEST_PASS=$((TEST_PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} TEST: status line produced no output"
    TEST_FAIL=$((TEST_FAIL + 1))
fi

echo ""
echo "  $TEST_PASS tests passed, $TEST_FAIL failed."

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Step 8 Complete — Status Line Active${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Status line indicators:"
echo "    🧠 2ndBrain  — in Obsidian vault"
echo "    ⚡ Ruflo     — MCP server connected"
echo "    🎨 UIPro     — design skill loaded"
echo "    🐝 Swarm     — swarm active (during /rswarm)"
echo "    🍯 Hive      — hive-mind active (during /rhive)"
echo ""
echo "  Restart Claude Code to see your status line."
echo ""
