#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 1 — Get Claude Running
# Installs: Xcode CLT/build-essential, Homebrew, Git, Node.js, Claude Code
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
# 0. Runtime PATH bootstrap — source whatever brew/nvm/.local bin already exist
#    so a re-run of step-1 in a fresh shell can see previously-installed tools.
# -----------------------------------------------------------------------------
source_runtime_path() {
    # Homebrew shellenv (Apple Silicon + Intel macOS)
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    # nvm (Node Version Manager)
    if [ -d "$HOME/.nvm" ]; then
        export NVM_DIR="$HOME/.nvm"
        # shellcheck source=/dev/null
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    fi

    # User-local bin (ctg and friends)
    if [ -d "$HOME/.local/bin" ]; then
        case ":$PATH:" in
            *":$HOME/.local/bin:"*) ;;
            *) export PATH="$HOME/.local/bin:$PATH" ;;
        esac
    fi
}

# -----------------------------------------------------------------------------
# 1. Detect OS + shell-config targets
#    macOS Terminal.app launches zsh by default (since 10.15) even when the
#    passwd shell is /bin/bash. Writing to BOTH zsh + bash config files is the
#    same approach Homebrew's own installer recommends, and prevents the
#    "command not found" trap when the passwd shell and the launched shell
#    disagree. On Linux we keep single-shell behavior (login shell from getent).
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin)       OS="mac" ;;
        Linux)        OS="linux" ;;
        MINGW*|MSYS*|CYGWIN*) fail "Windows is not supported. This script is for macOS and Linux only." ;;
        *)            fail "Unsupported OS: $(uname -s). This script supports macOS and Linux only." ;;
    esac
    info "Detected OS: $OS"

    if [ "$OS" = "mac" ]; then
        # macOS: write to both shells so Terminal.app (zsh) AND bash sessions
        # both pick up aliases/PATH regardless of the user's passwd shell.
        SHELL_RCS=("$HOME/.zshrc" "$HOME/.bashrc")
        SHELL_PROFILES=("$HOME/.zprofile" "$HOME/.bash_profile")
        USER_SHELL="zsh+bash"
    else
        # Linux: detect actual login shell from /etc/passwd, fall back to $SHELL.
        local login_shell=""
        if command -v getent &>/dev/null; then
            login_shell=$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)
        fi
        if [ -z "$login_shell" ]; then
            login_shell="${SHELL:-/bin/bash}"
        fi
        case "$login_shell" in
            */zsh)
                USER_SHELL="zsh"
                SHELL_RCS=("$HOME/.zshrc")
                SHELL_PROFILES=("$HOME/.zprofile")
                ;;
            */bash|*)
                USER_SHELL="bash"
                SHELL_RCS=("$HOME/.bashrc")
                SHELL_PROFILES=("$HOME/.bash_profile")
                ;;
        esac
    fi

    # Ensure every target file exists before we try to read/write it.
    for f in "${SHELL_RCS[@]}" "${SHELL_PROFILES[@]}"; do
        [ -e "$f" ] || touch "$f"
    done

    info "Detected shell: $USER_SHELL"
    info "Writing shell integrations to: ${SHELL_RCS[*]} ${SHELL_PROFILES[*]}"
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
#    brew shellenv must live in PROFILE files (login-shell env), not RC files.
#    On macOS we write to BOTH .zprofile and .bash_profile so either shell
#    picks up brew on next login — matches Homebrew's own post-install advice.
# -----------------------------------------------------------------------------
install_homebrew() {
    if [ "$OS" != "mac" ]; then return; fi

    if command -v brew &>/dev/null; then
        success "Homebrew already installed"
    else
        info "Installing Homebrew..."
        info "You may be prompted for your password."
        # Re-cache sudo in case Xcode CLT install took a long time (5 min timeout)
        sudo -v 2>/dev/null || true
        # NONINTERACTIVE=1 skips the "Press RETURN" prompt — the installer auto-sets
        # this when stdin isn't a TTY, but being explicit is safer. sudo -v above
        # ensures the cached credential is fresh so sudo -n succeeds.
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Pick the right brew prefix and eval it into THIS shell so subsequent
        # install_git / install_node steps see `brew`.
        if [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            BREW_SHELLENV_LINE='eval "$(/opt/homebrew/bin/brew shellenv)"'
        elif [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
            BREW_SHELLENV_LINE='eval "$(/usr/local/bin/brew shellenv)"'
        else
            BREW_SHELLENV_LINE=""
        fi

        # Persist brew shellenv into ALL profile files (idempotent per file).
        if [ -n "$BREW_SHELLENV_LINE" ]; then
            for profile in "${SHELL_PROFILES[@]}"; do
                [ -e "$profile" ] || touch "$profile"
                if ! grep -q 'brew shellenv' "$profile" 2>/dev/null; then
                    echo "" >> "$profile"
                    echo '# Homebrew' >> "$profile"
                    echo "$BREW_SHELLENV_LINE" >> "$profile"
                    info "Added Homebrew shellenv to $profile"
                fi
            done
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
# 8. Claude Code + shell integrations
#    Aliases and PATH live in RC files (interactive-shell config), NOT profile
#    files. We loop across every RC in SHELL_RCS so both zsh + bash sessions
#    on macOS see the shortcuts — fixes the Terminal.app-launches-zsh bug
#    where the passwd shell is bash but Terminal actually runs zsh.
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

    # Add Claude Code shortcuts to every RC file. Idempotent per-file — re-runs
    # fill gaps without duplicating. Also migrates the old `alias ctg=` line
    # (now replaced by ~/.local/bin/ctg which can do the token pre-check).
    local total_aliases_added=0
    for rc in "${SHELL_RCS[@]}"; do
        [ -e "$rc" ] || touch "$rc"

        local aliases_added_here=0

        # Marker comment — only once per file
        if ! grep -q '# Claude Code shortcuts' "$rc" 2>/dev/null; then
            echo "" >> "$rc"
            echo "# Claude Code shortcuts" >> "$rc"
        fi

        # Each alias — skip if already present in this rc
        for alias_line in \
            "alias cskip='claude --dangerously-skip-permissions'" \
            "alias cc='claude'" \
            "alias ccr='claude --resume'" \
            "alias ccc='claude --continue'"; do
            ALIAS_NAME=$(echo "$alias_line" | sed "s/alias \([^=]*\)=.*/\1/")
            if ! grep -q "alias ${ALIAS_NAME}=" "$rc" 2>/dev/null; then
                echo "$alias_line" >> "$rc"
                aliases_added_here=$((aliases_added_here + 1))
            fi
        done

        # Migrate old ctg alias → script (alias can't do token check; script can)
        if grep -q 'alias ctg=' "$rc" 2>/dev/null; then
            sed -i.bak '/alias ctg=/d' "$rc"
            info "Removed old ctg alias from $rc (replaced by ~/.local/bin/ctg)"
        fi

        # Add ~/.local/bin to PATH if not already present in this rc
        if ! grep -q '\.local/bin' "$rc" 2>/dev/null; then
            echo "" >> "$rc"
            echo '# Local bin (ctg)' >> "$rc"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
            success "Added ~/.local/bin to PATH in $rc"
        else
            success "$HOME/.local/bin already configured in $rc"
        fi

        if [ "$aliases_added_here" -gt 0 ]; then
            success "Added $aliases_added_here new shortcut(s) to $rc"
        else
            success "All shortcuts already configured in $rc (cskip, cc, ccr, ccc)"
        fi
        total_aliases_added=$((total_aliases_added + aliases_added_here))
    done

    # Install ctg command (Telegram + skip-permissions, any directory)
    info "Installing ctg command to ~/.local/bin..."
    cat > "$HOME/.local/bin/ctg" << 'CTG_EOF'
#!/usr/bin/env bash
# ctg — Launch Claude Code with Telegram channel + dangerously-skip-permissions
# Checks for a valid bot token before launching to avoid an infinite warning loop

TOKEN_FILE="$HOME/.claude/channels/telegram/.env"

if [ ! -f "$TOKEN_FILE" ] || ! grep -qE 'TELEGRAM_BOT_TOKEN=.+' "$TOKEN_FILE" 2>/dev/null; then
  echo ""
  echo "Telegram bot token not configured."
  echo "Run Step 8 to set it up:"
  echo ""
  echo "  bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-8/step-8-install.sh)"
  echo ""
  echo "Or use 'cskip' to launch Claude without Telegram."
  echo ""
  exit 1
fi

exec claude --dangerously-skip-permissions --channels plugin:telegram@claude-plugins-official "$@"
CTG_EOF
    chmod +x "$HOME/.local/bin/ctg"
    success "ctg command installed to ~/.local/bin/ctg"

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

    # Claude Code
    if command -v claude &>/dev/null; then
        success "TEST: claude — $(claude --version 2>/dev/null || echo 'found')"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: claude — not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Shell aliases — success if each alias appears in AT LEAST ONE rc file.
    # On macOS we write to both zsh + bash, and finding it in either shell's
    # rc is enough (user only opens one shell at a time in practice).
    ALIAS_PASS=0
    ALIAS_TOTAL=4
    for alias_name in cskip cc ccr ccc; do
        found_in_any_rc=0
        for rc in "${SHELL_RCS[@]}"; do
            if grep -q "alias ${alias_name}=" "$rc" 2>/dev/null; then
                found_in_any_rc=1
                break
            fi
        done
        if [ "$found_in_any_rc" -eq 1 ]; then
            ALIAS_PASS=$((ALIAS_PASS + 1))
        fi
    done
    if [ "$ALIAS_PASS" -eq "$ALIAS_TOTAL" ]; then
        success "TEST: shell aliases — all $ALIAS_TOTAL configured (cskip, cc, ccr, ccc) across ${SHELL_RCS[*]}"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: shell aliases — only $ALIAS_PASS/$ALIAS_TOTAL found across ${SHELL_RCS[*]}"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # ctg command
    if [ -x "$HOME/.local/bin/ctg" ]; then
        success "TEST: ctg command — installed at ~/.local/bin/ctg"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: ctg command — not found or not executable"
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
    echo -e "${YELLOW}  NEXT: Move to Step 2${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    if [ "${#SHELL_RCS[@]}" -gt 1 ]; then
        echo -e "  1. Reload your shell config (source whichever one matches your current shell):"
        echo ""
        for rc in "${SHELL_RCS[@]}"; do
            echo -e "     ${GREEN}source $rc${NC}"
        done
        echo ""
        echo -e "     ${BLUE}Note:${NC} You have both zsh and bash configured — either shell now works."
        echo "     macOS Terminal.app defaults to zsh; if you don't know, use .zshrc."
    else
        echo -e "  1. Run this command to reload your shell config:"
        echo ""
        echo -e "     ${GREEN}source ${SHELL_RCS[0]}${NC}"
    fi
    echo ""
    echo -e "  2. Close this terminal window and reopen it."
    echo ""
    echo -e "  3. Verify Claude is working by running:"
    echo ""
    echo -e "     ${GREEN}claude --version${NC}"
    echo ""
    echo "     If you see a version number, you're good to go."
    echo -e "     You can press ${GREEN}Ctrl+C${NC} to exit, then type ${GREEN}cskip${NC} to continue with auto-approve mode."
    echo ""
    echo "  4. Set up your Claude account at claude.ai"
    echo "     (you need a paid subscription, see the README)."
    echo ""
    echo "  5. Optional: Install Ghostty terminal (see Bonus in the README)."
    echo "     Or skip it and continue straight to Step 2."
    echo ""
    echo -e "  ${BLUE}Tip:${NC} Press ${GREEN}Shift+Tab${NC} while Claude is running to"
    echo "  toggle permissions on and off — works in any terminal."
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
    # Source any brew/nvm/.local/bin that already exist so a re-run in a fresh
    # shell sees previously-installed tools before we start detecting them.
    source_runtime_path

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Step 1 — Get Claude Running${NC}"
    echo -e "${BLUE}  4 tools • macOS + Linux${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${YELLOW}Note: This script installs everything automatically, but${NC}"
    echo -e "  ${YELLOW}the steps AFTER it finishes (Claude login) are${NC}"
    echo -e "  ${YELLOW}manual. Claude won't be helping in your terminal yet —${NC}"
    echo -e "  ${YELLOW}that starts after you complete the setup steps below.${NC}"
    echo -e "  ${YELLOW}It should be smooth, but if something goes wrong, check${NC}"
    echo -e "  ${YELLOW}the test results at the end of this script.${NC}"
    echo ""

    detect_os
    preflight_checks

    # Prompt for sudo password upfront so it doesn't interrupt mid-install
    info "Some tools require sudo. You may be prompted for your password."
    sudo -v 2>/dev/null || true

    update_package_index
    install_build_tools
    install_homebrew
    install_git
    install_node

    # Ensure base directories exist (tools assume these)
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.cache"

    install_claude_code
    run_self_test
    print_summary
    show_next_steps

    # Sentinel — lets step-2+ (and any orchestrator) detect "step-1 is done".
    mkdir -p "$HOME/.cli-maxxing"
    touch "$HOME/.cli-maxxing/step-1.done"
}

main "$@"
