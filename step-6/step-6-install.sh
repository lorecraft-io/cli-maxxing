#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 6 — Productivity Tools
# Installs Motion Calendar, Notion, Granola, and Google Calendar MCP servers
# Interactive — pick the tools you actually use
# Run this in your terminal after completing Steps 1-5
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

# Track what was installed this run
INSTALLED_MOTION=false
INSTALLED_NOTION=false
INSTALLED_GRANOLA=false
INSTALLED_GCAL=false
# Track pre-existing installs (credentials managed outside ~/.motion-calendar-mcp/.env)
MOTION_PREEXISTING=false

# -----------------------------------------------------------------------------
# Detect OS
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin)       OS="mac" ;;
        Linux)        OS="linux" ;;
        MINGW*|MSYS*|CYGWIN*) fail "Windows is not supported. This script is for macOS and Linux only." ;;
        *)            fail "Unsupported OS: $(uname -s). This script supports macOS and Linux only." ;;
    esac
    info "Detected OS: $OS"
}

# -----------------------------------------------------------------------------
# Verify prerequisites
# -----------------------------------------------------------------------------
verify_prerequisites() {
    if ! command -v node &>/dev/null; then
        fail "Node.js not found. Run Step 1 first."
    fi
    if ! command -v claude &>/dev/null; then
        fail "Claude Code not found. Run Step 1 first."
    fi
    success "Prerequisites verified"
}

# -----------------------------------------------------------------------------
# Interactive menu — let the user pick which tools to install
# -----------------------------------------------------------------------------
choose_tools() {
    # Detect non-interactive mode (stdin is a pipe, not a terminal)
    if [ ! -t 0 ]; then
        info "Non-interactive mode detected (running via curl pipe)"
        CHOICES=""

        # Auto-detect already-installed tools
        if claude mcp list 2>/dev/null | grep -q "motion-calendar" 2>/dev/null; then
            CHOICES="1"
            INSTALLED_MOTION=true
            MOTION_PREEXISTING=true
        fi
        if claude mcp list 2>/dev/null | grep -q "notion" 2>/dev/null; then
            CHOICES="$CHOICES 2"
            INSTALLED_NOTION=true
        fi
        if claude mcp list 2>/dev/null | grep -q "granola" 2>/dev/null; then
            CHOICES="$CHOICES 3"
            INSTALLED_GRANOLA=true
        fi
        if claude mcp list 2>/dev/null | grep -q "google-calendar" 2>/dev/null; then
            CHOICES="$CHOICES 4"
            INSTALLED_GCAL=true
        fi

        if [ -n "$CHOICES" ]; then
            info "Found already-installed tools — verifying configuration"
            return
        else
            echo ""
            echo -e "${YELLOW}  Step 6 requires interactive input for API credentials.${NC}"
            echo -e "${YELLOW}  Run it directly in your terminal:${NC}"
            echo ""
            echo "    bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-6/step-6-install.sh)"
            echo ""
            print_summary
            exit 0
        fi
    fi

    echo ""
    echo -e "${BLUE}  Which productivity tools do you use?${NC}"
    echo -e "${BLUE}  (enter numbers separated by spaces)${NC}"
    echo ""
    echo "    1) Motion Calendar  — calendar events, availability, scheduling"
    echo "    2) Notion           — pages, databases, knowledge management"
    echo "    3) Granola          — meeting transcripts and notes"
    echo "    4) Google Calendar  — calendar events via Google OAuth"
    echo ""
    read -rp "  Enter your choices (e.g. \"1 2\" for both, or \"3\" for just Granola): " CHOICES
    echo ""

    if [ -z "$CHOICES" ]; then
        warn "No tools selected. Nothing to install."
        print_summary
        exit 0
    fi
}

# -----------------------------------------------------------------------------
# Install Motion Calendar MCP
# -----------------------------------------------------------------------------
install_motion_calendar() {
    info "Installing Motion Calendar MCP server..."

    # Check if already registered
    if claude mcp list 2>/dev/null | grep -q "motion-calendar"; then
        success "Motion Calendar MCP already installed"
        INSTALLED_MOTION=true
        return
    fi

    # Register the MCP server
    claude mcp add --scope user motion-calendar -- npx -y motion-calendar-mcp 2>/dev/null

    # Collect credentials
    echo ""
    echo -e "${BLUE}  Motion Calendar requires a few API credentials.${NC}"
    echo -e "${BLUE}  You can find these in your Motion account settings.${NC}"
    echo ""

    read -sp "  Motion API key: " MOTION_API_KEY
    echo " [saved]"
    read -sp "  Firebase API key: " FIREBASE_API_KEY
    echo " [saved]"
    read -sp "  Firebase refresh token: " FIREBASE_REFRESH_TOKEN
    echo " [saved]"
    read -sp "  Motion user ID: " MOTION_USER_ID
    echo " [saved]"

    if [ -z "$MOTION_API_KEY" ] || [ -z "$FIREBASE_API_KEY" ] || [ -z "$FIREBASE_REFRESH_TOKEN" ] || [ -z "$MOTION_USER_ID" ]; then
        warn "One or more Motion credentials were left blank."
        warn "You can fill them in later at ~/.motion-calendar-mcp/.env"
    fi

    # Write config
    mkdir -p "$HOME/.motion-calendar-mcp"
    {
      printf 'MOTION_API_KEY=%s\n' "$MOTION_API_KEY"
      printf 'FIREBASE_API_KEY=%s\n' "$FIREBASE_API_KEY"
      printf 'FIREBASE_REFRESH_TOKEN=%s\n' "$FIREBASE_REFRESH_TOKEN"
      printf 'MOTION_USER_ID=%s\n' "$MOTION_USER_ID"
    } > "$HOME/.motion-calendar-mcp/.env"

    chmod 600 "$HOME/.motion-calendar-mcp/.env"

    # Verify
    if claude mcp list 2>/dev/null | grep -q "motion-calendar"; then
        success "Motion Calendar MCP installed"
        INSTALLED_MOTION=true
    else
        soft_fail "Motion Calendar MCP installation could not be verified"
    fi
}

# -----------------------------------------------------------------------------
# Install Notion MCP
# -----------------------------------------------------------------------------
install_notion() {
    info "Installing Notion MCP server..."

    # Check if already registered
    if claude mcp list 2>/dev/null | grep -q "notion"; then
        success "Notion MCP already installed"
        INSTALLED_NOTION=true
        return
    fi

    # Collect token
    echo ""
    echo -e "${BLUE}  Notion requires an integration token. Here's how to get one:${NC}"
    echo ""
    echo "    1. Go to https://www.notion.so/profile/integrations"
    echo "    2. Click \"New integration\""
    echo "    3. Give it a name (e.g. \"Claude Code\")"
    echo "    4. Select your workspace"
    echo "    5. Click \"Submit\" and copy the Internal Integration Secret"
    echo "       (starts with ntn_ or secret_)"
    echo ""
    echo -e "${YELLOW}  IMPORTANT: After setup, you also need to share pages with${NC}"
    echo -e "${YELLOW}  the integration. On any Notion page you want Claude to${NC}"
    echo -e "${YELLOW}  access, click the ••• menu > Connections > add your${NC}"
    echo -e "${YELLOW}  integration. Claude can only see pages you explicitly share.${NC}"
    echo ""

    read -sp "  Notion integration token: " NOTION_TOKEN
    echo ""
    echo ""

    if [ -z "$NOTION_TOKEN" ]; then
        warn "No Notion token provided. You can re-run this step later."
        return
    fi

    # Register with the token as an environment variable
    claude mcp add --scope user -e NOTION_TOKEN="$NOTION_TOKEN" notion -- npx -y @notionhq/notion-mcp-server 2>/dev/null

    # Verify
    if claude mcp list 2>/dev/null | grep -q "notion"; then
        success "Notion MCP installed"
        INSTALLED_NOTION=true
        echo ""
        echo -e "${GREEN}  Don't forget: share your Notion pages with the integration!${NC}"
        echo -e "${GREEN}  On each page: ••• menu > Connections > add your integration.${NC}"
        echo ""
    else
        soft_fail "Notion MCP installation could not be verified"
    fi
}

# -----------------------------------------------------------------------------
# Install Granola MCP
# -----------------------------------------------------------------------------
install_granola() {
    info "Installing Granola MCP server..."

    # Check if already registered
    if claude mcp list 2>/dev/null | grep -q "granola"; then
        success "Granola MCP already installed"
        INSTALLED_GRANOLA=true
        return
    fi

    echo ""
    echo -e "${BLUE}  Granola is a meeting notes app. This MCP gives Claude${NC}"
    echo -e "${BLUE}  access to your meeting transcripts and notes.${NC}"
    echo ""
    echo -e "${YELLOW}  Requires: Granola app installed and signed in on this Mac.${NC}"
    echo -e "${YELLOW}  Get it at: https://granola.ai${NC}"
    echo ""

    # Register the MCP server (HTTP transport — Granola handles auth via the app)
    claude mcp add --scope user --transport http granola https://mcp.granola.ai/mcp 2>/dev/null

    # Verify
    if claude mcp list 2>/dev/null | grep -q "granola"; then
        success "Granola MCP installed"
        INSTALLED_GRANOLA=true
    else
        soft_fail "Granola MCP installation could not be verified"
    fi
}

# -----------------------------------------------------------------------------
# Install Google Calendar MCP
# -----------------------------------------------------------------------------
install_google_calendar() {
    info "Installing Google Calendar MCP server..."

    # Check if already registered
    if claude mcp list 2>/dev/null | grep -q "google-calendar"; then
        success "Google Calendar MCP already installed"
        INSTALLED_GCAL=true
        return
    fi

    echo ""
    echo -e "${YELLOW}  ⚠️  IMPORTANT — Motion Calendar is your primary calendar.${NC}"
    echo -e "${YELLOW}  Claude will ALWAYS use Motion for calendar reads and changes.${NC}"
    echo -e "${YELLOW}  Only install Google Calendar if you need direct access to events${NC}"
    echo -e "${YELLOW}  that are NOT synced to Motion (e.g. a secondary Google account).${NC}"
    echo ""
    read -rp "  Continue with Google Calendar install? (y/N): " GCAL_CONFIRM
    if [[ ! "$GCAL_CONFIRM" =~ ^[Yy]$ ]]; then
        info "Google Calendar install skipped."
        return
    fi
    echo ""
    echo -e "${BLUE}  Google Calendar MCP requires OAuth credentials from Google Cloud.${NC}"
    echo ""
    echo "    1. Go to https://console.cloud.google.com"
    echo "    2. Create a project (or select an existing one)"
    echo "    3. Enable the Google Calendar API"
    echo "       (APIs & Services > Library > search \"Google Calendar API\" > Enable)"
    echo "    4. Go to APIs & Services > Credentials > Create Credentials > OAuth 2.0 Client ID"
    echo "    5. Choose \"Desktop app\", name it \"Claude Code\""
    echo "    6. Copy your Client ID and Client Secret"
    echo ""
    echo -e "${YELLOW}  Also add your Google account email as a test user:${NC}"
    echo -e "${YELLOW}  APIs & Services > OAuth consent screen > Test users > Add users${NC}"
    echo ""

    read -sp "  Google OAuth Client ID: " GCAL_CLIENT_ID
    echo " [saved]"
    read -sp "  Google OAuth Client Secret: " GCAL_CLIENT_SECRET
    echo " [saved]"
    echo ""

    if [ -z "$GCAL_CLIENT_ID" ] || [ -z "$GCAL_CLIENT_SECRET" ]; then
        warn "Credentials left blank. Skipping Google Calendar setup."
        warn "Re-run Step 6 when you have your credentials ready."
        return
    fi

    # Write credentials file
    mkdir -p "$HOME/.google-calendar-mcp"
    {
      printf 'GOOGLE_CLIENT_ID=%s\n' "$GCAL_CLIENT_ID"
      printf 'GOOGLE_CLIENT_SECRET=%s\n' "$GCAL_CLIENT_SECRET"
    } > "$HOME/.google-calendar-mcp/.env"
    chmod 600 "$HOME/.google-calendar-mcp/.env"

    # Register the MCP server
    claude mcp add --scope user \
        -e GOOGLE_CLIENT_ID="$GCAL_CLIENT_ID" \
        -e GOOGLE_CLIENT_SECRET="$GCAL_CLIENT_SECRET" \
        google-calendar -- npx -y google-calendar-mcp 2>/dev/null

    # Verify
    if claude mcp list 2>/dev/null | grep -q "google-calendar"; then
        success "Google Calendar MCP installed"
        INSTALLED_GCAL=true
        echo ""
        echo -e "${BLUE}  Final step — authorize Claude to access your calendar:${NC}"
        echo ""
        echo -e "    ${GREEN}npx google-calendar-mcp auth${NC}"
        echo ""
        echo "  A browser window will open. Sign in with your Google account"
        echo "  and allow access. The token is stored locally."
        echo ""
    else
        soft_fail "Google Calendar MCP installation could not be verified"
    fi
}

# -----------------------------------------------------------------------------
# Self-test — check each installed tool is registered
# -----------------------------------------------------------------------------
run_self_test() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Running Self-Test${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    TEST_PASS=0
    TEST_FAIL=0
    TEST_SKIP=0

    # Motion Calendar
    if $INSTALLED_MOTION; then
        if claude mcp list 2>/dev/null | grep -q "motion-calendar"; then
            success "TEST: Motion Calendar MCP registered"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: Motion Calendar MCP not registered"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi

        if [ -f "$HOME/.motion-calendar-mcp/.env" ]; then
            success "TEST: Motion Calendar config exists"
            TEST_PASS=$((TEST_PASS + 1))
        elif $MOTION_PREEXISTING; then
            success "TEST: Motion Calendar credentials managed externally (pre-existing install)"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: Motion Calendar config not found"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
    else
        info "TEST: Motion Calendar — skipped (not selected)"
        TEST_SKIP=$((TEST_SKIP + 1))
    fi

    # Notion
    if $INSTALLED_NOTION; then
        if claude mcp list 2>/dev/null | grep -q "notion"; then
            success "TEST: Notion MCP registered"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: Notion MCP not registered"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
    else
        info "TEST: Notion — skipped (not selected)"
        TEST_SKIP=$((TEST_SKIP + 1))
    fi

    # Granola
    if $INSTALLED_GRANOLA; then
        if claude mcp list 2>/dev/null | grep -q "granola"; then
            success "TEST: Granola MCP registered"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: Granola MCP not registered"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
    else
        info "TEST: Granola — skipped (not selected)"
        TEST_SKIP=$((TEST_SKIP + 1))
    fi

    # Google Calendar
    if $INSTALLED_GCAL; then
        if claude mcp list 2>/dev/null | grep -q "google-calendar"; then
            success "TEST: Google Calendar MCP registered"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: Google Calendar MCP not registered"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
        if [ -f "$HOME/.google-calendar-mcp/.env" ]; then
            success "TEST: Google Calendar credentials file exists"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: Google Calendar credentials file not found"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
    else
        info "TEST: Google Calendar — skipped (not selected)"
        TEST_SKIP=$((TEST_SKIP + 1))
    fi

    echo ""
    if [ "$TEST_FAIL" -eq 0 ]; then
        echo -e "  ${GREEN}All $TEST_PASS tests passed.${NC} ($TEST_SKIP skipped)"
    else
        echo -e "  ${GREEN}$TEST_PASS passed${NC}, ${RED}$TEST_FAIL failed${NC}, $TEST_SKIP skipped."
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
    echo -e "${GREEN}  Step 6 Complete — Productivity Tools${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # List what was installed
    INSTALLED_COUNT=0

    if $INSTALLED_MOTION; then
        echo "  Motion Calendar   — view events, check availability, schedule meetings"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi

    if $INSTALLED_NOTION; then
        echo "  Notion            — search pages, read databases, create content"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi

    if $INSTALLED_GRANOLA; then
        echo "  Granola           — meeting transcripts and notes"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi

    if $INSTALLED_GCAL; then
        echo "  Google Calendar   — calendar events via Google OAuth"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi

    if [ "$INSTALLED_COUNT" -eq 0 ]; then
        echo "  No tools were installed."
    else
        echo ""
        echo "  $INSTALLED_COUNT tool(s) installed and ready in Claude Code."
        echo ""
        echo "  What you can do now:"

        if $INSTALLED_MOTION; then
            echo "    - Ask Claude \"what's on my calendar today?\""
            echo "    - Ask Claude \"when am I free this week?\""
        fi

        if $INSTALLED_NOTION; then
            echo "    - Ask Claude to search or create Notion pages"
            echo "    - Ask Claude to query a Notion database"
        fi

        if $INSTALLED_GRANOLA; then
            echo "    - Ask Claude \"what were the key points from my last meeting?\""
            echo "    - Ask Claude to search your meeting notes"
        fi

        if $INSTALLED_GCAL; then
            echo "    - Ask Claude \"what's on my Google Calendar this week?\""
            echo "    - Ask Claude to create or find calendar events"
        fi

    fi

    echo ""
    if [ "$ERRORS" -gt 0 ]; then
        echo -e "  ${YELLOW}Warnings: $ERRORS issue(s) detected.${NC}"
        echo -e "  ${YELLOW}Scroll up to see details.${NC}"
        echo ""
    fi
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Check the README for more steps as they're added."
    echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Step 6 — Productivity Tools${NC}"
    echo -e "${BLUE}  Calendar, notes, and meetings — pick what you use • macOS + Linux${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    detect_os
    verify_prerequisites
    choose_tools

    # Process each selection
    for CHOICE in $CHOICES; do
        case "$CHOICE" in
            1) if ! $INSTALLED_MOTION; then install_motion_calendar; else success "Motion Calendar already configured"; fi ;;
            2) if ! $INSTALLED_NOTION; then install_notion; else success "Notion already configured"; fi ;;
            3) if ! $INSTALLED_GRANOLA; then install_granola; else success "Granola already configured"; fi ;;
            4) if ! $INSTALLED_GCAL; then install_google_calendar; else success "Google Calendar already configured"; fi ;;
            *) warn "Unknown choice: $CHOICE (skipping)" ;;
        esac
    done

    run_self_test
    print_summary
}

main "$@"
