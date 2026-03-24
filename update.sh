#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# AI Super User Setup — Update
# Re-runs all steps, skips anything already installed, picks up anything new.
# Usage: curl -fsSL <hosted-url>/update.sh | bash
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_URL="https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  AI Super User Setup — Update${NC}"
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
echo -e "${YELLOW}>>> Running Step 3 — Ruflo${NC}"
echo ""
curl -fsSL "$BASE_URL/step-3/step-3-install.sh" | bash
echo ""

# Step 4
echo -e "${YELLOW}>>> Running Step 4 — Design Tools${NC}"
echo ""
curl -fsSL "$BASE_URL/step-4/step-4-install.sh" | bash
echo ""

# Step 5a (vault structure)
echo -e "${YELLOW}>>> Running Step 5a — Second Brain Vault Structure${NC}"
echo ""
curl -fsSL "$BASE_URL/step-5/step-5a-setup-vault.sh" | bash
echo ""

# Step 5b (Claude history import)
echo -e "${YELLOW}>>> Running Step 5b — Import Claude History${NC}"
echo ""
curl -fsSL "$BASE_URL/step-5/step-5b-import-claude.sh" | bash
echo ""

# Step 5c (notes import)
echo -e "${YELLOW}>>> Running Step 5c — Import Existing Notes${NC}"
echo ""
curl -fsSL "$BASE_URL/step-5/step-5c-import-notes.sh" | bash
echo ""

# Step 5d (wire it up)
echo -e "${YELLOW}>>> Running Step 5d — Wire Up Vault${NC}"
echo ""
curl -fsSL "$BASE_URL/step-5/step-5d-wire-vault.sh" | bash
echo ""

# Step 6
echo -e "${YELLOW}>>> Running Step 6 — Visual Media${NC}"
echo ""
curl -fsSL "$BASE_URL/step-6/step-6-install.sh" | bash
echo ""

# Add new steps here as they're created

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Update complete. Steps 1 through 6 are current.${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Note: Steps 5b, 5c, and 5d are interactive. If you've"
echo "  already completed them before, they just verify your setup."
echo "  If you haven't, follow the prompts to import your data."
echo ""
