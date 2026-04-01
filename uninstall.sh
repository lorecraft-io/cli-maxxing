#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Uninstall — Remove everything installed by AI Super Setup
# Reverses Steps 1-7. Does NOT remove Homebrew, Git, or Node.js since
# other tools may depend on them. Offers to remove those separately.
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

# Detect shell
case "${SHELL:-/bin/bash}" in
    */zsh)  SHELL_RC="$HOME/.zshrc" ;;
    */bash) SHELL_RC="$HOME/.bashrc" ;;
    *)      SHELL_RC="$HOME/.bashrc" ;;
esac

echo ""
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  Uninstall — AI Super Setup${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  This will remove tools and configurations installed by"
echo "  AI Super Setup (Steps 1-7). Your Obsidian vault and"
echo "  notes will NOT be deleted."
echo ""

# -----------------------------------------------------------------------------
# Step 7 — Status Line
# -----------------------------------------------------------------------------
echo -e "${BLUE}--- Step 7: Status Line ---${NC}"

if [ -f "$HOME/.claude/statusline.sh" ]; then
    rm -f "$HOME/.claude/statusline.sh"
    success "Status line script"
else
    skip "Status line script (not found)"
fi

# Remove statusline hook from settings if present
if [ -f "$HOME/.claude/settings.json" ]; then
    if grep -q "statusline" "$HOME/.claude/settings.json" 2>/dev/null; then
        info "Status line hook found in settings.json — remove manually via Claude settings"
    fi
fi

# -----------------------------------------------------------------------------
# Step 5 — Visual Media (Remotion, YouTube Transcript, FFmpeg)
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}--- Step 5: Visual Media ---${NC}"

# Remotion skills
if [ -d "$HOME/.claude/skills/remotion-best-practices" ]; then
    rm -rf "$HOME/.claude/skills/remotion-best-practices"
    success "Remotion skills"
else
    skip "Remotion skills (not found)"
fi

# YouTube Transcript MCP
if claude mcp list 2>/dev/null | grep -qi "youtube-transcript" 2>/dev/null; then
    claude mcp remove youtube-transcript 2>/dev/null || true
    success "YouTube Transcript MCP"
else
    skip "YouTube Transcript MCP (not found)"
fi

# FFmpeg (brew)
if command -v ffmpeg &>/dev/null; then
    brew uninstall ffmpeg 2>/dev/null || true
    success "FFmpeg"
else
    skip "FFmpeg (not found)"
fi

# -----------------------------------------------------------------------------
# Step 4 — Design Tools (UI/UX Pro Max, 21st.dev Magic)
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}--- Step 4: Design Tools ---${NC}"

# UI/UX Pro Max skill
if [ -d "$HOME/.claude/skills/ui-ux-pro-max" ]; then
    rm -rf "$HOME/.claude/skills/ui-ux-pro-max"
    success "UI/UX Pro Max skill"
else
    skip "UI/UX Pro Max skill (not found)"
fi

# 21st.dev Magic MCP
if claude mcp list 2>/dev/null | grep -qi "magic\|21st" 2>/dev/null; then
    claude mcp remove magic 2>/dev/null || true
    success "21st.dev Magic MCP"
else
    skip "21st.dev Magic MCP (not found)"
fi

# -----------------------------------------------------------------------------
# Step 3 — Ruflo + Context Hub
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}--- Step 3: Ruflo + Context Hub ---${NC}"

# Ruflo MCP
if claude mcp list 2>/dev/null | grep -qi "ruflo" 2>/dev/null; then
    claude mcp remove ruflo 2>/dev/null || true
    success "Ruflo MCP server"
else
    skip "Ruflo MCP server (not found)"
fi

# Claude-flow MCP
if claude mcp list 2>/dev/null | grep -qi "claude-flow" 2>/dev/null; then
    claude mcp remove claude-flow 2>/dev/null || true
    success "Claude-flow MCP server"
else
    skip "Claude-flow MCP server (not found)"
fi

# Global npm packages
for pkg in ruflo@latest agentic-flow@latest @aisuite/chub typescript; do
    PKG_NAME=$(echo "$pkg" | sed 's/@latest//')
    if npm list -g "$PKG_NAME" 2>/dev/null | grep -q "$PKG_NAME"; then
        npm uninstall -g "$PKG_NAME" 2>/dev/null || true
        success "npm: $PKG_NAME"
    else
        skip "npm: $PKG_NAME (not found)"
    fi
done

# Swarm skills
for skill in rswarm rhive get-api-docs; do
    if [ -d "$HOME/.claude/skills/$skill" ]; then
        rm -rf "$HOME/.claude/skills/$skill"
        success "Skill: /$skill"
    else
        skip "Skill: /$skill (not found)"
    fi
done

# Claude-flow config
if [ -d ".claude-flow" ]; then
    rm -rf .claude-flow
    success ".claude-flow config directory"
else
    skip ".claude-flow config (not found)"
fi

# -----------------------------------------------------------------------------
# Step 2 — Dev Tools (brew packages)
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}--- Step 2: Dev Tools ---${NC}"

for tool in pandoc poppler jq ripgrep gh tree fzf wget; do
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

# -----------------------------------------------------------------------------
# Step 1 — Claude Code, aliases, commands
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}--- Step 1: Claude Code + Shortcuts ---${NC}"

# Claude Code
if command -v claude &>/dev/null; then
    npm uninstall -g @anthropic-ai/claude-code 2>/dev/null \
        || sudo npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || true
    success "Claude Code"
else
    skip "Claude Code (not found)"
fi

# Shell aliases (cskip, cauto, cc, ccr, ccc)
ALIAS_REMOVED=0
# Remove the header comment if present
if grep -q '# Claude Code shortcuts' "$SHELL_RC" 2>/dev/null; then
    sed -i.bak '/# Claude Code shortcuts/d' "$SHELL_RC" 2>/dev/null || true
    rm -f "${SHELL_RC}.bak"
fi
# Remove each alias individually (handles both block and standalone installs)
for alias_name in cskip cauto cc ccr ccc; do
    if grep -q "alias ${alias_name}=" "$SHELL_RC" 2>/dev/null; then
        sed -i.bak "/alias ${alias_name}=/d" "$SHELL_RC" 2>/dev/null || true
        rm -f "${SHELL_RC}.bak"
        ALIAS_REMOVED=$((ALIAS_REMOVED + 1))
    fi
done
if [ "$ALIAS_REMOVED" -gt 0 ]; then
    success "Shell aliases ($ALIAS_REMOVED removed: cskip, cauto, cc, ccr, ccc)"
else
    skip "Shell aliases (not found in $SHELL_RC)"
fi

# c2danger, cbrain, cbraintg, and c2tgdanger commands
for cmd in c2danger cbrain cbraintg c2tgdanger; do
    if [ -f "$HOME/.local/bin/$cmd" ]; then
        rm -f "$HOME/.local/bin/$cmd"
        success "$cmd command"
    else
        skip "$cmd command (not found)"
    fi
done

# -----------------------------------------------------------------------------
# Optional: Heavy dependencies
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  Uninstall Complete${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Removed: $REMOVED items"
echo "  Skipped: $SKIPPED items (already absent)"
echo ""
echo "  Your Obsidian vault and notes were NOT touched."
echo ""
echo "  To finish cleanup, restart your terminal or run:"
echo ""
echo -e "    ${GREEN}source $SHELL_RC${NC}"
echo ""
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
