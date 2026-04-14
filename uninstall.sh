#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Uninstall — Remove everything installed by CLI Maxxing
# Reverses all setup steps. Does NOT remove Homebrew, Git, or Node.js since
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
echo -e "${RED}  Uninstall — CLI Maxxing${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  This will remove tools and configurations installed by"
echo "  CLI Maxxing (all steps). Your Obsidian vault and"
echo "  notes will NOT be deleted."
echo ""

# -----------------------------------------------------------------------------
# Final Step — Status Line
# -----------------------------------------------------------------------------
echo -e "${BLUE}--- Final Step: Status Line ---${NC}"

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
# Step 9 — SafetyCheck
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}--- Step 9: SafetyCheck ---${NC}"

if [ -d "$HOME/.claude/skills/safetycheck" ]; then
    rm -rf "$HOME/.claude/skills/safetycheck"
    success "SafetyCheck skill (~/.claude/skills/safetycheck)"
else
    skip "SafetyCheck skill (not found)"
fi

# -----------------------------------------------------------------------------
# Step 8 — Telegram
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}--- Step 8: Telegram ---${NC}"

if [ -d "$HOME/.claude/channels/telegram" ]; then
    rm -rf "$HOME/.claude/channels/telegram"
    success "Telegram config directory (~/.claude/channels/telegram)"
else
    skip "Telegram config directory (not found)"
fi

# -----------------------------------------------------------------------------
# Step 6 — Productivity Tools
# (Notion, Granola, n8n, Google Calendar, Morgen, Motion Calendar)
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}--- Step 6: Productivity Tools ---${NC}"

# Notion MCP
if claude mcp list 2>/dev/null | grep -qi "notion" 2>/dev/null; then
    claude mcp remove notion 2>/dev/null || true
    success "Notion MCP"
else
    skip "Notion MCP (not found)"
fi

# Granola MCP
if claude mcp list 2>/dev/null | grep -qi "granola" 2>/dev/null; then
    claude mcp remove granola 2>/dev/null || true
    success "Granola MCP"
else
    skip "Granola MCP (not found)"
fi

# n8n MCP (user's own n8n instance — HTTP transport, no local config)
if claude mcp list 2>/dev/null | grep -qi "n8n" 2>/dev/null; then
    claude mcp remove n8n 2>/dev/null || true
    success "n8n MCP"
else
    skip "n8n MCP (not found)"
fi

# Google Calendar MCP
if claude mcp list 2>/dev/null | grep -qi "google-calendar" 2>/dev/null; then
    claude mcp remove google-calendar 2>/dev/null || true
    success "Google Calendar MCP"
else
    skip "Google Calendar MCP (not found)"
fi

# Google Calendar config
if [ -d "$HOME/.google-calendar-mcp" ]; then
    rm -rf "$HOME/.google-calendar-mcp"
    success "Google Calendar config (~/.google-calendar-mcp)"
else
    skip "Google Calendar config (not found)"
fi

# Morgen MCP (credentials live in Claude's MCP config, no local .env)
if claude mcp list 2>/dev/null | grep -qi "morgen" 2>/dev/null; then
    claude mcp remove morgen 2>/dev/null || true
    success "Morgen MCP"
else
    skip "Morgen MCP (not found)"
fi

# Motion Calendar MCP
if claude mcp list 2>/dev/null | grep -qi "motion-calendar" 2>/dev/null; then
    claude mcp remove motion-calendar 2>/dev/null || true
    success "Motion Calendar MCP"
else
    skip "Motion Calendar MCP (not found)"
fi

# Motion Calendar config
if [ -d "$HOME/.motion-calendar-mcp" ]; then
    rm -rf "$HOME/.motion-calendar-mcp"
    success "Motion Calendar config (~/.motion-calendar-mcp)"
else
    skip "Motion Calendar config (not found)"
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
for skill in rswarm rmini rhive get-api-docs w4w gitfix; do
    if [ -d "$HOME/.claude/skills/$skill" ]; then
        rm -rf "$HOME/.claude/skills/$skill"
        success "Skill: /$skill"
    else
        skip "Skill: /$skill (not found)"
    fi
done

# Claude-flow config
if [ -d "$HOME/.claude-flow" ]; then
    rm -rf "$HOME/.claude-flow"
    success ".claude-flow config directory"
else
    skip ".claude-flow config (not found)"
fi

# -----------------------------------------------------------------------------
# Step 2 — Dev Tools (brew packages)
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Bonus — Ghostty Config (remove config only, keep the app)
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Bonus — Arc Browser (remove the app if installed via bonus script)
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}--- Bonus: Arc Browser ---${NC}"

if [ -d "/Applications/Arc.app" ] && brew list --cask arc &>/dev/null 2>&1; then
    brew uninstall --cask arc 2>/dev/null || true
    success "Arc Browser (brew cask)"
else
    skip "Arc Browser (not found or not installed via Homebrew)"
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

# Shell aliases (cskip, cc, ccr, ccc) — ctg is a script (~/.local/bin/ctg), removed below
ALIAS_REMOVED=0
# Remove the header comment if present
if grep -q '# Claude Code shortcuts' "$SHELL_RC" 2>/dev/null; then
    sed -i.bak '/# Claude Code shortcuts/d' "$SHELL_RC" 2>/dev/null || true
    rm -f "${SHELL_RC}.bak"
fi
# Remove each alias individually (handles both block and standalone installs)
for alias_name in cskip cc ccr ccc; do
    if grep -q "alias ${alias_name}=" "$SHELL_RC" 2>/dev/null; then
        sed -i.bak "/alias ${alias_name}=/d" "$SHELL_RC" 2>/dev/null || true
        rm -f "${SHELL_RC}.bak"
        ALIAS_REMOVED=$((ALIAS_REMOVED + 1))
    fi
done
if [ "$ALIAS_REMOVED" -gt 0 ]; then
    success "Shell aliases ($ALIAS_REMOVED removed: cskip, cc, ccr, ccc)"
else
    skip "Shell aliases (not found in $SHELL_RC)"
fi

# No-flicker mode env vars
FLICKER_REMOVED=0
for flicker_line in 'CLAUDE_CODE_NO_FLICKER' 'CLAUDE_CODE_SCROLL_SPEED' '# Claude Code — no-flicker'; do
    if grep -q "$flicker_line" "$SHELL_RC" 2>/dev/null; then
        sed -i.bak "/$flicker_line/d" "$SHELL_RC" 2>/dev/null || true
        rm -f "${SHELL_RC}.bak"
        FLICKER_REMOVED=$((FLICKER_REMOVED + 1))
    fi
done
if [ "$FLICKER_REMOVED" -gt 0 ]; then
    success "No-flicker mode ($FLICKER_REMOVED lines removed from $SHELL_RC)"
else
    skip "No-flicker mode (not found in $SHELL_RC)"
fi

# ~/.local/bin PATH entry
if grep -q '# Local bin (ctg' "$SHELL_RC" 2>/dev/null; then
    sed -i.bak '/# Local bin (ctg/d' "$SHELL_RC" 2>/dev/null || true
    rm -f "${SHELL_RC}.bak"
fi
if grep -q '\.local/bin' "$SHELL_RC" 2>/dev/null; then
    sed -i.bak '/\.local\/bin/d' "$SHELL_RC" 2>/dev/null || true
    rm -f "${SHELL_RC}.bak"
    success "$HOME/.local/bin PATH entry removed from $SHELL_RC"
else
    skip "$HOME/.local/bin PATH entry (not found in $SHELL_RC)"
fi

# ctg command (~/.local/bin script) — cbrain/cbraintg are managed by 2ndbrain-maxxing
for cmd in ctg; do
    if [ -f "$HOME/.local/bin/$cmd" ]; then
        rm -f "$HOME/.local/bin/$cmd"
        success "$cmd command"
    else
        skip "$cmd command (not found)"
    fi
done

# g2/g4 window tiling functions
if grep -q 'g2()' "$SHELL_RC" 2>/dev/null; then
    sed -i.bak '/# Ghostty window tiling/,/^}/d' "$SHELL_RC" 2>/dev/null || true
    rm -f "${SHELL_RC}.bak"
    # Clean up both function blocks
    sed -i.bak '/g2()/,/^}/d' "$SHELL_RC" 2>/dev/null || true
    rm -f "${SHELL_RC}.bak"
    sed -i.bak '/g4()/,/^}/d' "$SHELL_RC" 2>/dev/null || true
    rm -f "${SHELL_RC}.bak"
    success "g2/g4 window tiling functions removed from $SHELL_RC"
else
    skip "g2/g4 window tiling (not found in $SHELL_RC)"
fi

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
