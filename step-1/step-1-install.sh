#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 1 — Get Claude Running
# Installs: Xcode CLT/build-essential, Homebrew, Git, Node.js, Warp, Claude Code
# Usage: curl -fsSL <hosted-url>/step-1/step-1-install.sh | bash
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
# 1. Detect OS
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin)       OS="mac" ;;
        Linux)        OS="linux" ;;
        MINGW*|MSYS*) fail "Windows detected (Git Bash). Run the PowerShell version instead:\n\n  irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-1/step-1-install.ps1 | iex" ;;
        CYGWIN*)      fail "Cygwin detected. Run the PowerShell version instead:\n\n  irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-1/step-1-install.ps1 | iex" ;;
        *)            fail "Unsupported OS: $(uname -s). This script supports macOS and Linux.\nFor Windows, use the PowerShell version: step-1-install.ps1" ;;
    esac
    info "Detected OS: $OS"

    case "${SHELL:-/bin/bash}" in
        */zsh)  USER_SHELL="zsh";  SHELL_RC="$HOME/.zshrc" ;;
        */bash) USER_SHELL="bash"; SHELL_RC="$HOME/.bashrc" ;;
        *)      USER_SHELL="bash"; SHELL_RC="$HOME/.bashrc" ;;
    esac
    info "Detected shell: $USER_SHELL ($SHELL_RC)"
}

# -----------------------------------------------------------------------------
# 2. Preflight checks
# -----------------------------------------------------------------------------
preflight_checks() {
    if [ "$(id -u)" -eq 0 ]; then
        fail "Do not run this script as root or with sudo. Run as your normal user account."
    fi

    if ! curl -fsSL --connect-timeout 5 https://raw.githubusercontent.com/ &>/dev/null; then
        fail "No internet connection detected. This script requires internet access."
    fi
    success "Internet connectivity verified"
}

# -----------------------------------------------------------------------------
# 3. Update package index (Linux only)
# -----------------------------------------------------------------------------
update_package_index() {
    if [ "$OS" = "linux" ]; then
        if command -v apt-get &>/dev/null; then
            info "Updating apt package index..."
            sudo apt-get update -qq
            success "Package index updated"
        fi
    fi
}

# -----------------------------------------------------------------------------
# 4. Xcode CLT (macOS) / build-essential (Linux)
# -----------------------------------------------------------------------------
install_build_tools() {
    if [ "$OS" = "mac" ]; then
        if xcode-select -p &>/dev/null; then
            success "Xcode Command Line Tools already installed"
        else
            info "Installing Xcode Command Line Tools..."
            xcode-select --install 2>/dev/null || true
            echo ""
            echo -e "    ${YELLOW}A popup window should appear on your screen.${NC}"
            echo -e "    ${YELLOW}Click 'Install' and wait for it to finish.${NC}"
            echo -e "    ${YELLOW}This can take a few minutes...${NC}"
            echo ""
            CLT_WAIT=0
            CLT_MAX=180
            until xcode-select -p &>/dev/null; do
                sleep 5
                CLT_WAIT=$((CLT_WAIT + 1))
                if [ "$CLT_WAIT" -ge "$CLT_MAX" ]; then
                    fail "Xcode Command Line Tools installation timed out after 15 minutes. Please install manually: xcode-select --install"
                fi
            done
            success "Xcode Command Line Tools installed"
        fi
    else
        if dpkg -s build-essential &>/dev/null 2>&1; then
            success "build-essential already installed"
        elif command -v gcc &>/dev/null && command -v make &>/dev/null; then
            success "Build tools already available (gcc + make)"
        else
            info "Installing build-essential..."
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y -qq build-essential || soft_fail "build-essential installation failed"
            elif command -v dnf &>/dev/null; then
                sudo dnf groupinstall -y "Development Tools" || soft_fail "Development Tools installation failed"
            else
                warn "Could not install build tools — install gcc and make manually if needed"
                return
            fi
            command -v gcc &>/dev/null && success "Build tools installed"
        fi
    fi
}

# -----------------------------------------------------------------------------
# 5. Homebrew (macOS only)
# -----------------------------------------------------------------------------
install_homebrew() {
    if [ "$OS" != "mac" ]; then return; fi

    if command -v brew &>/dev/null; then
        success "Homebrew already installed"
    else
        info "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            if [ "$USER_SHELL" = "bash" ]; then
                BREW_PROFILE="$HOME/.bash_profile"
            else
                BREW_PROFILE="$HOME/.zprofile"
            fi
            if ! grep -q 'homebrew' "$BREW_PROFILE" 2>/dev/null; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$BREW_PROFILE"
            fi
        elif [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        command -v brew &>/dev/null || fail "Homebrew installation failed"
        success "Homebrew installed"
    fi
}

# -----------------------------------------------------------------------------
# 6. Git
# -----------------------------------------------------------------------------
install_git() {
    if command -v git &>/dev/null; then
        success "Git already installed ($(git --version))"
        return
    fi

    info "Installing Git..."
    if [ "$OS" = "mac" ]; then
        brew install git
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq git
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y git
        else
            fail "Could not install Git — no supported package manager found"
        fi
    fi

    command -v git &>/dev/null || fail "Git installation failed"
    success "Git installed ($(git --version))"
}

# -----------------------------------------------------------------------------
# 7. Node.js via nvm
# -----------------------------------------------------------------------------
install_node() {
    if command -v node &>/dev/null; then
        NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)
        if [ "$NODE_MAJOR" -ge 18 ]; then
            success "Node.js $(node -v) already installed (meets v18+ requirement)"
            return
        else
            warn "Node.js $(node -v) found but too old — need v18+. Installing via nvm..."
        fi
    fi

    if [ ! -d "$HOME/.nvm" ]; then
        info "Installing nvm..."
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi

    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

    command -v nvm &>/dev/null || fail "nvm installation failed"

    info "Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'

    command -v node &>/dev/null || fail "Node.js installation failed"
    success "Node.js $(node -v) installed via nvm"
}

# -----------------------------------------------------------------------------
# 8. Warp Terminal
# -----------------------------------------------------------------------------
install_warp() {
    if [ "$OS" = "mac" ]; then
        if [ -d "/Applications/Warp.app" ]; then
            success "Warp Terminal already installed"
            return
        fi
    else
        if command -v warp-terminal &>/dev/null; then
            success "Warp Terminal already installed"
            return
        fi
    fi

    info "Installing Warp Terminal..."
    if [ "$OS" = "mac" ]; then
        brew install --cask warp || { soft_fail "Warp Terminal installation failed"; return; }
    else
        if command -v apt-get &>/dev/null; then
            curl -fsSL https://releases.warp.dev/stable/v0.2025.03.18.08.02.stable_05/warp-terminal_0.2025.03.18.08.02.stable.05_amd64.deb -o /tmp/warp.deb 2>/dev/null
            if [ -f /tmp/warp.deb ]; then
                sudo apt-get install -y -qq /tmp/warp.deb || { soft_fail "Warp Terminal installation failed — install manually: https://www.warp.dev"; return; }
                rm -f /tmp/warp.deb
            else
                soft_fail "Warp Terminal download failed — install manually: https://www.warp.dev"
                return
            fi
        elif command -v dnf &>/dev/null; then
            sudo rpm --import https://releases.warp.dev/linux/keys/warp.asc 2>/dev/null
            sudo dnf install -y https://releases.warp.dev/stable/v0.2025.03.18.08.02.stable_05/warp-terminal-0.2025.03.18.08.02.stable.05-1.x86_64.rpm 2>/dev/null \
                || { soft_fail "Warp Terminal installation failed — install manually: https://www.warp.dev"; return; }
        else
            soft_fail "Could not install Warp Terminal — install manually: https://www.warp.dev"
            return
        fi
    fi

    success "Warp Terminal installed"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Why Warp?${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Warp is your new terminal for working with Claude."
    echo ""
    echo "  The key feature: press ${GREEN}Shift+Tab${NC} while Claude is"
    echo "  running to toggle permissions on and off — no need to"
    echo "  exit and relaunch."
    echo ""
    echo "  After this script finishes, open Warp and run all"
    echo "  future commands from there."
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# 9. Claude Code
# -----------------------------------------------------------------------------
install_claude_code() {
    if command -v claude &>/dev/null; then
        success "Claude Code already installed"
    else
        info "Installing Claude Code..."
        npm install -g @anthropic-ai/claude-code 2>/dev/null \
            || sudo npm install -g @anthropic-ai/claude-code

        command -v claude &>/dev/null || fail "Claude Code installation failed"
        success "Claude Code installed"
    fi

    # Add cskip shortcut
    if ! grep -q 'alias cskip' "$SHELL_RC" 2>/dev/null; then
        info "Adding 'cskip' shortcut to $SHELL_RC..."
        echo "" >> "$SHELL_RC"
        echo "# Claude Code shortcuts" >> "$SHELL_RC"
        echo "alias cskip='claude --dangerously-skip-permissions'" >> "$SHELL_RC"
        success "Shortcut added: type 'cskip' to launch Claude (auto-approve mode)"
    else
        success "cskip shortcut already configured"
    fi
}

# -----------------------------------------------------------------------------
# Self-test — verify everything actually works
# -----------------------------------------------------------------------------
run_self_test() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Running Self-Test${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    TEST_PASS=0
    TEST_FAIL=0

    # Git
    if command -v git &>/dev/null; then
        success "TEST: git — $(git --version)"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: git — not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Node
    if command -v node &>/dev/null; then
        NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)
        if [ "$NODE_MAJOR" -ge 18 ]; then
            success "TEST: node $(node -v) — meets v18+ requirement"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: node $(node -v) — too old, need v18+"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
    else
        soft_fail "TEST: node — not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # npm
    if command -v npm &>/dev/null; then
        success "TEST: npm v$(npm -v)"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: npm — not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Warp
    if [ "$OS" = "mac" ]; then
        if [ -d "/Applications/Warp.app" ]; then
            success "TEST: Warp Terminal — installed"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: Warp Terminal — not found in /Applications"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
    else
        if command -v warp-terminal &>/dev/null; then
            success "TEST: Warp Terminal — installed"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: Warp Terminal — not found"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
    fi

    # Claude Code
    if command -v claude &>/dev/null; then
        success "TEST: claude — $(claude --version 2>/dev/null || echo 'found')"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: claude — not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # cskip alias in shell config
    if grep -q 'alias cskip' "$SHELL_RC" 2>/dev/null; then
        success "TEST: cskip shortcut — configured in $SHELL_RC"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: cskip shortcut — not found in $SHELL_RC"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    echo ""
    if [ "$TEST_FAIL" -eq 0 ]; then
        echo -e "  ${GREEN}All $TEST_PASS tests passed.${NC}"
    else
        echo -e "  ${GREEN}$TEST_PASS passed${NC}, ${RED}$TEST_FAIL failed${NC}."
        echo -e "  ${YELLOW}Scroll up to see what went wrong. You may need to fix these before continuing.${NC}"
    fi
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Next steps
# -----------------------------------------------------------------------------
show_next_steps() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  ACTION REQUIRED: Set Up Warp + Claude${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  1. Close this terminal and open ${GREEN}Warp${NC}"
    echo ""
    echo "  2. If Warp asks to create an account — sign up."
    echo "     The free plan is all you need."
    echo ""
    echo "  3. Go to Warp settings (Cmd+Comma / Ctrl+Comma):"
    echo -e "     → Features → Default Mode → set to ${GREEN}Terminal${NC}"
    echo ""
    echo "     If you see 'Agent Oz' instead of a terminal,"
    echo -e "     just press ${GREEN}Esc${NC} to switch to the terminal view."
    echo ""
    echo "  4. Launch Claude (it will prompt you to log in):"
    echo ""
    echo -e "     ${GREEN}cskip${NC}"
    echo ""
    echo "  5. Run Step 2 to install dev tools:"
    echo ""
    echo -e "     ${GREEN}curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-2/step-2-install.sh | bash${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
print_summary() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  Step 1 Complete — Claude is Ready${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Installed:"
    if [ "$OS" = "mac" ]; then
    echo "    Homebrew       $(brew --version 2>/dev/null | head -1 || echo '—')"
    fi
    echo "    Git            $(git --version 2>/dev/null || echo '—')"
    echo "    Node.js        $(node -v 2>/dev/null || echo '—')"
    echo "    npm            v$(npm -v 2>/dev/null || echo '—')"
    if [ "$OS" = "mac" ]; then
    echo "    Warp Terminal  $([ -d '/Applications/Warp.app' ] && echo 'installed' || echo '—')"
    else
    echo "    Warp Terminal  $(command -v warp-terminal &>/dev/null && echo 'installed' || echo '—')"
    fi
    echo "    Claude Code    $(claude --version 2>/dev/null || echo '—')"
    echo ""
    if [ "$ERRORS" -gt 0 ]; then
        echo -e "  ${YELLOW}Warnings: $ERRORS non-critical tool(s) failed to install.${NC}"
        echo -e "  ${YELLOW}Scroll up to see which ones and install them manually.${NC}"
        echo ""
    fi
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Step 1 — Get Claude Running${NC}"
    echo -e "${BLUE}  5 tools • macOS + Linux${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${YELLOW}Note: This script installs everything automatically, but${NC}"
    echo -e "  ${YELLOW}the steps AFTER it finishes (Warp setup, Claude login) are${NC}"
    echo -e "  ${YELLOW}manual. Claude won't be helping in your terminal yet —${NC}"
    echo -e "  ${YELLOW}that starts after you complete the setup steps below.${NC}"
    echo -e "  ${YELLOW}It should be smooth, but if something goes wrong, check${NC}"
    echo -e "  ${YELLOW}the test results at the end of this script.${NC}"
    echo ""

    detect_os
    preflight_checks
    update_package_index
    install_build_tools
    install_homebrew
    install_git
    install_node
    install_warp
    install_claude_code
    run_self_test
    print_summary
    show_next_steps
}

main "$@"
