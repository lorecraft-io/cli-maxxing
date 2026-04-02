#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Bonus — Arc Browser
# Installs Arc Browser via Homebrew.
# A faster, cleaner browser built for people who live in their browser.
# Usage: curl -fsSL <hosted-url>/bonus-arc/bonus-arc.sh | bash
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

# -----------------------------------------------------------------------------
# Detect OS
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin)       OS="mac" ;;
        Linux)        OS="linux" ;;
        MINGW*|MSYS*|CYGWIN*) fail "Windows is not supported." ;;
        *)            fail "Unsupported OS: $(uname -s)" ;;
    esac
    info "Detected OS: $OS"
}

# -----------------------------------------------------------------------------
# Install Arc Browser
# -----------------------------------------------------------------------------
install_arc() {
    if [ "$OS" = "mac" ]; then
        if [ -d "/Applications/Arc.app" ]; then
            success "Arc Browser already installed"
            return
        fi

        if ! command -v brew &>/dev/null; then
            fail "Homebrew not found. Run Step 1 first."
        fi

        info "Installing Arc Browser via Homebrew..."
        brew install --cask arc || fail "Arc installation failed"
        success "Arc Browser installed"
    else
        warn "Arc Browser is currently macOS-only."
        warn "Visit https://arc.net for updates on Linux support."
        return
    fi
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
print_summary() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  Arc Browser — Installed${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  What you got:"
    echo "    Arc Browser — a faster, cleaner way to use the internet"
    echo ""
    echo "  Migrating from Chrome:"
    echo "    Arc imports your Chrome bookmarks, passwords, history,"
    echo "    and extensions automatically on first launch."
    echo "    Just follow the prompts when you open it."
    echo ""
    echo "  Quick tips:"
    echo "    Cmd+T to open a new tab"
    echo "    Cmd+S to pin a tab to your sidebar"
    echo "    Cmd+Shift+C to copy the current URL"
    echo "    Swipe left/right to switch Spaces"
    echo ""
    echo "  Set as default browser:"
    echo "    Arc will ask on first launch, or go to"
    echo "    System Settings > Desktop & Dock > Default web browser"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Bonus — Arc Browser${NC}"
    echo -e "${BLUE}  The browser for power users. Fast, clean, no clutter.${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    detect_os
    install_arc
    print_summary
}

main "$@"
