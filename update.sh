#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# CLI Maxxing — Update
# Re-runs all steps, skips anything already installed, picks up anything new.
# Usage: curl -fsSL <hosted-url>/update.sh | bash
# =============================================================================

RED='\033[0;31m'
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

# Step 4
echo -e "${YELLOW}>>> Running Step 4 — Design Tools${NC}"
echo ""
curl -fsSL "$BASE_URL/step-4/step-4-install.sh" | bash
echo ""

# Step 5 (Visual Media)
echo -e "${YELLOW}>>> Running Step 5 — Visual Media${NC}"
echo ""
curl -fsSL "$BASE_URL/step-5/step-5-install.sh" | bash
echo ""

# Step 6 (Productivity Tools)
echo -e "${YELLOW}>>> Running Step 6 — Productivity Tools${NC}"
echo ""
curl -fsSL "$BASE_URL/step-6/step-6-install.sh" | bash
echo ""

# Step 7a (vault structure)
echo -e "${YELLOW}>>> Running Step 7a — Second Brain Vault Structure${NC}"
echo ""
curl -fsSL "$BASE_URL/step-7/step-7a-setup-vault.sh" | bash
echo ""

# Step 7b (Claude history import)
echo -e "${YELLOW}>>> Running Step 7b — Import Claude History${NC}"
echo ""
curl -fsSL "$BASE_URL/step-7/step-7b-import-claude.sh" | bash
echo ""

# Step 7c (notes import)
echo -e "${YELLOW}>>> Running Step 7c — Import Existing Notes${NC}"
echo ""
curl -fsSL "$BASE_URL/step-7/step-7c-import-notes.sh" | bash
echo ""

# Step 7d (wire it up)
echo -e "${YELLOW}>>> Running Step 7d — Wire Up Vault${NC}"
echo ""
curl -fsSL "$BASE_URL/step-7/step-7d-wire-vault.sh" | bash
echo ""

# Step 8 (Status Line — wrap-up)
echo -e "${YELLOW}>>> Running Step 8 — Status Line${NC}"
echo ""
curl -fsSL "$BASE_URL/step-8/step-8-install.sh" | bash
echo ""

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Update complete. Steps 1 through 8 are current.${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Reload shell config so new aliases (cskip, ctg, cc, ccr, ccc, cbrain, cbraintg) are active
if [ -f "$HOME/.zshrc" ]; then
    source "$HOME/.zshrc" 2>/dev/null || true
elif [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc" 2>/dev/null || true
fi

echo "  Available commands: cskip, ctg, cc, ccr, ccc, cbrain, cbraintg"
echo "  Available skills:   /rswarm, /rmini, /rhive, /w4w"
echo ""
echo "  Note: Steps 7b, 7c, 7d, and 6 are interactive. If you've"
echo "  already completed them before, they just verify your setup."
echo "  If you haven't, follow the prompts to import your data"
echo "  and choose your productivity tools."
echo ""
