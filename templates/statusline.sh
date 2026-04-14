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

# --- RUFLO CHECK ---
RUFLO=""
if pgrep -f "claude-flow.*mcp" >/dev/null 2>&1 || pgrep -f "@claude-flow/cli" >/dev/null 2>&1 || pgrep -f "ruflo" >/dev/null 2>&1; then
  RUFLO="⚡ Ruflo"
fi

# --- UIPRO CHECK (always on — global skill) ---
UIPRO="🎨 UIPro"

# --- SWARM CHECK (only shows when actively running) ---
# Lock file alone isn't enough — validate swarm processes are alive.
# If lock file exists but nothing's running, clean it up (stale session).
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
    # Stale lock file — no swarm processes running, clean up
    rm -f "$SWARM_LOCK" 2>/dev/null
  fi
fi

# --- HIVE CHECK (only shows when actively running) ---
# Same validation — lock file + live process required.
HIVE=""
HIVE_LOCK="/tmp/ruflo-hive-active"
if [ -f "$HIVE_LOCK" ] 2>/dev/null; then
  if pgrep -f "hive-mind|claude-flow.*hive|ruflo.*hive" >/dev/null 2>&1; then
    HIVE="👑 Hive"
  else
    # Stale lock file — no hive processes running, clean up
    rm -f "$HIVE_LOCK" 2>/dev/null
  fi
fi

# --- BUILD THE LINE ---
PARTS=""

# Ruflo
if [ -n "$RUFLO" ]; then
  PARTS="${RUFLO}"
fi

# UIPro (always on)
if [ -n "$PARTS" ]; then
  PARTS="${PARTS} + ${UIPRO}"
else
  PARTS="${UIPRO}"
fi

# Swarm or Hive activity
if [ -n "$SWARM" ] && [ -n "$HIVE" ]; then
  PARTS="${PARTS} [${SWARM} + ${HIVE}]"
elif [ -n "$SWARM" ]; then
  PARTS="${PARTS} [${SWARM}]"
elif [ -n "$HIVE" ]; then
  PARTS="${PARTS} [${HIVE}]"
fi

echo "${PARTS} • ${MODEL} • ⏱ ${TIME_FMT} • ${CTX}% ctx"
