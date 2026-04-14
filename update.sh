#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# CLI Maxxing — Update
# Re-runs all steps, skips anything already installed, picks up anything new.
# Usage: curl -fsSL <hosted-url>/update.sh | bash
# =============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_URL="https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  CLI Maxxing — Update${NC}"
echo -e "${BLUE}  Running all steps, skipping what's already installed${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Step 1
echo -e "${YELLOW}>>> Running Step 1 — Get Claude Running${NC}"
echo ""
curl -fsSL "$BASE_URL/step-1/step-1-install.sh" | bash
echo ""

# Bonus — Ghostty Terminal (optional, won't reinstall if already present)
echo -e "${YELLOW}>>> Running Bonus — Ghostty Terminal${NC}"
echo ""
curl -fsSL "$BASE_URL/bonus-ghostty/bonus-ghostty.sh" | bash
echo ""

# Bonus — Arc Browser (optional, macOS-only, won't reinstall if already present)
echo -e "${YELLOW}>>> Running Bonus — Arc Browser${NC}"
echo ""
curl -fsSL "$BASE_URL/bonus-arc/bonus-arc.sh" | bash
echo ""

# Step 2
echo -e "${YELLOW}>>> Running Step 2 — Dev Tools${NC}"
echo ""
curl -fsSL "$BASE_URL/step-2/step-2-install.sh" | bash
echo ""

# Step 3
echo -e "${YELLOW}>>> Running Step 3 — Ruflo + Context Hub${NC}"
echo ""
curl -fsSL "$BASE_URL/step-3/step-3-install.sh" | bash
echo ""

# Step 6 (Productivity Tools)
echo -e "${YELLOW}>>> Running Step 6 — Productivity Tools${NC}"
echo ""
curl -fsSL "$BASE_URL/step-6/step-6-install.sh" | bash
echo ""

# Step 8 (Telegram)
echo -e "${YELLOW}>>> Running Step 8 — Telegram${NC}"
echo ""
curl -fsSL "$BASE_URL/step-8/step-8-install.sh" | bash
echo ""

# Step 9 (SafetyCheck)
echo -e "${YELLOW}>>> Running Step 9 — SafetyCheck${NC}"
echo ""
curl -fsSL "$BASE_URL/step-9/step-9-install.sh" | bash
echo ""

# Final Step (Status Line — wrap-up)
echo -e "${YELLOW}>>> Running Final Step — Status Line${NC}"
echo ""
curl -fsSL "$BASE_URL/step-final/step-final-install.sh" | bash
echo ""

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Update complete. All steps are current.${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "  Available commands: cskip, ctg, cc, ccr, ccc"
echo "  Available skills:   /rswarm, /rmini, /rhive, /w4w, /safetycheck, /gitfix, get-api-docs (auto-triggered)"
echo "  Design + media:     github.com/lorecraft-io/creativity-maxxing"
echo "  Second Brain:       github.com/lorecraft-io/2ndbrain-maxxing"
echo ""
echo "  Note: Steps 6 and 8 require interactive input (API credentials"
echo "  and Telegram bot token). They may skip themselves if run"
echo "  non-interactively. Run them directly in your terminal if needed:"
echo ""
echo "    Step 6: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-6/step-6-install.sh)"
echo "    Step 8: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-8/step-8-install.sh)"
echo ""
echo "  Open a new terminal window for aliases to take effect."
echo ""
