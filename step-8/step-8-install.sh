#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 8 — Telegram
# Connect Claude to Telegram — send and receive messages from your phone
# Run after Step 7 (Second Brain) or earlier — requires Step 1 for aliases
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
# Ensure runtime PATH (brew, nvm, ~/.local/bin) is visible.
# Defense-in-depth: users typically run Step 8 in a fresh terminal after
# Steps 1-7 completed, but installers/nvm don't always source their shell
# rc files in non-login shells. This makes `node`, `npm`, `claude`, `ctg`,
# and `cbraintg` resolvable regardless of how the user invoked the script.
# -----------------------------------------------------------------------------
source_runtime_path() {
    # Homebrew shellenv — try the first brew binary we find.
    local brew_bin
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        if [ -x "$brew_bin" ]; then
            eval "$("$brew_bin" shellenv)" 2>/dev/null || true
            break
        fi
    done

    # nvm — source it if installed so `node`/`npm` resolve.
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck disable=SC1091
        . "$NVM_DIR/nvm.sh" 2>/dev/null || true
    fi

    # ~/.local/bin — prepend if not already on PATH.
    if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

source_runtime_path

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Step 8 — Telegram${NC}"
echo -e "${BLUE}  Connect Claude to Telegram — message Claude from your phone${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# =============================================================================
# Prerequisites
# =============================================================================
info "Checking prerequisites..."
echo ""

PREREQ_PASS=true

# Check Claude Code installed
if command -v claude &>/dev/null; then
    success "Claude Code is installed"
else
    warn "Claude Code not found — run Step 1 first"
    PREREQ_PASS=false
fi

# Check ctg command (installed as ~/.local/bin/ctg script by Step 1)
if [ -x "$HOME/.local/bin/ctg" ]; then
    success "ctg command found at ~/.local/bin/ctg"
else
    warn "ctg not found at ~/.local/bin/ctg — re-run Step 1 to set it up"
    PREREQ_PASS=false
fi

# Check cbraintg command
if [ -x "$HOME/.local/bin/cbraintg" ]; then
    success "cbraintg command found at ~/.local/bin/cbraintg"
else
    warn "cbraintg not found at ~/.local/bin/cbraintg — re-run Step 1 to set it up"
    PREREQ_PASS=false
fi

echo ""

if [ "$PREREQ_PASS" = false ]; then
    warn "Some prerequisites are missing. The bot token can still be configured,"
    warn "but you will need to re-run Step 1 before launching Claude with Telegram."
    echo ""
fi

# =============================================================================
# Check Existing Configuration
# =============================================================================
CONFIG_DIR="$HOME/.claude/channels/telegram"
TOKEN_FILE="$CONFIG_DIR/.env"
ACCESS_FILE="$CONFIG_DIR/access.json"
SKIP_TOKEN=false

if [ -f "$TOKEN_FILE" ] && grep -q 'TELEGRAM_BOT_TOKEN=' "$TOKEN_FILE" 2>/dev/null; then
    EXISTING_TOKEN=$(grep 'TELEGRAM_BOT_TOKEN=' "$TOKEN_FILE" 2>/dev/null | cut -d= -f2)
    # Mask the token for display
    if [ ${#EXISTING_TOKEN} -gt 12 ]; then
        MASKED="${EXISTING_TOKEN:0:4}...${EXISTING_TOKEN: -4}"
    else
        MASKED="****"
    fi
    echo -e "${YELLOW}Telegram bot token already configured: ${MASKED}${NC}"
    echo ""
    read -p "Reconfigure with a new token? (y/N): " RECONFIGURE
    if [[ ! "$RECONFIGURE" =~ ^[Yy]$ ]]; then
        info "Keeping existing configuration."
        echo ""
        SKIP_TOKEN=true
    fi
fi

# =============================================================================
# BotFather Instructions + Token Prompt
# =============================================================================
if [ "$SKIP_TOKEN" = false ]; then
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Create Your Telegram Bot${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  1. Open Telegram on your phone or desktop"
    echo "  2. Search for @BotFather and start a chat"
    echo "  3. Send the command:  /newbot"
    echo "  4. Choose a display name (e.g. \"Claude Assistant\")"
    echo "  5. Choose a username — must end in \"bot\" (e.g. \"my_claude_bot\")"
    echo "  6. BotFather will reply with a token that looks like:"
    echo ""
    echo -e "     ${BLUE}1234567890:ABCDefGhIJKlmNOPQrstUVwxyz${NC}"
    echo ""
    echo "  Copy that token now."
    echo ""

    # Prompt for token — empty input skips setup
    read -rsp "Paste your bot token here (press Enter to skip): " BOT_TOKEN
    echo ""

    # Trim whitespace
    BOT_TOKEN=$(echo "$BOT_TOKEN" | xargs)

    if [ -z "$BOT_TOKEN" ]; then
        echo ""
        info "Telegram setup skipped. You can add your token later by re-running Step 8."
        SKIP_TOKEN=true
    else
        # Validate token format: digits, colon, alphanumeric + dash/underscore
        if [[ "$BOT_TOKEN" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]]; then
            success "Token format looks valid"
        else
            warn "Token format doesn't look right. Expected: 1234567890:ABC-DEF..."
            warn "Should be digits, a colon, then letters/numbers/dashes."
            warn "Saving anyway — you can fix it later in $TOKEN_FILE"
        fi

        echo ""

        # Save token
        info "Saving bot token..."
        mkdir -p "$CONFIG_DIR"
        chmod 700 "$CONFIG_DIR"
        echo "TELEGRAM_BOT_TOKEN=$BOT_TOKEN" > "$TOKEN_FILE"
        chmod 600 "$TOKEN_FILE"
        success "Token saved to $TOKEN_FILE (permissions: 600)"
    fi
fi

# =============================================================================
# Access Policy Configuration
# =============================================================================
info "Configuring access policy..."

mkdir -p "$CONFIG_DIR"
chmod 700 "$CONFIG_DIR"

if [ -f "$ACCESS_FILE" ] && [ "$SKIP_TOKEN" = true ]; then
    success "Access policy already configured at $ACCESS_FILE"
else
    cat > "$ACCESS_FILE" << 'POLICY'
{
  "defaultPolicy": "ask",
  "allowedChats": []
}
POLICY
    chmod 600 "$ACCESS_FILE"
    success "Access policy written to $ACCESS_FILE"
    info "Default policy: \"ask\" — Claude will prompt before accepting new chats"
fi

echo ""

# =============================================================================
# Your Telegram Commands
# =============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Your Telegram Commands${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}ctg${NC}        Launch Claude with Telegram (from any directory)"
echo -e "  ${GREEN}cbraintg${NC}   Launch Claude with Telegram inside your 2ndBrain vault"
echo ""

# =============================================================================
# Self-Test
# =============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Running Self-Test${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

TEST_PASS=0
TEST_FAIL=0

# Test 1: Bot token file exists
if [ -f "$TOKEN_FILE" ]; then
    success "TEST: Bot token file exists"
    TEST_PASS=$((TEST_PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} TEST: Bot token file not found at $TOKEN_FILE"
    TEST_FAIL=$((TEST_FAIL + 1))
fi

# Test 2: Token format valid
if [ -f "$TOKEN_FILE" ]; then
    SAVED_TOKEN=$(grep 'TELEGRAM_BOT_TOKEN=' "$TOKEN_FILE" 2>/dev/null | cut -d= -f2)
    if [[ "$SAVED_TOKEN" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]]; then
        success "TEST: Token format is valid"
        TEST_PASS=$((TEST_PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} TEST: Token format invalid"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi
else
    echo -e "${RED}[FAIL]${NC} TEST: Cannot validate token (file missing)"
    TEST_FAIL=$((TEST_FAIL + 1))
fi

# Test 3: ctg command (script at ~/.local/bin/ctg, installed by Step 1)
if [ -x "$HOME/.local/bin/ctg" ]; then
    success "TEST: ctg command installed at ~/.local/bin/ctg"
    TEST_PASS=$((TEST_PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} TEST: ctg not found at ~/.local/bin/ctg — re-run Step 1"
    TEST_FAIL=$((TEST_FAIL + 1))
fi

# Test 4: cbraintg command exists and is executable
if [ -x "$HOME/.local/bin/cbraintg" ]; then
    success "TEST: cbraintg command installed at ~/.local/bin/cbraintg"
    TEST_PASS=$((TEST_PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} TEST: cbraintg not found or not executable"
    TEST_FAIL=$((TEST_FAIL + 1))
fi

echo ""
echo "  $TEST_PASS tests passed, $TEST_FAIL failed."

if [ "$TEST_FAIL" -gt 0 ]; then
    echo ""
    echo -e "  ${YELLOW}Some tests failed. Scroll up to see which tests failed — re-run the relevant step to fix.${NC}"
fi

# =============================================================================
# Complete
# =============================================================================
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Step 8 Complete — Telegram Configured${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Launch Claude with Telegram connected:"
echo ""
echo -e "     ${GREEN}ctg${NC}          — from any directory"
echo -e "     ${GREEN}cbraintg${NC}     — from your 2ndBrain vault"
echo ""
echo "  2. Inside Claude, tell it:"
echo ""
echo -e "     ${BLUE}\"pair my Telegram bot\"${NC}"
echo ""
echo "     Claude will walk you through connecting your first chat."
echo ""
echo -e "  ${YELLOW}Tip: Use ctg from any directory, or cbraintg to also${NC}"
echo -e "  ${YELLOW}open your 2ndBrain vault with Telegram connected.${NC}"
echo ""

# Breadcrumb for /doctor and re-run detection.
mkdir -p "$HOME/.cli-maxxing" 2>/dev/null || true
touch "$HOME/.cli-maxxing/step-8.done" 2>/dev/null || true
