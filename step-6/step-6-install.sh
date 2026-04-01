#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 6 — Visual Media Tools
# Installs Remotion skills for programmatic video creation with React
# Run this in your terminal after completing Steps 1-5
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
# Install Remotion skills via the skills CLI
# -----------------------------------------------------------------------------
install_remotion_skills() {
    info "Installing Remotion skills for Claude Code..."

    # Check if already installed
    if [ -d "$HOME/.claude/skills/remotion-best-practices" ] || [ -L "$HOME/.claude/skills/remotion-best-practices" ]; then
        success "Remotion skills already installed"
        return
    fi

    # Install globally with auto-confirm
    npx skills add remotion-dev/skills --yes --global 2>/dev/null

    # Verify installation
    if [ -d "$HOME/.claude/skills/remotion-best-practices" ] || [ -L "$HOME/.claude/skills/remotion-best-practices" ]; then
        success "Remotion skills installed for Claude Code"
    else
        # Try project-level install as fallback
        npx skills add remotion-dev/skills --yes 2>/dev/null

        if [ -d ".agents/skills/remotion-best-practices" ] || [ -L "$HOME/.claude/skills/remotion-best-practices" ]; then
            success "Remotion skills installed"
        else
            soft_fail "Remotion skills installation could not be verified"
        fi
    fi
}

# -----------------------------------------------------------------------------
# Install YouTube Transcript MCP (free transcript extraction from YouTube)
# -----------------------------------------------------------------------------
install_youtube_transcript() {
    info "Installing YouTube Transcript MCP server..."

    # Check if already registered
    if claude mcp list 2>/dev/null | grep -q "youtube-transcript"; then
        success "YouTube Transcript MCP already installed"
        return
    fi

    claude mcp add --scope user youtube-transcript -- npx -y @kimtaeyoon83/mcp-server-youtube-transcript 2>/dev/null

    if claude mcp list 2>/dev/null | grep -q "youtube-transcript"; then
        success "YouTube Transcript MCP installed"
    else
        soft_fail "YouTube Transcript MCP installation could not be verified"
    fi
}

# -----------------------------------------------------------------------------
# Install FFmpeg (needed for video processing features)
# -----------------------------------------------------------------------------
install_ffmpeg() {
    if command -v ffmpeg &>/dev/null; then
        success "FFmpeg already installed ($(ffmpeg -version 2>/dev/null | head -1 | awk '{print $3}'))"
        return
    fi

    info "Installing FFmpeg..."
    if [ "$OS" = "mac" ]; then
        brew install ffmpeg 2>/dev/null || true
    else
        sudo apt-get install -y ffmpeg 2>/dev/null \
            || sudo dnf install -y ffmpeg 2>/dev/null \
            || sudo pacman -S --noconfirm ffmpeg 2>/dev/null \
            || true
    fi

    if command -v ffmpeg &>/dev/null; then
        success "FFmpeg installed"
    else
        soft_fail "FFmpeg installation failed (install manually: brew install ffmpeg)"
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

    # Remotion skills installed
    if [ -d "$HOME/.claude/skills/remotion-best-practices" ] || [ -L "$HOME/.claude/skills/remotion-best-practices" ] || [ -d ".agents/skills/remotion-best-practices" ]; then
        success "TEST: Remotion skills installed"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: Remotion skills not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # YouTube Transcript MCP registered
    if claude mcp list 2>/dev/null | grep -q "youtube-transcript"; then
        success "TEST: YouTube Transcript MCP registered"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: YouTube Transcript MCP not registered"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # FFmpeg available
    if command -v ffmpeg &>/dev/null; then
        success "TEST: FFmpeg available"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: FFmpeg not available"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # skills CLI available
    if npx skills --version &>/dev/null 2>&1; then
        success "TEST: Skills CLI available"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: Skills CLI not available"
        TEST_FAIL=$((TEST_FAIL + 1))
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
    echo -e "${GREEN}  Step 6 Complete — Visual Media Tools are Ready${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Remotion and YouTube Transcripts are now available in Claude Code."
    echo ""
    echo "  What you can do now:"
    echo "    - Create videos programmatically with React"
    echo "    - Add animations, transitions, captions, and 3D content"
    echo "    - Process audio and video with FFmpeg"
    echo "    - Generate data visualizations as video"
    echo "    - Pull transcripts from any YouTube video"
    echo ""
    echo "  Try it: ask Claude to create a Remotion video project,"
    echo "  or paste a YouTube link and ask for the transcript."
    echo ""
    if [ "$ERRORS" -gt 0 ]; then
        echo -e "  ${YELLOW}Warnings: $ERRORS issue(s) detected.${NC}"
        echo -e "  ${YELLOW}Scroll up to see details.${NC}"
        echo ""
    fi
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
    echo -e "${BLUE}  Step 6 — Visual Media${NC}"
    echo -e "${BLUE}  Programmatic video creation • macOS + Linux${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    detect_os
    verify_prerequisites
    install_remotion_skills
    install_youtube_transcript
    install_ffmpeg
    run_self_test
    print_summary
}

main "$@"
