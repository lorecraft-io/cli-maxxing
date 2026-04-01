#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# AI Super Setup — Update
# Re-runs all steps, skips anything already installed, picks up anything new.
# Usage: curl -fsSL <hosted-url>/update.sh | bash
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_URL="https://raw.githubusercontent.com/lorecraft-io/ai-super-setup/main"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  AI Super Setup — Update${NC}"
echo -e "${BLUE}  Running all steps, skipping what's already installed${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Step 1
echo -e "${YELLOW}>>> Running Step 1 — Get Claude Running${NC}"
echo ""
curl -fsSL "$BASE_URL/step-1/step-1-install.sh" | bash
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

# Step 6a (vault structure)
echo -e "${YELLOW}>>> Running Step 6a — Second Brain Vault Structure${NC}"
echo ""
curl -fsSL "$BASE_URL/step-6/step-6a-setup-vault.sh" | bash
echo ""

# Step 6b (Claude history import)
echo -e "${YELLOW}>>> Running Step 6b — Import Claude History${NC}"
echo ""
curl -fsSL "$BASE_URL/step-6/step-6b-import-claude.sh" | bash
echo ""

# Step 6c (notes import)
echo -e "${YELLOW}>>> Running Step 6c — Import Existing Notes${NC}"
echo ""
curl -fsSL "$BASE_URL/step-6/step-6c-import-notes.sh" | bash
echo ""

# Step 6d (wire it up)
echo -e "${YELLOW}>>> Running Step 6d — Wire Up Vault${NC}"
echo ""
curl -fsSL "$BASE_URL/step-6/step-6d-wire-vault.sh" | bash
echo ""

# Step 7 (Status Line — wrap-up)
echo -e "${YELLOW}>>> Running Step 7 — Status Line${NC}"
echo ""
curl -fsSL "$BASE_URL/step-7/step-7-install.sh" | bash
echo ""

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Update complete. Steps 1 through 7 are current.${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Reload shell config so new aliases (cskip, cc, ccr, ccc, cbrain) are active
if [ -f "$HOME/.zshrc" ]; then
    source "$HOME/.zshrc" 2>/dev/null || true
elif [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc" 2>/dev/null || true
fi

echo "  Available commands: cskip, cauto, cc, ccr, ccc, cbrain"
echo "  Available skills:   /rswarm, /rhive, /pretext"
echo ""
echo "  Note: Steps 6b, 6c, and 6d are interactive. If you've"
echo "  already completed them before, they just verify your setup."
echo "  If you haven't, follow the prompts to import your data."
echo ""
