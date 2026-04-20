#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 2 — Dev Tools
# Installs: Python, Pandoc, xlsx2csv, pdftotext, jq, ripgrep, gh, tree, fzf, wget, weasyprint
# Run this in your terminal after completing Step 1
# Usage: curl -fsSL <hosted-url>/step-2/step-2-install.sh | bash
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
# source_runtime_path — defense-in-depth PATH hydration
#
# Ensures brew, nvm-installed node, pipx shims, and ~/.local/bin are visible
# even when this script is invoked standalone (not via the install.sh wrapper
# which already calls reload_path between steps — see BUG A coordination fix).
#
# Idempotent: safe to call multiple times.
# -----------------------------------------------------------------------------
source_runtime_path() {
    # 1. Homebrew — eval shellenv from the first brew binary found
    local brew_bin
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        if [ -x "$brew_bin" ]; then
            eval "$("$brew_bin" shellenv)" 2>/dev/null || true
            break
        fi
    done

    # 2. nvm — source if present (node/npm may live under $NVM_DIR/versions/node/*/bin)
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        # shellcheck disable=SC1091
        \. "$HOME/.nvm/nvm.sh" 2>/dev/null || true
    fi

    # 3. ~/.local/bin — idempotent prepend (pipx shims, ctg, user-installed bins)
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
}

# -----------------------------------------------------------------------------
# Detect OS + shell
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin)       OS="mac" ;;
        Linux)        OS="linux" ;;
        MINGW*|MSYS*|CYGWIN*) fail "Windows is not supported. This script is for macOS and Linux only." ;;
        *)            fail "Unsupported OS: $(uname -s). This script supports macOS and Linux only." ;;
    esac
    info "Detected OS: $OS"

    # Primary SHELL_RC (for summary/display + legacy single-file grep checks)
    case "${SHELL:-/bin/bash}" in
        */zsh)  SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_RC="$HOME/.bashrc" ;;
        *)      SHELL_RC="$HOME/.bashrc" ;;
    esac

    # SHELL_RCS — full list to write integrations to. On macOS many users have
    # both zsh (default) and bash installed; step-1 mirrors writes across both.
    # We match that pattern so no-flicker + memory hook land in whichever rc
    # the user actually sources.
    if [ "$OS" = "mac" ]; then
        SHELL_RCS="$HOME/.zshrc $HOME/.bashrc"
    else
        SHELL_RCS="$SHELL_RC"
    fi
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
# xlsx2csv (via pipx — avoids PEP 668 externally-managed-environment on mac py 3.9)
# -----------------------------------------------------------------------------
install_xlsx2csv() {
    if command -v xlsx2csv &>/dev/null; then
        success "xlsx2csv already installed ($(command -v xlsx2csv))"
        return
    fi

    # Ensure pipx is available (idempotent — brew/apt/dnf skip if present)
    if ! command -v pipx &>/dev/null; then
        info "Installing pipx (required for PEP 668 isolated Python apps)..."
        if [ "$OS" = "mac" ]; then
            brew install pipx || { soft_fail "pipx installation failed — skipping xlsx2csv"; return; }
        else
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y -qq pipx || {
                    # Fallback: bootstrap pipx via pip on older Ubuntus
                    python3 -m pip install --user pipx --break-system-packages --quiet 2>/dev/null \
                        || python3 -m pip install --user pipx --quiet \
                        || { soft_fail "pipx installation failed — skipping xlsx2csv"; return; }
                }
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y pipx || {
                    python3 -m pip install --user pipx --quiet \
                        || { soft_fail "pipx installation failed — skipping xlsx2csv"; return; }
                }
            else
                python3 -m pip install --user pipx --quiet \
                    || { soft_fail "pipx installation failed — skipping xlsx2csv"; return; }
            fi
        fi
    fi

    # ensurepath appends pipx's bin dir (~/.local/bin on mac/linux) to shell rc files.
    # Safe on re-run — pipx writes idempotent markers.
    pipx ensurepath >/dev/null 2>&1 || true

    # Re-hydrate PATH so the freshly-added pipx shim dir is visible to this shell
    source_runtime_path

    info "Installing xlsx2csv via pipx..."
    if pipx install xlsx2csv --force >/dev/null 2>&1; then
        # One more PATH hydrate in case pipx just created a new shim dir
        source_runtime_path
        if command -v xlsx2csv &>/dev/null; then
            success "xlsx2csv installed ($(command -v xlsx2csv))"
        else
            soft_fail "xlsx2csv installed but shim not on PATH — open a new shell or run: pipx ensurepath"
        fi
    else
        soft_fail "xlsx2csv installation failed"
    fi
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
# weasyprint (HTML to PDF converter)
# -----------------------------------------------------------------------------
install_weasyprint() {
    if command -v weasyprint &>/dev/null; then
        success "weasyprint already installed"
        return
    fi

    info "Installing weasyprint..."
    if [ "$OS" = "mac" ]; then
        brew install weasyprint || { soft_fail "weasyprint installation failed"; return; }
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y -qq weasyprint || { soft_fail "weasyprint installation failed"; return; }
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y weasyprint || { soft_fail "weasyprint installation failed"; return; }
        else
            soft_fail "Could not install weasyprint"
            return
        fi
    fi

    success "weasyprint installed"
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
        "wget:wget" \
        "weasyprint:weasyprint"; do
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

    # xlsx2csv (pipx shim check — pipx install adds `xlsx2csv` to ~/.local/bin)
    if command -v xlsx2csv &>/dev/null; then
        success "TEST: xlsx2csv — installed ($(command -v xlsx2csv))"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: xlsx2csv — not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # No-flicker mode — check across all rc files we write to
    NO_FLICKER_FOUND=""
    for rc in $SHELL_RCS; do
        if [ -f "$rc" ] && grep -q 'CLAUDE_CODE_NO_FLICKER' "$rc" 2>/dev/null; then
            NO_FLICKER_FOUND="${NO_FLICKER_FOUND}${rc} "
        fi
    done
    if [ -n "$NO_FLICKER_FOUND" ]; then
        success "TEST: no-flicker mode — configured in ${NO_FLICKER_FOUND% }"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: no-flicker mode — not found in any of: $SHELL_RCS"
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
# Auto-save memory hook — saves conversation context on session end
# -----------------------------------------------------------------------------
configure_memory_hook() {
    CLAUDE_SETTINGS="$HOME/.claude/settings.json"

    # Create .claude dir if needed
    mkdir -p "$HOME/.claude"

    # Check if hook already exists
    if [ -f "$CLAUDE_SETTINGS" ] && grep -q '"Stop"' "$CLAUDE_SETTINGS" 2>/dev/null; then
        success "Memory auto-save hook already configured"
        return
    fi

    info "Configuring memory auto-save hook..."

    if [ -f "$CLAUDE_SETTINGS" ]; then
        # Settings file exists — add hooks if not present
        if command -v jq &>/dev/null; then
            HOOK_CMD='SESSION_ID=$(jq -r '"'"'.session_id // empty'"'"' 2>/dev/null); MARKER="/tmp/claude-memory-saved-${SESSION_ID}"; if [ -f "$MARKER" ]; then echo '"'"'{"continue": true}'"'"'; else touch "$MARKER"; echo '"'"'{"continue": false, "stopReason": "MANDATORY: Before ending, review this conversation and save any key decisions, project context, outcomes, or user preferences to memory files. If nothing noteworthy was discussed, acknowledge that and stop."}'"'"'; fi'

            jq --arg cmd "$HOOK_CMD" '.hooks = (.hooks // {}) | .hooks.Stop = [{"hooks": [{"type": "command", "command": $cmd, "timeout": 5}]}]' "$CLAUDE_SETTINGS" > "${CLAUDE_SETTINGS}.tmp" \
                && mv "${CLAUDE_SETTINGS}.tmp" "$CLAUDE_SETTINGS"
            success "Memory auto-save hook configured"
        else
            warn "jq not available yet, skipping hook config. Run Step 2 again after jq installs."
        fi
    else
        # No settings file — create one with the hook
        cat > "$CLAUDE_SETTINGS" << 'SETTINGS_EOF'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "SESSION_ID=$(jq -r '.session_id // empty' 2>/dev/null); MARKER=\"/tmp/claude-memory-saved-${SESSION_ID}\"; if [ -f \"$MARKER\" ]; then echo '{\"continue\": true}'; else touch \"$MARKER\"; echo '{\"continue\": false, \"stopReason\": \"MANDATORY: Before ending, review this conversation and save any key decisions, project context, outcomes, or user preferences to memory files. If nothing noteworthy was discussed, acknowledge that and stop.\"}'; fi",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
        success "Memory auto-save hook configured"
    fi
}

# -----------------------------------------------------------------------------
# No-flicker mode — fullscreen rendering for Claude Code
#
# Writes to every shell rc file that already exists in $SHELL_RCS so users on
# macOS (zsh default, bash secondary) get the env vars whichever shell they
# launch. Idempotent via grep markers.
# -----------------------------------------------------------------------------
configure_no_flicker() {
    FLICKER_ANY_CHANGED=false
    FLICKER_ANY_WRITTEN=""

    for rc in $SHELL_RCS; do
        # Only write to files that already exist — never materialize a .bashrc
        # on a zsh-only macOS user and vice versa.
        [ -f "$rc" ] || continue

        local changed=false

        if ! grep -q 'CLAUDE_CODE_NO_FLICKER' "$rc" 2>/dev/null; then
            echo "" >> "$rc"
            echo "# Claude Code — no-flicker fullscreen rendering" >> "$rc"
            echo "export CLAUDE_CODE_NO_FLICKER=1" >> "$rc"
            changed=true
        fi

        if ! grep -q 'CLAUDE_CODE_SCROLL_SPEED' "$rc" 2>/dev/null; then
            echo "export CLAUDE_CODE_SCROLL_SPEED=3" >> "$rc"
            changed=true
        fi

        if $changed; then
            FLICKER_ANY_CHANGED=true
            FLICKER_ANY_WRITTEN="${FLICKER_ANY_WRITTEN}${rc} "
            info "Enabled no-flicker mode in $rc"
        fi
    done

    if $FLICKER_ANY_CHANGED; then
        success "No-flicker mode enabled in ${FLICKER_ANY_WRITTEN% }"
    else
        success "No-flicker mode already configured in $SHELL_RCS"
    fi
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
    echo "    xlsx2csv       $(command -v xlsx2csv &>/dev/null && echo 'installed' || echo '—')"
    echo "    pdftotext      $(command -v pdftotext &>/dev/null && echo 'installed' || echo '—')"
    echo "    jq             $(jq --version 2>/dev/null || echo '—')"
    echo "    ripgrep        $(rg --version 2>/dev/null | head -1 || echo '—')"
    echo "    GitHub CLI     $(gh --version 2>/dev/null | head -1 || echo '—')"
    echo "    tree           $(command -v tree &>/dev/null && echo 'installed' || echo '—')"
    echo "    fzf            $(fzf --version 2>/dev/null | cut -d' ' -f1 || echo '—')"
    echo "    wget           $(command -v wget &>/dev/null && echo 'installed' || echo '—')"
    echo ""
    # Report no-flicker status across all rc files we may have written to
    NO_FLICKER_STATUS="—"
    for rc in $SHELL_RCS; do
        if [ -f "$rc" ] && grep -q 'CLAUDE_CODE_NO_FLICKER' "$rc" 2>/dev/null; then
            NO_FLICKER_STATUS="enabled"
            break
        fi
    done

    echo "  Configured:"
    echo "    No-flicker     $NO_FLICKER_STATUS"
    echo "    Memory hook    $(grep -q '"Stop"' "$HOME/.claude/settings.json" 2>/dev/null && echo 'enabled' || echo '—')"
    echo ""
    if [ "$ERRORS" -gt 0 ]; then
        echo -e "  ${YELLOW}Warnings: $ERRORS non-critical tool(s) failed to install.${NC}"
        echo -e "  ${YELLOW}Scroll up to see which ones and install them manually.${NC}"
        echo ""
    fi
    echo "  Next: Run Step 3 to set up FidgetFlo (multi-agent orchestration)"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    # Defense-in-depth for BUG A: hydrate PATH before any brew/node/claude probe.
    # install.sh wrapper calls reload_path between steps, but step-2 may be
    # invoked standalone (curl | bash) — so we self-hydrate first thing.
    source_runtime_path

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
    install_weasyprint
    configure_memory_hook
    configure_no_flicker
    run_self_test
    print_summary

    # Success marker — consumed by install.sh wrapper for step-skip logic
    mkdir -p "$HOME/.cli-maxxing"
    touch "$HOME/.cli-maxxing/step-2.done"
}

main "$@"
