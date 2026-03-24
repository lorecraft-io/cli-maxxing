#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Script 0 — Client Environment Setup
# Installs all prerequisites + Claude Code
# Usage: curl -fsSL <hosted-url>/script-0-install.sh | bash
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
# 1. Detect OS
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin) OS="mac" ;;
        Linux)  OS="linux" ;;
        *)      fail "Unsupported OS: $(uname -s). This script supports macOS and Linux." ;;
    esac
    info "Detected OS: $OS"
}

# -----------------------------------------------------------------------------
# 2. Xcode Command Line Tools (macOS) / build-essential (Linux)
# -----------------------------------------------------------------------------
install_build_tools() {
    if [ "$OS" = "mac" ]; then
        if xcode-select -p &>/dev/null; then
            success "Xcode Command Line Tools already installed"
        else
            info "Installing Xcode Command Line Tools..."
            xcode-select --install 2>/dev/null || true
            # Wait for installation to complete
            echo "    Waiting for Xcode CLT installer to finish..."
            until xcode-select -p &>/dev/null; do
                sleep 5
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
                sudo apt-get update -qq && sudo apt-get install -y -qq build-essential
            elif command -v dnf &>/dev/null; then
                sudo dnf groupinstall -y "Development Tools"
            else
                warn "Could not install build tools automatically — install gcc and make manually if needed"
                return
            fi
            success "Build tools installed"
        fi
    fi
}

# -----------------------------------------------------------------------------
# 3. Homebrew (macOS only)
# -----------------------------------------------------------------------------
install_homebrew() {
    if [ "$OS" != "mac" ]; then return; fi

    if command -v brew &>/dev/null; then
        success "Homebrew already installed"
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add brew to PATH for Apple Silicon and Intel
        if [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            SHELL_PROFILE="$HOME/.zprofile"
            if ! grep -q 'homebrew' "$SHELL_PROFILE" 2>/dev/null; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$SHELL_PROFILE"
            fi
        elif [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        command -v brew &>/dev/null || fail "Homebrew installation failed"
        success "Homebrew installed"
    fi
}

# -----------------------------------------------------------------------------
# 4. Git
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
# 5. Node.js via nvm
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
# 6. Python 3 + pip
# -----------------------------------------------------------------------------
install_python() {
    if command -v python3 &>/dev/null; then
        success "Python 3 already installed ($(python3 --version))"
    else
        info "Installing Python 3..."
        if [ "$OS" = "mac" ]; then
            brew install python3
        else
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y -qq python3 python3-pip python3-venv
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y python3 python3-pip
            else
                fail "Could not install Python 3 — no supported package manager found"
            fi
        fi
        command -v python3 &>/dev/null || fail "Python 3 installation failed"
        success "Python 3 installed ($(python3 --version))"
    fi

    # Ensure pip is available
    if ! python3 -m pip --version &>/dev/null; then
        info "Installing pip..."
        if [ "$OS" = "mac" ]; then
            python3 -m ensurepip --upgrade 2>/dev/null || brew install python3
        else
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y -qq python3-pip
            else
                curl -fsSL https://bootstrap.pypa.io/get-pip.py | python3
            fi
        fi
    fi
    success "pip available ($(python3 -m pip --version 2>/dev/null | cut -d' ' -f1-2))"
}

# -----------------------------------------------------------------------------
# 7. Pandoc
# -----------------------------------------------------------------------------
install_pandoc() {
    if command -v pandoc &>/dev/null; then
        success "Pandoc already installed ($(pandoc --version | head -1))"
        return
    fi

    info "Installing Pandoc..."
    if [ "$OS" = "mac" ]; then
        brew install pandoc
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq pandoc
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y pandoc
        elif command -v snap &>/dev/null; then
            sudo snap install pandoc
        else
            fail "Could not install Pandoc — install manually: https://pandoc.org/installing.html"
        fi
    fi

    command -v pandoc &>/dev/null || fail "Pandoc installation failed"
    success "Pandoc installed ($(pandoc --version | head -1))"
}

# -----------------------------------------------------------------------------
# 8. xlsx2csv (Python package for spreadsheet conversion)
# -----------------------------------------------------------------------------
install_xlsx2csv() {
    if python3 -c "import xlsx2csv" &>/dev/null 2>&1; then
        success "xlsx2csv already installed"
        return
    fi

    info "Installing xlsx2csv..."
    python3 -m pip install --user xlsx2csv --quiet
    success "xlsx2csv installed"
}

# -----------------------------------------------------------------------------
# 9. pdftotext (poppler-utils — PDF text extraction)
# -----------------------------------------------------------------------------
install_pdftotext() {
    if command -v pdftotext &>/dev/null; then
        success "pdftotext already installed"
        return
    fi

    info "Installing poppler (pdftotext)..."
    if [ "$OS" = "mac" ]; then
        brew install poppler
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq poppler-utils
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y poppler-utils
        else
            warn "Could not install poppler-utils — install manually for PDF support"
            return
        fi
    fi

    command -v pdftotext &>/dev/null || warn "pdftotext installation may need a shell restart"
    success "pdftotext installed"
}

# -----------------------------------------------------------------------------
# 10. jq (JSON processor)
# -----------------------------------------------------------------------------
install_jq() {
    if command -v jq &>/dev/null; then
        success "jq already installed ($(jq --version))"
        return
    fi

    info "Installing jq..."
    if [ "$OS" = "mac" ]; then
        brew install jq
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq jq
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y jq
        else
            fail "Could not install jq — no supported package manager found"
        fi
    fi

    command -v jq &>/dev/null || fail "jq installation failed"
    success "jq installed ($(jq --version))"
}

# -----------------------------------------------------------------------------
# 11. ripgrep (fast code search — used by Claude Code internally)
# -----------------------------------------------------------------------------
install_ripgrep() {
    if command -v rg &>/dev/null; then
        success "ripgrep already installed ($(rg --version | head -1))"
        return
    fi

    info "Installing ripgrep..."
    if [ "$OS" = "mac" ]; then
        brew install ripgrep
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq ripgrep
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y ripgrep
        elif command -v snap &>/dev/null; then
            sudo snap install ripgrep --classic
        else
            warn "Could not install ripgrep — install manually: https://github.com/BurntSushi/ripgrep"
            return
        fi
    fi

    command -v rg &>/dev/null || warn "ripgrep installation may need a shell restart"
    success "ripgrep installed ($(rg --version | head -1))"
}

# -----------------------------------------------------------------------------
# 12. GitHub CLI (gh)
# -----------------------------------------------------------------------------
install_gh() {
    if command -v gh &>/dev/null; then
        success "GitHub CLI already installed ($(gh --version | head -1))"
        return
    fi

    info "Installing GitHub CLI..."
    if [ "$OS" = "mac" ]; then
        brew install gh
    else
        if command -v apt-get &>/dev/null; then
            # Official GitHub apt repo
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt-get update -qq && sudo apt-get install -y -qq gh
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y gh
        else
            warn "Could not install GitHub CLI — install manually: https://cli.github.com"
            return
        fi
    fi

    command -v gh &>/dev/null || warn "GitHub CLI installation may need a shell restart"
    success "GitHub CLI installed ($(gh --version | head -1))"
}

# -----------------------------------------------------------------------------
# 13. tree (directory visualization)
# -----------------------------------------------------------------------------
install_tree() {
    if command -v tree &>/dev/null; then
        success "tree already installed"
        return
    fi

    info "Installing tree..."
    if [ "$OS" = "mac" ]; then
        brew install tree
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq tree
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y tree
        else
            warn "Could not install tree"
            return
        fi
    fi

    success "tree installed"
}

# -----------------------------------------------------------------------------
# 14. fzf (fuzzy finder)
# -----------------------------------------------------------------------------
install_fzf() {
    if command -v fzf &>/dev/null; then
        success "fzf already installed ($(fzf --version | cut -d' ' -f1))"
        return
    fi

    info "Installing fzf..."
    if [ "$OS" = "mac" ]; then
        brew install fzf
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq fzf
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y fzf
        else
            git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
            "$HOME/.fzf/install" --all --no-bash --no-fish
        fi
    fi

    success "fzf installed"
}

# -----------------------------------------------------------------------------
# 15. wget
# -----------------------------------------------------------------------------
install_wget() {
    if command -v wget &>/dev/null; then
        success "wget already installed"
        return
    fi

    info "Installing wget..."
    if [ "$OS" = "mac" ]; then
        brew install wget
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq wget
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y wget
        else
            warn "Could not install wget"
            return
        fi
    fi

    success "wget installed"
}

# -----------------------------------------------------------------------------
# 16. Claude Code
# -----------------------------------------------------------------------------
install_claude_code() {
    if command -v claude &>/dev/null; then
        success "Claude Code already installed"
    else
        info "Installing Claude Code..."
        npm install -g @anthropic-ai/claude-code

        command -v claude &>/dev/null || fail "Claude Code installation failed"
        success "Claude Code installed"
    fi
}

# -----------------------------------------------------------------------------
# Auth — user must complete interactively
# -----------------------------------------------------------------------------
verify_claude_auth() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  ACTION REQUIRED: Claude Code Login${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Run this command to log in:"
    echo ""
    echo -e "    ${GREEN}claude auth login${NC}"
    echo ""
    echo "  This will open a browser window. Sign in with your"
    echo "  Anthropic account and approve the connection."
    echo ""
    echo "  After logging in, verify it worked with:"
    echo ""
    echo -e "    ${GREEN}claude --version${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
print_summary() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  Script 0 Complete — Environment Ready${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Installed:"
    if [ "$OS" = "mac" ]; then
    echo "    Homebrew       $(brew --version 2>/dev/null | head -1 || echo '—')"
    fi
    echo "    Git            $(git --version 2>/dev/null || echo '—')"
    echo "    Node.js        $(node -v 2>/dev/null || echo '—')"
    echo "    npm            v$(npm -v 2>/dev/null || echo '—')"
    echo "    Python         $(python3 --version 2>/dev/null || echo '—')"
    echo "    Pandoc         $(pandoc --version 2>/dev/null | head -1 || echo '—')"
    echo "    xlsx2csv       $(python3 -c 'import xlsx2csv; print("installed")' 2>/dev/null || echo '—')"
    echo "    pdftotext      $(command -v pdftotext &>/dev/null && echo 'installed' || echo '—')"
    echo "    jq             $(jq --version 2>/dev/null || echo '—')"
    echo "    ripgrep        $(rg --version 2>/dev/null | head -1 || echo '—')"
    echo "    GitHub CLI     $(gh --version 2>/dev/null | head -1 || echo '—')"
    echo "    tree           $(command -v tree &>/dev/null && echo 'installed' || echo '—')"
    echo "    fzf            $(fzf --version 2>/dev/null | cut -d' ' -f1 || echo '—')"
    echo "    wget           $(command -v wget &>/dev/null && echo 'installed' || echo '—')"
    echo "    Claude Code    $(claude --version 2>/dev/null || echo '—')"
    echo ""
    echo "  Next steps:"
    echo "    1. Log in to Claude Code (see above)"
    echo "    2. Run Script 1 to set up ClaudeFlow"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Script 0 — Client Environment Setup${NC}"
    echo -e "${BLUE}  15 tools • macOS + Linux${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    detect_os
    install_build_tools
    install_homebrew
    install_git
    install_node
    install_python
    install_pandoc
    install_xlsx2csv
    install_pdftotext
    install_jq
    install_ripgrep
    install_gh
    install_tree
    install_fzf
    install_wget
    install_claude_code
    verify_claude_auth
    print_summary
}

main "$@"
