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
echo -e "${YELLOW}>>> Running Step 3 — ClaudeFlow${NC}"
echo ""
curl -fsSL "$BASE_URL/step-3/step-3-install.sh" | bash
echo ""

# Step 4
echo -e "${YELLOW}>>> Running Step 4 — Design Tools${NC}"
echo ""
curl -fsSL "$BASE_URL/step-4/step-4-install.sh" | bash
echo ""

# Add new steps here as they're created
# echo -e "${YELLOW}>>> Running Step 5 — ...${NC}"
# curl -fsSL "$BASE_URL/step-5/step-5-install.sh" | bash

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Update complete. Everything is current.${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
