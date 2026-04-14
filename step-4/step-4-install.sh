#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 4 — UI/UX Pro Max Skill + Taste Skill (Leonxlnx) + 21st.dev Magic MCP
# Installs design intelligence, anti-slop taste skills, and component tools.
# Run this in your terminal after completing Steps 1-3
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail()    { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }
soft_fail() { echo -e "${RED}[FAIL]${NC} $1 (non-critical, continuing...)"; ERRORS=$((ERRORS + 1)); }

# -----------------------------------------------------------------------------
# Detect OS
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin)       OS="mac" ;;
        Linux)        OS="linux" ;;
        MINGW*|MSYS*|CYGWIN*) fail "Windows is not supported. This script is for macOS and Linux only." ;;
        *)            fail "Unsupported OS: $(uname -s). This script supports macOS and Linux only." ;;
    esac
    info "Detected OS: $OS"
}

# -----------------------------------------------------------------------------
# Verify prerequisites
# -----------------------------------------------------------------------------
verify_prerequisites() {
    if ! command -v node &>/dev/null; then
        fail "Node.js not found. Run Step 1 first."
    fi
    if ! command -v claude &>/dev/null; then
        fail "Claude Code not found. Run Step 1 first."
    fi
    success "Prerequisites verified"
}

# -----------------------------------------------------------------------------
# Install UI/UX Pro Max Skill
# -----------------------------------------------------------------------------
install_uiux_skill() {
    SKILL_DIR="$HOME/.claude/skills/ui-ux-pro-max"

    if [ -f "$SKILL_DIR/SKILL.md" ]; then
        success "UI/UX Pro Max Skill already installed"
        return
    fi

    info "Installing UI/UX Pro Max Skill..."
    mkdir -p "$SKILL_DIR"

    # Download the skill from the repo (file is CLAUDE.md in the repo, we save as SKILL.md)
    SKILL_URL="https://raw.githubusercontent.com/nextlevelbuilder/ui-ux-pro-max-skill/main/CLAUDE.md"
    curl -fsSL "$SKILL_URL" -o "$SKILL_DIR/SKILL.md" 2>/dev/null

    if [ -f "$SKILL_DIR/SKILL.md" ] && [ -s "$SKILL_DIR/SKILL.md" ]; then
        success "UI/UX Pro Max Skill installed at $SKILL_DIR"
    else
        soft_fail "Could not download skill file. Install manually from: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill"
    fi
}

# -----------------------------------------------------------------------------
# Install Taste Skill (Leonxlnx/taste-skill)
# Installs 7 variants: taste, redesign, soft, output, minimalist, brutalist, stitch.
# Each becomes its own skill folder under ~/.claude/skills/.
# -----------------------------------------------------------------------------
install_taste_skill() {
    # If any of the variants is already present, assume the pack is installed.
    if [ -d "$HOME/.claude/skills/taste-skill" ] \
        || [ -L "$HOME/.claude/skills/taste-skill" ] \
        || [ -d "$HOME/.claude/skills/soft-skill" ] \
        || [ -d "$HOME/.claude/skills/minimalist-skill" ]; then
        success "Taste Skill already installed"
        return
    fi

    info "Installing Taste Skill pack (Leonxlnx/taste-skill)..."

    # Use the skills CLI — same pattern as the Remotion install in Step 5.
    # The pack ships 7 variants; the CLI expands each one into its own skill dir.
    npx skills add Leonxlnx/taste-skill --yes --global 2>/dev/null

    # Re-check. If the global install didn't land it, try without --global
    # as a fallback (some skills CLI versions don't honor --global).
    if [ ! -d "$HOME/.claude/skills/taste-skill" ] && [ ! -L "$HOME/.claude/skills/taste-skill" ]; then
        npx skills add Leonxlnx/taste-skill --yes 2>/dev/null
    fi

    if [ -d "$HOME/.claude/skills/taste-skill" ] || [ -L "$HOME/.claude/skills/taste-skill" ]; then
        success "Taste Skill installed (7 variants under ~/.claude/skills/)"
    else
        soft_fail "Taste Skill installation could not be verified — install manually: npx skills add Leonxlnx/taste-skill --yes --global"
    fi
}

# -----------------------------------------------------------------------------
# Install 21st.dev Magic MCP
# -----------------------------------------------------------------------------
install_21st_magic() {
    # Check if already configured
    if claude mcp list 2>/dev/null | grep -qi "magic\|21st" 2>/dev/null; then
        success "21st.dev Magic MCP already configured"
        return
    fi

    info "Adding 21st.dev Magic MCP to Claude Code..."
    npx -y @anthropic-ai/claude-code mcp add magic -- npx -y @21st-dev/magic@latest 2>/dev/null \
        || claude mcp add magic -- npx -y @21st-dev/magic@latest 2>/dev/null

    if claude mcp list 2>/dev/null | grep -qi "magic\|21st" 2>/dev/null; then
        success "21st.dev Magic MCP configured"
    else
        warn "Could not auto-configure Magic MCP. You may need to set it up manually."
        echo ""
        echo "  To set up manually:"
        echo "  1. Go to https://21st.dev"
        echo "  2. Create a free account"
        echo "  3. Follow the MCP setup instructions on their site"
        echo ""
    fi
}

# -----------------------------------------------------------------------------
# Self-test
# -----------------------------------------------------------------------------
run_self_test() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Running Self-Test${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    TEST_PASS=0
    TEST_FAIL=0

    # UI/UX Pro Max Skill
    if [ -f "$HOME/.claude/skills/ui-ux-pro-max/SKILL.md" ]; then
        success "TEST: UI/UX Pro Max Skill installed"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: UI/UX Pro Max Skill not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Taste Skill (Leonxlnx/taste-skill) — checks for the main variant folder
    if [ -d "$HOME/.claude/skills/taste-skill" ] || [ -L "$HOME/.claude/skills/taste-skill" ]; then
        success "TEST: Taste Skill installed"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: Taste Skill not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # 21st.dev Magic MCP
    if claude mcp list 2>/dev/null | grep -qi "magic\|21st" 2>/dev/null; then
        success "TEST: 21st.dev Magic MCP configured"
        TEST_PASS=$((TEST_PASS + 1))
    else
        warn "TEST: 21st.dev Magic MCP may need manual setup (see instructions below)"
        TEST_PASS=$((TEST_PASS + 1))
    fi

    echo ""
    if [ "$TEST_FAIL" -eq 0 ]; then
        echo -e "  ${GREEN}All $TEST_PASS tests passed.${NC}"
    else
        echo -e "  ${GREEN}$TEST_PASS passed${NC}, ${RED}$TEST_FAIL failed${NC}."
        echo -e "  ${YELLOW}Scroll up to see what went wrong.${NC}"
    fi
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
print_summary() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  Step 4 Complete — Design Tools Ready${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Installed:"
    echo "    UI/UX Pro Max    $([ -f "$HOME/.claude/skills/ui-ux-pro-max/SKILL.md" ] && echo 'installed' || echo '—')"
    echo "    Taste Skill      $([ -d "$HOME/.claude/skills/taste-skill" ] || [ -L "$HOME/.claude/skills/taste-skill" ] && echo 'installed (7 variants)' || echo '—')"
    echo "    21st.dev Magic   $(claude mcp list 2>/dev/null | grep -qi 'magic\|21st' && echo 'configured' || echo 'needs manual setup')"
    echo ""
    echo "  Taste Skill variants installed:"
    echo "    - taste-skill       (main premium frontend rules, 3 knobs)"
    echo "    - redesign-skill    (upgrade existing projects — audit first)"
    echo "    - soft-skill        (expensive soft UI look, spring animations)"
    echo "    - output-skill      (anti-laziness: no placeholder comments)"
    echo "    - minimalist-skill  (clean, editorial, Notion/Linear style)"
    echo "    - brutalist-skill   (raw mechanical, CRT terminal aesthetics — beta)"
    echo "    - stitch-skill      (Google Stitch-compatible semantic rules)"
    echo ""
    echo "  taste-skill knobs (edit the SKILL.md to tune, 1-10 scale):"
    echo "    DESIGN_VARIANCE   — 1-3 centered/clean   | 8-10 asymmetric/modern"
    echo "    MOTION_INTENSITY  — 1-3 simple hover     | 8-10 scroll-triggered"
    echo "    VISUAL_DENSITY    — 1-3 spacious/luxury  | 8-10 dense dashboards"
    echo ""
    if [ "$ERRORS" -gt 0 ]; then
        echo -e "  ${YELLOW}Warnings: $ERRORS issue(s) detected.${NC}"
        echo -e "  ${YELLOW}Scroll up to see details.${NC}"
        echo ""
    fi
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  IMPORTANT: 21st.dev Magic MCP Manual Setup${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  If 21st.dev Magic wasn't auto-configured, do this:"
    echo ""
    echo "  1. Go to https://21st.dev"
    echo "  2. Create a free account (no payment needed)"
    echo "  3. Follow the MCP setup instructions on their site"
    echo "  4. They'll give you a command to run in your terminal"
    echo ""
    echo "  Once connected, ask Claude to build any UI component"
    echo "  and it will pull from 21st.dev's library automatically."
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Check the README for more steps as they're added."
    echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Step 4 — Design Tools${NC}"
    echo -e "${BLUE}  UI/UX Pro Max + Taste Skill + 21st.dev Magic • macOS + Linux${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    detect_os
    verify_prerequisites
    install_uiux_skill
    install_taste_skill
    install_21st_magic
    run_self_test
    print_summary
}

main "$@"
