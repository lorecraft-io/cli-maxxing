#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 6 — Productivity Tools
# Installs Notion, Granola, n8n, Google Calendar, Morgen, and Motion Calendar
# MCP servers. Interactive — pick the tools you actually use.
# Obsidian MCP lives in Step 7 alongside the rest of the Obsidian vault setup.
# Run this in your terminal after completing Steps 1-5.
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
INSTALLED_NOTION=false
INSTALLED_GRANOLA=false
INSTALLED_N8N=false
INSTALLED_GCAL=false
INSTALLED_MORGEN=false
INSTALLED_MOTION=false
# Pre-existing installs (credentials managed outside this script).
# Only Motion tracks this because Motion persists credentials to a local .env
# the self-test checks for; Morgen/Notion/n8n credentials live inside Claude's
# MCP config, so there is nothing separate to verify.
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
        if claude mcp list 2>/dev/null | grep -q "notion" 2>/dev/null; then
            CHOICES="$CHOICES 1"
            INSTALLED_NOTION=true
        fi
        if claude mcp list 2>/dev/null | grep -q "granola" 2>/dev/null; then
            CHOICES="$CHOICES 2"
            INSTALLED_GRANOLA=true
        fi
        if claude mcp list 2>/dev/null | grep -q "n8n" 2>/dev/null; then
            CHOICES="$CHOICES 3"
            INSTALLED_N8N=true
        fi
        if claude mcp list 2>/dev/null | grep -q "google-calendar" 2>/dev/null; then
            CHOICES="$CHOICES 4"
            INSTALLED_GCAL=true
        fi
        if claude mcp list 2>/dev/null | grep -q "morgen" 2>/dev/null; then
            CHOICES="$CHOICES 5"
            INSTALLED_MORGEN=true
        fi
        if claude mcp list 2>/dev/null | grep -q "motion-calendar" 2>/dev/null; then
            CHOICES="$CHOICES 6"
            INSTALLED_MOTION=true
            MOTION_PREEXISTING=true
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
    echo "    1) Notion           — pages, databases, knowledge management"
    echo "    2) Granola          — meeting transcripts and notes"
    echo "    3) n8n              — your own n8n instance (workflow automation)"
    echo "    4) Google Calendar  — calendar events via Google OAuth"
    echo "    5) Morgen           — unified calendar + tasks (recommended)"
    echo "    6) Motion Calendar  — Motion events, availability, scheduling"
    echo ""
    echo -e "${YELLOW}  Note: Morgen (5) is the recommended calendar+task tool.${NC}"
    echo -e "${YELLOW}  Motion (6) and Google Calendar (4) are secondary —${NC}"
    echo -e "${YELLOW}  install them only if you specifically need those accounts.${NC}"
    echo ""
    echo -e "${BLUE}  Looking for Obsidian MCP? It ships with Step 7 (Second Brain),${NC}"
    echo -e "${BLUE}  alongside the Obsidian app install and vault setup.${NC}"
    echo ""
    read -rp "  Enter your choices (e.g. \"1 5\" or just \"5\"): " CHOICES
    echo ""

    if [ -z "$CHOICES" ]; then
        warn "No tools selected. Nothing to install."
        print_summary
        exit 0
    fi
}

# -----------------------------------------------------------------------------
# Install Notion MCP
# -----------------------------------------------------------------------------
install_notion() {
    info "Installing Notion MCP server..."

    if claude mcp list 2>/dev/null | grep -q "notion"; then
        success "Notion MCP already installed"
        INSTALLED_NOTION=true
        return
    fi

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

    # Register with the token as an environment variable.
    claude mcp add --scope user -e NOTION_TOKEN="$NOTION_TOKEN" notion -- npx -y @notionhq/notion-mcp-server 2>/dev/null

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

    # HTTP transport — Granola handles auth via the app
    claude mcp add --scope user --transport http granola https://mcp.granola.ai/mcp 2>/dev/null

    if claude mcp list 2>/dev/null | grep -q "granola"; then
        success "Granola MCP installed"
        INSTALLED_GRANOLA=true
    else
        soft_fail "Granola MCP installation could not be verified"
    fi
}

# -----------------------------------------------------------------------------
# Install n8n MCP (user's own n8n instance)
# -----------------------------------------------------------------------------
install_n8n() {
    info "Installing n8n MCP server..."

    if claude mcp list 2>/dev/null | grep -q "n8n"; then
        success "n8n MCP already installed"
        INSTALLED_N8N=true
        return
    fi

    echo ""
    echo -e "${BLUE}  n8n MCP connects Claude to YOUR OWN n8n instance (cloud or${NC}"
    echo -e "${BLUE}  self-hosted) so Claude can trigger and inspect your workflows.${NC}"
    echo ""
    echo -e "${YELLOW}  This requires you to create an \"MCP Server Trigger\" node${NC}"
    echo -e "${YELLOW}  inside your n8n instance first. Here's how:${NC}"
    echo ""
    echo "    1. Open your n8n instance in a browser (e.g. https://YOUR.app.n8n.cloud)"
    echo "    2. Create a new workflow"
    echo "    3. Add the \"MCP Server Trigger\" node (search \"MCP\")"
    echo "    4. Configure the trigger:"
    echo "       - Path: leave default or pick your own (e.g. /mcp-server/http)"
    echo "       - Authentication: None, Bearer Token, or Header Auth — your choice"
    echo "    5. Add whatever downstream nodes you want Claude to be able to call"
    echo "    6. Activate the workflow (toggle in top right)"
    echo "    7. Click the MCP Server Trigger node and copy the \"Production URL\""
    echo ""
    echo -e "${BLUE}  Docs: https://docs.n8n.io/advanced-ai/mcp/mcp-server-trigger/${NC}"
    echo ""

    read -rp "  Full MCP Server Trigger URL (e.g. https://YOU.app.n8n.cloud/mcp-server/http): " N8N_URL
    echo ""

    if [ -z "$N8N_URL" ]; then
        warn "No n8n URL provided. Skipping n8n setup."
        return
    fi

    # Basic sanity check — must start with http:// or https://
    if [[ ! "$N8N_URL" =~ ^https?:// ]]; then
        warn "URL must start with http:// or https:// — got: $N8N_URL"
        warn "Skipping n8n setup. Re-run Step 6 with a valid URL."
        return
    fi

    echo -e "${BLUE}  Optional: if you set Bearer Token auth on the MCP trigger,${NC}"
    echo -e "${BLUE}  paste the token here. Otherwise press Enter to skip.${NC}"
    echo ""
    read -sp "  Bearer token (optional): " N8N_TOKEN
    echo ""
    echo ""

    if [ -n "$N8N_TOKEN" ]; then
        claude mcp add --scope user --transport http \
            -H "Authorization: Bearer $N8N_TOKEN" \
            n8n "$N8N_URL" 2>/dev/null
    else
        claude mcp add --scope user --transport http n8n "$N8N_URL" 2>/dev/null
    fi

    if claude mcp list 2>/dev/null | grep -q "n8n"; then
        success "n8n MCP installed"
        INSTALLED_N8N=true
    else
        soft_fail "n8n MCP installation could not be verified"
    fi
}

# -----------------------------------------------------------------------------
# Install Google Calendar MCP
# -----------------------------------------------------------------------------
install_google_calendar() {
    info "Installing Google Calendar MCP server..."

    if claude mcp list 2>/dev/null | grep -q "google-calendar"; then
        success "Google Calendar MCP already installed"
        INSTALLED_GCAL=true
        return
    fi

    # If a primary calendar is already installed, warn that it takes priority
    if claude mcp list 2>/dev/null | grep -q "morgen\|motion-calendar"; then
        echo ""
        echo -e "${YELLOW}  You already have a primary calendar MCP installed${NC}"
        echo -e "${YELLOW}  (Morgen or Motion). Claude will use that by default.${NC}"
        echo -e "${YELLOW}  Only continue if you need direct access to a specific${NC}"
        echo -e "${YELLOW}  Google account that is NOT synced through your primary.${NC}"
        echo ""
        read -rp "  Continue anyway? (y/N): " GCAL_CONFIRM
        if [[ ! "$GCAL_CONFIRM" =~ ^[Yy]$ ]]; then
            info "Google Calendar install skipped."
            return
        fi
        echo ""
    fi
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

    # Write credentials file as a local backup reference.
    # IMPORTANT: Editing this file later does NOT take effect automatically.
    # To update credentials, re-run Step 6. The -e flags below are what
    # actually injects the credentials into the MCP server at runtime.
    mkdir -p "$HOME/.google-calendar-mcp"
    chmod 700 "$HOME/.google-calendar-mcp"
    {
      printf 'GOOGLE_CLIENT_ID=%s\n' "$GCAL_CLIENT_ID"
      printf 'GOOGLE_CLIENT_SECRET=%s\n' "$GCAL_CLIENT_SECRET"
    } > "$HOME/.google-calendar-mcp/.env"
    chmod 600 "$HOME/.google-calendar-mcp/.env"
    echo ""
    echo -e "  ${YELLOW}Note: editing ~/.google-calendar-mcp/.env later will not update credentials.${NC}"
    echo -e "  ${YELLOW}To change credentials, re-run Step 6.${NC}"

    # Register the MCP server with credentials via -e flags.
    claude mcp add --scope user \
        -e GOOGLE_CLIENT_ID="$GCAL_CLIENT_ID" \
        -e GOOGLE_CLIENT_SECRET="$GCAL_CLIENT_SECRET" \
        google-calendar -- npx -y google-calendar-mcp 2>/dev/null

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
# Install Morgen MCP (recommended calendar + tasks)
# -----------------------------------------------------------------------------
install_morgen() {
    info "Installing Morgen MCP server..."

    if claude mcp list 2>/dev/null | grep -q "morgen"; then
        success "Morgen MCP already installed"
        INSTALLED_MORGEN=true
        return
    fi

    echo ""
    echo -e "${BLUE}  Morgen unifies Google, Outlook, iCloud, and native tasks${NC}"
    echo -e "${BLUE}  into one auto-scheduling interface. Authentication is a${NC}"
    echo -e "${BLUE}  single API key — no OAuth, no refresh tokens.${NC}"
    echo ""
    echo "    1. Go to https://platform.morgen.so/developers-api"
    echo "    2. Sign in with your Morgen account"
    echo "    3. Generate an API key and copy it"
    echo ""
    echo -e "${BLUE}  Package: morgen-mcp (published by lorecraft-io)${NC}"
    echo -e "${BLUE}  Source:  https://github.com/lorecraft-io/morgen-mcp${NC}"
    echo ""

    read -sp "  Morgen API key: " MORGEN_API_KEY
    echo " [saved]"

    if [ -z "$MORGEN_API_KEY" ]; then
        warn "No Morgen API key provided. Skipping Morgen setup."
        return
    fi

    echo ""
    echo -e "${BLUE}  Optional: IANA timezone for event/task formatting.${NC}"
    echo -e "${BLUE}  Press Enter to default to America/New_York.${NC}"
    echo ""
    read -rp "  Morgen timezone [America/New_York]: " MORGEN_TIMEZONE
    MORGEN_TIMEZONE="${MORGEN_TIMEZONE:-America/New_York}"
    echo ""

    # Register via claude mcp add with -e flags. Credentials are not written
    # to disk by this script — they live in Claude's MCP config only.
    claude mcp add --scope user \
        -e MORGEN_API_KEY="$MORGEN_API_KEY" \
        -e MORGEN_TIMEZONE="$MORGEN_TIMEZONE" \
        morgen -- npx -y morgen-mcp 2>/dev/null

    if claude mcp list 2>/dev/null | grep -q "morgen"; then
        success "Morgen MCP installed (timezone: $MORGEN_TIMEZONE)"
        INSTALLED_MORGEN=true
    else
        soft_fail "Morgen MCP installation could not be verified"
    fi
}

# -----------------------------------------------------------------------------
# Install Motion Calendar MCP
# -----------------------------------------------------------------------------
install_motion_calendar() {
    info "Installing Motion Calendar MCP server..."

    if claude mcp list 2>/dev/null | grep -q "motion-calendar"; then
        success "Motion Calendar MCP already installed"
        INSTALLED_MOTION=true
        MOTION_PREEXISTING=true
        return
    fi

    echo ""
    echo -e "${YELLOW}  Heads up: Morgen (option 6) is the recommended default${NC}"
    echo -e "${YELLOW}  calendar tool. Motion Calendar is only needed for a few${NC}"
    echo -e "${YELLOW}  Motion-specific features (teammate events, full-text${NC}"
    echo -e "${YELLOW}  search across events, custom calendar management).${NC}"
    echo ""
    echo -e "${BLUE}  Package: motion-calendar-mcp (published by lorecraft-io)${NC}"
    echo -e "${BLUE}  Source:  https://github.com/lorecraft-io/motion-calendar-mcp${NC}"
    echo ""
    echo -e "${BLUE}  Motion Calendar requires a few API credentials from your${NC}"
    echo -e "${BLUE}  Motion account settings.${NC}"
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
    chmod 700 "$HOME/.motion-calendar-mcp"
    {
      printf 'MOTION_API_KEY=%s\n' "$MOTION_API_KEY"
      printf 'FIREBASE_API_KEY=%s\n' "$FIREBASE_API_KEY"
      printf 'FIREBASE_REFRESH_TOKEN=%s\n' "$FIREBASE_REFRESH_TOKEN"
      printf 'MOTION_USER_ID=%s\n' "$MOTION_USER_ID"
    } > "$HOME/.motion-calendar-mcp/.env"
    chmod 600 "$HOME/.motion-calendar-mcp/.env"

    # Register the MCP server (it reads credentials from ~/.motion-calendar-mcp/.env)
    claude mcp add --scope user motion-calendar -- npx -y motion-calendar-mcp 2>/dev/null

    if claude mcp list 2>/dev/null | grep -q "motion-calendar"; then
        success "Motion Calendar MCP installed"
        INSTALLED_MOTION=true
    else
        soft_fail "Motion Calendar MCP installation could not be verified"
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

    check_registered() {
        local label="$1"
        local needle="$2"
        if claude mcp list 2>/dev/null | grep -q "$needle"; then
            success "TEST: $label MCP registered"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: $label MCP not registered"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
    }

    if $INSTALLED_NOTION;   then check_registered "Notion"          "notion";          else info "TEST: Notion — skipped";          TEST_SKIP=$((TEST_SKIP + 1)); fi
    if $INSTALLED_GRANOLA;  then check_registered "Granola"         "granola";         else info "TEST: Granola — skipped";         TEST_SKIP=$((TEST_SKIP + 1)); fi
    if $INSTALLED_N8N;      then check_registered "n8n"             "n8n";             else info "TEST: n8n — skipped";             TEST_SKIP=$((TEST_SKIP + 1)); fi
    if $INSTALLED_GCAL;     then check_registered "Google Calendar" "google-calendar"; else info "TEST: Google Calendar — skipped"; TEST_SKIP=$((TEST_SKIP + 1)); fi
    if $INSTALLED_MORGEN;   then check_registered "Morgen"          "morgen";          else info "TEST: Morgen — skipped";          TEST_SKIP=$((TEST_SKIP + 1)); fi
    if $INSTALLED_MOTION;   then check_registered "Motion Calendar" "motion-calendar"; else info "TEST: Motion Calendar — skipped"; TEST_SKIP=$((TEST_SKIP + 1)); fi

    # Credential-file checks for tools that persist a local .env
    if $INSTALLED_GCAL; then
        if [ -f "$HOME/.google-calendar-mcp/.env" ]; then
            success "TEST: Google Calendar credentials file exists"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: Google Calendar credentials file not found"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
    fi
    if $INSTALLED_MOTION; then
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

    INSTALLED_COUNT=0

    if $INSTALLED_NOTION;   then echo "  Notion            — search pages, read databases, create content";   INSTALLED_COUNT=$((INSTALLED_COUNT + 1)); fi
    if $INSTALLED_GRANOLA;  then echo "  Granola           — meeting transcripts and notes";                   INSTALLED_COUNT=$((INSTALLED_COUNT + 1)); fi
    if $INSTALLED_N8N;      then echo "  n8n               — trigger and inspect your own n8n workflows";      INSTALLED_COUNT=$((INSTALLED_COUNT + 1)); fi
    if $INSTALLED_GCAL;     then echo "  Google Calendar   — calendar events via Google OAuth";                INSTALLED_COUNT=$((INSTALLED_COUNT + 1)); fi
    if $INSTALLED_MORGEN;   then echo "  Morgen            — unified calendar + tasks (single API key)";       INSTALLED_COUNT=$((INSTALLED_COUNT + 1)); fi
    if $INSTALLED_MOTION;   then echo "  Motion Calendar   — Motion events, availability, scheduling";         INSTALLED_COUNT=$((INSTALLED_COUNT + 1)); fi

    if [ "$INSTALLED_COUNT" -eq 0 ]; then
        echo "  No tools were installed."
    else
        echo ""
        echo "  $INSTALLED_COUNT tool(s) installed and ready in Claude Code."
        echo ""
        echo "  What you can do now:"

        if $INSTALLED_NOTION; then
            echo "    - Ask Claude to search or create Notion pages"
            echo "    - Ask Claude to query a Notion database"
        fi
        if $INSTALLED_GRANOLA; then
            echo "    - Ask Claude \"what were the key points from my last meeting?\""
        fi
        if $INSTALLED_N8N; then
            echo "    - Ask Claude to list or trigger your n8n workflows"
        fi
        if $INSTALLED_GCAL; then
            echo "    - Ask Claude \"what's on my Google Calendar this week?\""
        fi
        if $INSTALLED_MORGEN; then
            echo "    - Ask Claude \"what's on my calendar this week?\""
            echo "    - Ask Claude \"add a task called 'Review contracts' due Friday\""
            echo "    - Ask Claude \"reflow my day starting at 9am\""
        fi
        if $INSTALLED_MOTION; then
            echo "    - Ask Claude \"who on my team has a conflict at 3pm?\""
            echo "    - Ask Claude to search events across all your Motion calendars"
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
    echo -e "${BLUE}  Notes, calendars, meetings, workflows — pick what you use • macOS + Linux${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    detect_os
    verify_prerequisites
    choose_tools

    # Process each selection in the canonical order
    for CHOICE in $CHOICES; do
        case "$CHOICE" in
            1) if ! $INSTALLED_NOTION;  then install_notion;          else success "Notion already configured";          fi ;;
            2) if ! $INSTALLED_GRANOLA; then install_granola;         else success "Granola already configured";         fi ;;
            3) if ! $INSTALLED_N8N;     then install_n8n;             else success "n8n already configured";             fi ;;
            4) if ! $INSTALLED_GCAL;    then install_google_calendar; else success "Google Calendar already configured"; fi ;;
            5) if ! $INSTALLED_MORGEN;  then install_morgen;          else success "Morgen already configured";          fi ;;
            6) if ! $INSTALLED_MOTION;  then install_motion_calendar; else success "Motion Calendar already configured"; fi ;;
            *) warn "Unknown choice: $CHOICE (skipping)" ;;
        esac
    done

    run_self_test
    print_summary
}

main "$@"
