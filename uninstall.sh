#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Uninstall — Remove everything installed by CLI Maxxing
# Reverses all setup steps. Does NOT remove Homebrew, Git, nvm, or Node.js
# themselves — they are user tools and other things on the system likely
# depend on them. We only strip the specific lines/files WE wrote.
#
# On macOS, step-1 writes shell integrations to BOTH zsh + bash config files
# (.zshrc, .bashrc, .zprofile, .bash_profile) because Terminal.app defaults
# to zsh even when passwd says bash. Uninstall must clean all four.
#
# Usage: curl -fsSL <hosted-url>/uninstall.sh | bash
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REMOVED=0
SKIPPED=0

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[REMOVED]${NC} $1"; REMOVED=$((REMOVED + 1)); }
skip()    { echo -e "${YELLOW}[SKIP]${NC} $1"; SKIPPED=$((SKIPPED + 1)); }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }

# -----------------------------------------------------------------------------
# source_runtime_path — hydrate brew/nvm/~/.local/bin into this shell so that
# `claude mcp remove`, `brew uninstall`, `npm uninstall`, etc. can actually
# find their binaries even if the parent shell never sourced its rc files.
# Idempotent — safe to call multiple times.
# -----------------------------------------------------------------------------
source_runtime_path() {
    if command -v brew &>/dev/null; then
        eval "$(brew shellenv)" 2>/dev/null || true
    elif [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
    elif [ -x "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
    elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
    fi

    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck disable=SC1091
        \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
    fi

    if [ -d "$HOME/.local/bin" ]; then
        case ":$PATH:" in
            *":$HOME/.local/bin:"*) ;;
            *) export PATH="$HOME/.local/bin:$PATH" ;;
        esac
    fi
}

# -----------------------------------------------------------------------------
# detect_os — mirrors step-1's multi-shell detection so we clean the same set
# of rc + profile files that install wrote to.
# macOS: both zsh + bash (.zshrc, .bashrc, .zprofile, .bash_profile).
# Linux: single login shell via getent passwd.
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin) OS="mac" ;;
        Linux)  OS="linux" ;;
        *)      OS="linux" ;;  # best-effort for unknown Unixes
    esac

    if [ "$OS" = "mac" ]; then
        SHELL_RCS=("$HOME/.zshrc" "$HOME/.bashrc")
        SHELL_PROFILES=("$HOME/.zprofile" "$HOME/.bash_profile")
        USER_SHELL="zsh+bash"
    else
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

    info "Detected OS: $OS (shell targets: $USER_SHELL)"
    info "Cleaning RC files:      ${SHELL_RCS[*]}"
    info "Cleaning profile files: ${SHELL_PROFILES[*]}"
}

# -----------------------------------------------------------------------------
# strip_line — delete every line matching $1 in file $2 (portable sed -i.bak)
# Silent no-op if file doesn't exist.
# -----------------------------------------------------------------------------
strip_line() {
    local pattern="$1"
    local file="$2"
    [ -f "$file" ] || return 0
    if grep -q "$pattern" "$file" 2>/dev/null; then
        sed -i.bak "/$pattern/d" "$file" 2>/dev/null || true
        rm -f "${file}.bak"
        return 0
    fi
    return 1
}

# -----------------------------------------------------------------------------
# strip_block — delete from $1 through $2 (inclusive) in $3. Block-style sed.
# Used for multi-line things we wrote (g2/g4 function bodies).
# -----------------------------------------------------------------------------
strip_block() {
    local start="$1"
    local end="$2"
    local file="$3"
    [ -f "$file" ] || return 0
    if grep -q "$start" "$file" 2>/dev/null; then
        sed -i.bak "/$start/,/$end/d" "$file" 2>/dev/null || true
        rm -f "${file}.bak"
        return 0
    fi
    return 1
}

# -----------------------------------------------------------------------------
# confirm_uninstall — preserve existing "this will remove stuff" banner and
# give the user one last chance to bail if running interactively.
# -----------------------------------------------------------------------------
confirm_uninstall() {
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  Uninstall — CLI Maxxing${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  This will remove tools and configurations installed by"
    echo "  CLI Maxxing (all steps). Your Obsidian vault, notes,"
    echo "  Homebrew, Node.js, and user-installed skills will NOT be deleted."
    echo ""

    # Only prompt when stdin is a TTY. curl|bash installs run non-interactively
    # and should proceed without prompting (same pattern as install.sh).
    if [ -t 0 ]; then
        read -r -p "  Continue? [y/N] " reply
        case "$reply" in
            [yY]|[yY][eE][sS]) ;;
            *) echo "  Aborted."; exit 0 ;;
        esac
        echo ""
    fi
}

# -----------------------------------------------------------------------------
# Final Step — Status Line
# -----------------------------------------------------------------------------
uninstall_status_line() {
    echo -e "${BLUE}--- Final Step: Status Line ---${NC}"

    if [ -f "$HOME/.claude/statusline.sh" ]; then
        rm -f "$HOME/.claude/statusline.sh"
        success "Status line script"
    else
        skip "Status line script (not found)"
    fi

    # Remove statusline hook from settings if present — don't mutate settings.json
    # directly (CLAUDE.md rule: always jq-merge, never overwrite).
    if [ -f "$HOME/.claude/settings.json" ]; then
        if grep -q "statusline" "$HOME/.claude/settings.json" 2>/dev/null; then
            info "Status line hook found in settings.json — remove manually via Claude settings"
        fi
    fi
}

# -----------------------------------------------------------------------------
# Step 9 — SafetyCheck
# -----------------------------------------------------------------------------
uninstall_safetycheck() {
    echo ""
    echo -e "${BLUE}--- Step 9: SafetyCheck ---${NC}"

    if [ -d "$HOME/.claude/skills/safetycheck" ]; then
        rm -rf "$HOME/.claude/skills/safetycheck"
        success "SafetyCheck skill (~/.claude/skills/safetycheck)"
    else
        skip "SafetyCheck skill (not found)"
    fi
}

# -----------------------------------------------------------------------------
# Step 8 — Telegram
# -----------------------------------------------------------------------------
uninstall_telegram() {
    echo ""
    echo -e "${BLUE}--- Step 8: Telegram ---${NC}"

    if [ -d "$HOME/.claude/channels/telegram" ]; then
        rm -rf "$HOME/.claude/channels/telegram"
        success "Telegram config directory (~/.claude/channels/telegram)"
    else
        skip "Telegram config directory (not found)"
    fi
}

# -----------------------------------------------------------------------------
# Step 6 — Productivity Tools
# (Notion, Granola, n8n, Google Calendar, Morgen, Motion Calendar, Playwright)
# -----------------------------------------------------------------------------
uninstall_productivity_mcps() {
    echo ""
    echo -e "${BLUE}--- Step 6: Productivity Tools ---${NC}"

    for mcp in notion granola n8n google-calendar morgen motion playwright; do
        if claude mcp list 2>/dev/null | grep -qi "$mcp" 2>/dev/null; then
            claude mcp remove "$mcp" 2>/dev/null || true
            success "$mcp MCP"
        else
            skip "$mcp MCP (not found)"
        fi
    done

    # Google Calendar config
    if [ -d "$HOME/.google-calendar-mcp" ]; then
        rm -rf "$HOME/.google-calendar-mcp"
        success "Google Calendar config (~/.google-calendar-mcp)"
    else
        skip "Google Calendar config (not found)"
    fi

    # Motion Calendar config
    if [ -d "$HOME/.motion-mcp" ]; then
        rm -rf "$HOME/.motion-mcp"
        success "Motion Calendar config (~/.motion-mcp)"
    else
        skip "Motion Calendar config (not found)"
    fi
}

# -----------------------------------------------------------------------------
# Step 3 — FidgetFlo + Context Hub + skills
# -----------------------------------------------------------------------------
uninstall_fidgetflo_stack() {
    echo ""
    echo -e "${BLUE}--- Step 3: FidgetFlo + Context Hub ---${NC}"

    # FidgetFlo MCP
    if claude mcp list 2>/dev/null | grep -qi "fidgetflo" 2>/dev/null; then
        claude mcp remove fidgetflo 2>/dev/null || true
        success "FidgetFlo MCP server"
    else
        skip "FidgetFlo MCP server (not found)"
    fi

    # Claude-flow MCP
    if claude mcp list 2>/dev/null | grep -qi "claude-flow" 2>/dev/null; then
        claude mcp remove claude-flow 2>/dev/null || true
        success "Claude-flow MCP server"
    else
        skip "Claude-flow MCP server (not found)"
    fi

    # Global npm packages
    for pkg in fidgetflo@latest agentic-flow@latest @aisuite/chub typescript; do
        PKG_NAME=$(echo "$pkg" | sed 's/@latest//')
        if npm list -g "$PKG_NAME" 2>/dev/null | grep -q "$PKG_NAME"; then
            npm uninstall -g "$PKG_NAME" 2>/dev/null || true
            success "npm: $PKG_NAME"
        else
            skip "npm: $PKG_NAME (not found)"
        fi
    done

    # cli-maxxing-installed skill files. User-installed skills not in this list
    # (design-taste-*, high-end-visual-design, /save, /wiki, etc.) are preserved.
    for skill in \
        fswarm fswarm1 fswarm2 fswarm3 fswarmmax \
        fmini fmini1 fmini2 fmini3 fminimax \
        fhive get-api-docs w4w gitfix; do
        if [ -d "$HOME/.claude/skills/$skill" ]; then
            rm -rf "$HOME/.claude/skills/$skill"
            success "Skill: /$skill"
        else
            skip "Skill: /$skill (not found)"
        fi
    done

    # Claude-flow config directory (created by step-3 npx init)
    if [ -d "$HOME/.claude-flow" ]; then
        rm -rf "$HOME/.claude-flow"
        success ".claude-flow config directory"
    else
        skip ".claude-flow config (not found)"
    fi
}

# -----------------------------------------------------------------------------
# Step 2 — Dev Tools (brew packages)
# -----------------------------------------------------------------------------
uninstall_dev_tools() {
    echo ""
    echo -e "${BLUE}--- Step 2: Dev Tools ---${NC}"

    for tool in pandoc poppler jq ripgrep gh tree fzf wget weasyprint; do
        if command -v "$tool" &>/dev/null || brew list "$tool" &>/dev/null 2>&1; then
            brew uninstall "$tool" 2>/dev/null || true
            success "brew: $tool"
        else
            skip "brew: $tool (not found)"
        fi
    done

    # xlsx2csv (pip)
    if python3 -c "import xlsx2csv" 2>/dev/null; then
        python3 -m pip uninstall xlsx2csv -y 2>/dev/null || true
        success "pip: xlsx2csv"
    else
        skip "pip: xlsx2csv (not found)"
    fi
}

# -----------------------------------------------------------------------------
# Bonus — Ghostty Config (remove config only, keep the app)
# -----------------------------------------------------------------------------
uninstall_ghostty() {
    echo ""
    echo -e "${BLUE}--- Bonus: Ghostty Config ---${NC}"

    GHOSTTY_CONFIG_MAC="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
    GHOSTTY_CONFIG_LINUX="$HOME/.config/ghostty/config"

    if [ -f "$GHOSTTY_CONFIG_MAC" ]; then
        rm -f "$GHOSTTY_CONFIG_MAC"
        rm -f "${GHOSTTY_CONFIG_MAC}.backup"
        success "Ghostty config (macOS)"
    elif [ -f "$GHOSTTY_CONFIG_LINUX" ]; then
        rm -f "$GHOSTTY_CONFIG_LINUX"
        rm -f "${GHOSTTY_CONFIG_LINUX}.backup"
        success "Ghostty config (Linux)"
    else
        skip "Ghostty config (not found)"
    fi

    # duti (installed by bonus-ghostty.sh)
    if brew list duti &>/dev/null 2>&1; then
        brew uninstall duti 2>/dev/null || true
        success "brew: duti"
    else
        skip "brew: duti (not found)"
    fi
}

# -----------------------------------------------------------------------------
# Bonus — Arc Browser (remove the app if installed via bonus script)
# -----------------------------------------------------------------------------
uninstall_arc() {
    echo ""
    echo -e "${BLUE}--- Bonus: Arc Browser ---${NC}"

    if [ -d "/Applications/Arc.app" ] && brew list --cask arc &>/dev/null 2>&1; then
        brew uninstall --cask arc 2>/dev/null || true
        success "Arc Browser (brew cask)"
    else
        skip "Arc Browser (not found or not installed via Homebrew)"
    fi
}

# -----------------------------------------------------------------------------
# Step 1 — Claude Code, aliases, commands, shell integrations
# Clean every file in SHELL_RCS (.zshrc + .bashrc on macOS) and SHELL_PROFILES
# (.zprofile + .bash_profile on macOS). Only strip lines WE wrote, keyed on
# either the marker comment we own or the specific alias/export names we added.
# -----------------------------------------------------------------------------
uninstall_step_1() {
    echo ""
    echo -e "${BLUE}--- Step 1: Claude Code + Shortcuts ---${NC}"

    # Claude Code global npm package. Don't remove Node/nvm — user tool.
    if command -v claude &>/dev/null; then
        npm uninstall -g @anthropic-ai/claude-code 2>/dev/null \
            || sudo npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || true
        success "Claude Code"
    else
        skip "Claude Code (not found)"
    fi

    # -------------------------------------------------------------------------
    # Clean RC files (.zshrc / .bashrc — interactive shell config)
    # -------------------------------------------------------------------------
    local rc_alias_removed=0
    local rc_flicker_removed=0
    local rc_localbin_removed=0
    local rc_ghostty_removed=0

    for rc in "${SHELL_RCS[@]}"; do
        [ -f "$rc" ] || continue

        # Header marker we wrote ("# Claude Code shortcuts") — safe to delete,
        # it's unique to us.
        strip_line '# Claude Code shortcuts' "$rc"

        # Aliases — only the exact names step-1 wrote. User's own aliases with
        # different names stay.
        for alias_name in cskip cc ccr ccc; do
            if strip_line "alias ${alias_name}=" "$rc"; then
                rc_alias_removed=$((rc_alias_removed + 1))
            fi
        done

        # Also remove the old deprecated `alias ctg=` in case it's still around
        # (step-1 migrates this to ~/.local/bin/ctg, but older installs may
        # still have the alias line).
        strip_line 'alias ctg=' "$rc"

        # No-flicker env vars + marker we wrote
        for flicker_pat in 'CLAUDE_CODE_NO_FLICKER' 'CLAUDE_CODE_SCROLL_SPEED' '# Claude Code — no-flicker'; do
            if strip_line "$flicker_pat" "$rc"; then
                rc_flicker_removed=$((rc_flicker_removed + 1))
            fi
        done

        # ~/.local/bin PATH entry — OUR marker "# Local bin (ctg" is unique.
        # Remove the marker line AND the export on the next line if it matches
        # what we wrote. We only strip a bare `export PATH="$HOME/.local/bin:$PATH"`
        # — user's more elaborate PATH lines (with extra paths) are left alone.
        if grep -q '# Local bin (ctg' "$rc" 2>/dev/null; then
            strip_line '# Local bin (ctg' "$rc"
            strip_line '^export PATH="\$HOME/\.local/bin:\$PATH"$' "$rc"
            rc_localbin_removed=$((rc_localbin_removed + 1))
        fi

        # g2 / g4 Ghostty window-tiling functions — WE wrote these as
        # multi-line function bodies under a `# Ghostty window tiling` header.
        if grep -q '# Ghostty window tiling' "$rc" 2>/dev/null \
           || grep -q '^g2()' "$rc" 2>/dev/null \
           || grep -q '^g4()' "$rc" 2>/dev/null; then
            strip_block '# Ghostty window tiling' '^}' "$rc"
            strip_block '^g2()' '^}' "$rc"
            strip_block '^g4()' '^}' "$rc"
            rc_ghostty_removed=$((rc_ghostty_removed + 1))
        fi
    done

    if [ "$rc_alias_removed" -gt 0 ]; then
        success "Shell aliases ($rc_alias_removed removed across ${SHELL_RCS[*]})"
    else
        skip "Shell aliases (not found in any rc file)"
    fi

    if [ "$rc_flicker_removed" -gt 0 ]; then
        success "No-flicker mode ($rc_flicker_removed lines removed across ${SHELL_RCS[*]})"
    else
        skip "No-flicker mode (not found in any rc file)"
    fi

    if [ "$rc_localbin_removed" -gt 0 ]; then
        success "\$HOME/.local/bin PATH entry removed from $rc_localbin_removed rc file(s)"
    else
        skip "\$HOME/.local/bin PATH entry (not found in any rc file)"
    fi

    if [ "$rc_ghostty_removed" -gt 0 ]; then
        success "g2/g4 window tiling functions removed from $rc_ghostty_removed rc file(s)"
    else
        skip "g2/g4 window tiling (not found in any rc file)"
    fi

    # -------------------------------------------------------------------------
    # Clean profile files (.zprofile / .bash_profile — login shell config)
    # Only the Homebrew shellenv block step-1 wrote under its `# Homebrew`
    # marker. If brew was installed some other way, the user's own setup
    # stays intact.
    # -------------------------------------------------------------------------
    local profile_brew_removed=0
    for profile in "${SHELL_PROFILES[@]}"; do
        [ -f "$profile" ] || continue

        # Only strip if OUR marker is present. Homebrew's own installer writes
        # a similar line but without this exact single-word `# Homebrew` header
        # that step-1 uses.
        if grep -q '^# Homebrew$' "$profile" 2>/dev/null \
           && grep -q 'brew shellenv' "$profile" 2>/dev/null; then
            strip_line '^# Homebrew$' "$profile"
            strip_line 'eval "\$(/opt/homebrew/bin/brew shellenv)"' "$profile"
            strip_line 'eval "\$(/usr/local/bin/brew shellenv)"' "$profile"
            profile_brew_removed=$((profile_brew_removed + 1))
        fi
    done

    if [ "$profile_brew_removed" -gt 0 ]; then
        success "Homebrew shellenv block removed from $profile_brew_removed profile file(s)"
    else
        skip "Homebrew shellenv block (not found or installed by a different tool — leaving alone)"
    fi

    # -------------------------------------------------------------------------
    # ctg command (~/.local/bin script). cbrain/cbraintg are managed by the
    # companion 2ndBrain-mogging installer — we don't touch those.
    # -------------------------------------------------------------------------
    if [ -f "$HOME/.local/bin/ctg" ]; then
        rm -f "$HOME/.local/bin/ctg"
        success "ctg command"
    else
        skip "ctg command (not found)"
    fi

    # -------------------------------------------------------------------------
    # cli-maxxing breadcrumbs directory (step-N.done sentinels)
    # -------------------------------------------------------------------------
    if [ -d "$HOME/.cli-maxxing" ]; then
        rm -rf "$HOME/.cli-maxxing"
        success "cli-maxxing breadcrumbs (~/.cli-maxxing)"
    else
        skip "cli-maxxing breadcrumbs (~/.cli-maxxing not found)"
    fi
}

# -----------------------------------------------------------------------------
# Optional heavy deps notice (brew / nvm / node) — we never auto-remove these
# -----------------------------------------------------------------------------
print_heavy_deps_notice() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  Optional: Core Dependencies${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  The following were installed by Step 1 but are commonly"
    echo "  used by other tools. They were NOT removed automatically:"
    echo ""
    echo "    • Node.js / nvm"
    echo "    • Homebrew"
    echo "    • Git (usually pre-installed)"
    echo ""
    echo "  To remove them manually:"
    echo ""
    echo -e "    ${GREEN}nvm uninstall --lts${NC}          # Remove Node.js"
    echo -e "    ${GREEN}/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)\"${NC}"
    echo "                                  # Remove Homebrew"
    echo ""
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
print_summary() {
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  Uninstall Complete${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Removed: $REMOVED items"
    echo "  Skipped: $SKIPPED items (already absent)"
    echo ""
    echo "  Your Obsidian vault and notes were NOT touched."
    echo ""
    echo "  To finish cleanup, restart your terminal or re-source your shell:"
    echo ""
    if [ "${#SHELL_RCS[@]}" -gt 1 ]; then
        echo "    macOS writes to both zsh + bash configs — source whichever"
        echo "    shell you're actually using:"
        echo ""
        for rc in "${SHELL_RCS[@]}"; do
            echo -e "      ${GREEN}source $rc${NC}"
        done
    else
        echo -e "    ${GREEN}source ${SHELL_RCS[0]}${NC}"
    fi
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    source_runtime_path
    detect_os
    confirm_uninstall

    uninstall_status_line
    uninstall_safetycheck
    uninstall_telegram
    uninstall_productivity_mcps
    uninstall_fidgetflo_stack
    uninstall_dev_tools
    uninstall_ghostty
    uninstall_arc
    uninstall_step_1

    print_heavy_deps_notice
    print_summary
}

main "$@"
