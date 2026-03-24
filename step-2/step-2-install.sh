#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 2 — Dev Tools
# Installs: Python, Pandoc, xlsx2csv, pdftotext, jq, ripgrep, gh, tree, fzf, wget
# Run this in Warp after completing Step 1
# Usage: curl -fsSL <hosted-url>/step-1/step-2-install.sh | bash
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
# Detect OS + shell
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin)       OS="mac" ;;
        Linux)        OS="linux" ;;
        MINGW*|MSYS*) fail "Windows detected (Git Bash). Run the PowerShell version instead:\n\n  irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-1/step-2-install.ps1 | iex" ;;
        *)            fail "Unsupported OS: $(uname -s)." ;;
    esac
    info "Detected OS: $OS"

    case "${SHELL:-/bin/bash}" in
        */zsh)  SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_RC="$HOME/.bashrc" ;;
        *)      SHELL_RC="$HOME/.bashrc" ;;
    esac
}

# -----------------------------------------------------------------------------
# Verify Step 1 ran
# -----------------------------------------------------------------------------
verify_prerequisites() {
    if ! command -v node &>/dev/null; then
        fail "Node.js not found. Run Step 1 first."
    fi
    if ! command -v claude &>/dev/null; then
        fail "Claude Code not found. Run Step 1 first."
    fi
    success "Step 1 prerequisites verified (Node.js + Claude Code)"
}

# -----------------------------------------------------------------------------
# Update package index (Linux only, once)
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
# Python 3 + pip
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
# Pandoc
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
            soft_fail "Could not install Pandoc — install manually: https://pandoc.org/installing.html"
            return
        fi
    fi

    command -v pandoc &>/dev/null || soft_fail "Pandoc installation failed"
    command -v pandoc &>/dev/null && success "Pandoc installed ($(pandoc --version | head -1))"
}

# -----------------------------------------------------------------------------
# xlsx2csv
# -----------------------------------------------------------------------------
install_xlsx2csv() {
    if python3 -c "import xlsx2csv" &>/dev/null 2>&1; then
        success "xlsx2csv already installed"
        return
    fi

    info "Installing xlsx2csv..."
    python3 -m pip install --user xlsx2csv --quiet 2>/dev/null \
        || python3 -m pip install --user --break-system-packages xlsx2csv --quiet \
        || { soft_fail "xlsx2csv installation failed"; return; }

    PYTHON_USER_BIN="$(python3 -m site --user-base)/bin"
    if [ -d "$PYTHON_USER_BIN" ]; then
        export PATH="$PYTHON_USER_BIN:$PATH"
        if ! grep -q 'Python.*bin' "$SHELL_RC" 2>/dev/null; then
            echo "" >> "$SHELL_RC"
            echo "# Python user packages" >> "$SHELL_RC"
            echo "export PATH=\"\$(python3 -m site --user-base)/bin:\$PATH\"" >> "$SHELL_RC"
        fi
    fi

    success "xlsx2csv installed"
}

# -----------------------------------------------------------------------------
# pdftotext (poppler)
# -----------------------------------------------------------------------------
install_pdftotext() {
    if command -v pdftotext &>/dev/null; then
        success "pdftotext already installed"
        return
    fi

    info "Installing poppler (pdftotext)..."
    if [ "$OS" = "mac" ]; then
        brew install poppler || { soft_fail "poppler installation failed"; return; }
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq poppler-utils || { soft_fail "poppler-utils installation failed"; return; }
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y poppler-utils || { soft_fail "poppler-utils installation failed"; return; }
        else
            soft_fail "Could not install poppler-utils — install manually for PDF support"
            return
        fi
    fi

    command -v pdftotext &>/dev/null && success "pdftotext installed"
}

# -----------------------------------------------------------------------------
# jq
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
            soft_fail "Could not install jq"
            return
        fi
    fi

    command -v jq &>/dev/null || soft_fail "jq installation failed"
    command -v jq &>/dev/null && success "jq installed ($(jq --version))"
}

# -----------------------------------------------------------------------------
# ripgrep
# -----------------------------------------------------------------------------
install_ripgrep() {
    if command -v rg &>/dev/null; then
        success "ripgrep already installed ($(rg --version | head -1))"
        return
    fi

    info "Installing ripgrep..."
    if [ "$OS" = "mac" ]; then
        brew install ripgrep || { soft_fail "ripgrep installation failed"; return; }
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq ripgrep || { soft_fail "ripgrep installation failed"; return; }
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y ripgrep || { soft_fail "ripgrep installation failed"; return; }
        elif command -v snap &>/dev/null; then
            sudo snap install ripgrep --classic || { soft_fail "ripgrep installation failed"; return; }
        else
            soft_fail "Could not install ripgrep"
            return
        fi
    fi

    command -v rg &>/dev/null && success "ripgrep installed ($(rg --version | head -1))"
}

# -----------------------------------------------------------------------------
# GitHub CLI
# -----------------------------------------------------------------------------
install_gh() {
    if command -v gh &>/dev/null; then
        success "GitHub CLI already installed ($(gh --version | head -1))"
        return
    fi

    info "Installing GitHub CLI..."
    if [ "$OS" = "mac" ]; then
        brew install gh || { soft_fail "GitHub CLI installation failed"; return; }
    else
        if command -v apt-get &>/dev/null; then
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt-get update -qq && sudo apt-get install -y -qq gh || { soft_fail "GitHub CLI installation failed"; return; }
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y gh || { soft_fail "GitHub CLI installation failed"; return; }
        else
            soft_fail "Could not install GitHub CLI — install manually: https://cli.github.com"
            return
        fi
    fi

    command -v gh &>/dev/null && success "GitHub CLI installed ($(gh --version | head -1))"
}

# -----------------------------------------------------------------------------
# tree
# -----------------------------------------------------------------------------
install_tree() {
    if command -v tree &>/dev/null; then
        success "tree already installed"
        return
    fi

    info "Installing tree..."
    if [ "$OS" = "mac" ]; then
        brew install tree || { soft_fail "tree installation failed"; return; }
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq tree || { soft_fail "tree installation failed"; return; }
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y tree || { soft_fail "tree installation failed"; return; }
        else
            soft_fail "Could not install tree"
            return
        fi
    fi

    success "tree installed"
}

# -----------------------------------------------------------------------------
# fzf
# -----------------------------------------------------------------------------
install_fzf() {
    if command -v fzf &>/dev/null; then
        success "fzf already installed ($(fzf --version | cut -d' ' -f1))"
        return
    fi

    info "Installing fzf..."
    if [ "$OS" = "mac" ]; then
        brew install fzf || { soft_fail "fzf installation failed"; return; }
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq fzf || { soft_fail "fzf installation failed"; return; }
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y fzf || { soft_fail "fzf installation failed"; return; }
        else
            git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" && "$HOME/.fzf/install" --all --no-bash --no-fish || { soft_fail "fzf installation failed"; return; }
        fi
    fi

    success "fzf installed"
}

# -----------------------------------------------------------------------------
# wget
# -----------------------------------------------------------------------------
install_wget() {
    if command -v wget &>/dev/null; then
        success "wget already installed"
        return
    fi

    info "Installing wget..."
    if [ "$OS" = "mac" ]; then
        brew install wget || { soft_fail "wget installation failed"; return; }
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq wget || { soft_fail "wget installation failed"; return; }
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y wget || { soft_fail "wget installation failed"; return; }
        else
            soft_fail "Could not install wget"
            return
        fi
    fi

    success "wget installed"
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

    for cmd_check in \
        "python3:Python 3" \
        "pandoc:Pandoc" \
        "pdftotext:pdftotext" \
        "jq:jq" \
        "rg:ripgrep" \
        "gh:GitHub CLI" \
        "tree:tree" \
        "fzf:fzf" \
        "wget:wget"; do
        cmd="${cmd_check%%:*}"
        name="${cmd_check##*:}"
        if command -v "$cmd" &>/dev/null; then
            success "TEST: $name — installed"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: $name — not found"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
    done

    # xlsx2csv (Python import check)
    if python3 -c "import xlsx2csv" &>/dev/null 2>&1; then
        success "TEST: xlsx2csv — installed"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: xlsx2csv — not found"
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
    echo -e "${GREEN}  Step 2 Complete — Dev Tools Installed${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Installed:"
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
    echo ""
    if [ "$ERRORS" -gt 0 ]; then
        echo -e "  ${YELLOW}Warnings: $ERRORS non-critical tool(s) failed to install.${NC}"
        echo -e "  ${YELLOW}Scroll up to see which ones and install them manually.${NC}"
        echo ""
    fi
    echo "  Next: Run Script 2 to set up ClaudeFlow (coming soon)"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Step 2 — Dev Tools${NC}"
    echo -e "${BLUE}  10 tools • macOS + Linux${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    detect_os
    verify_prerequisites
    update_package_index
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
    run_self_test
    print_summary
}

main "$@"
