#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# CLI Maxxing — Install
# Runs all non-interactive steps in order. Steps that are already installed
# are skipped automatically. Steps that require interactive input (Step 6,
# Step 8, and Step 10) are noted at the end — run them separately in your terminal.
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/install.sh)
# =============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_URL="https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main"

# -----------------------------------------------------------------------------
# reload_path — re-source brew + nvm into the current shell so chained child
# steps in this pipeline can find node, npm, brew, etc. Needed because Step 1
# installs brew/nvm mid-run and the parent shell otherwise never picks them up.
# -----------------------------------------------------------------------------
reload_path() {
  # brew — first found wins
  local brew_bin
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [ -x "$brew_bin" ]; then
      eval "$("$brew_bin" shellenv)"
      break
    fi
  done

  # nvm — source if installed
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  # ~/.local/bin — prepend idempotently
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) : ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
}

# Breadcrumb dir — child step scripts touch step-N.done here on success.
mkdir -p "$HOME/.cli-maxxing"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  CLI Maxxing — Install${NC}"
echo -e "${BLUE}  Running all steps in order, skipping what's already done${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Step 1
echo -e "${YELLOW}>>> Step 1 — Get Claude Running${NC}"
echo ""
curl -fsSL "$BASE_URL/step-1/step-1-install.sh" | bash
# BUG A fix: Step 1 installs brew+nvm; re-source them into this shell so the
# remaining curl|bash steps (Ghostty/Arc/2/3/9/final) can actually find them.
reload_path
echo ""

# Bonus — Ghostty Terminal (optional, won't reinstall if already present)
echo -e "${YELLOW}>>> Bonus — Ghostty Terminal${NC}"
echo ""
curl -fsSL "$BASE_URL/bonus-ghostty/bonus-ghostty.sh" | bash
echo ""

# Bonus — Arc Browser (optional, macOS-only, won't reinstall if already present)
echo -e "${YELLOW}>>> Bonus — Arc Browser${NC}"
echo ""
curl -fsSL "$BASE_URL/bonus-arc/bonus-arc.sh" | bash
echo ""

# Step 2
echo -e "${YELLOW}>>> Step 2 — Dev Tools${NC}"
echo ""
curl -fsSL "$BASE_URL/step-2/step-2-install.sh" | bash
echo ""

# Step 3
echo -e "${YELLOW}>>> Step 3 — fidgetflo + Context Hub${NC}"
echo ""
curl -fsSL "$BASE_URL/step-3/step-3-install.sh" | bash
echo ""

# Step 9 (SafetyCheck)
echo -e "${YELLOW}>>> Step 9 — SafetyCheck${NC}"
echo ""
curl -fsSL "$BASE_URL/step-9/step-9-install.sh" | bash
echo ""

# Final Step (Status Line — wrap-up)
echo -e "${YELLOW}>>> Final Step — Status Line${NC}"
echo ""
curl -fsSL "$BASE_URL/step-final/step-final-install.sh" | bash
echo ""

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Core install complete.${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Breadcrumb check — list any expected steps that did NOT touch their .done file.
EXPECTED_CRUMBS=(step-1 step-2 step-3 step-9 step-final ghostty arc)
MISSING_CRUMBS=()
for crumb in "${EXPECTED_CRUMBS[@]}"; do
  if [ ! -f "$HOME/.cli-maxxing/${crumb}.done" ]; then
    MISSING_CRUMBS+=("$crumb")
  fi
done

if [ "${#MISSING_CRUMBS[@]}" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  Some steps did not complete. This usually happens on the first install${NC}"
  echo -e "${YELLOW}   when a new terminal hasn't loaded brew + node yet.${NC}"
  echo -e "${YELLOW}   → Close this terminal, open a new one, and re-run:${NC}"
  echo -e "${YELLOW}     bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/install.sh)${NC}"
  echo -e "${YELLOW}   The script is idempotent and will resume.${NC}"
  echo ""
  echo -e "${YELLOW}   Missing: ${MISSING_CRUMBS[*]}${NC}"
  echo ""
fi

echo "  Available commands: cskip, ctg, cc, ccr, ccc"
echo "  Available skills:   /rswarm, /rmini, /rhive, /w4w, /safetycheck, /gitfix, get-api-docs (auto-triggered)"
echo "  Swarm tiers:        /rswarm{1,2,3,max}, /rmini{1,2,3,max} — 1=think, 2=think hard, 3=think harder, max=ultrathink"
echo ""
echo "  Three steps require interactive input — run them separately:"
echo ""
echo "    Step 6 (Productivity Tools — Notion, Morgen, n8n, Playwright, etc.):"
echo "    bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-6/step-6-install.sh)"
echo ""
echo "    Step 8 (Telegram — optional, skip if you don't have a bot token):"
echo "    bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-8/step-8-install.sh)"
echo ""
echo "    Step 10 (Developer Tools — GitHub MCP, optional, for devs):"
echo "    bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-10/step-10-install.sh)"
echo ""
echo "  Companion repos (install after this):"
echo "    Design + media:  bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/creativity-maxxing/main/install.sh)"
echo "    Second Brain:    bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/2ndbrain-maxxing/main/install.sh)"
echo ""
echo "  Open a new terminal window for aliases to take effect."
echo ""
