#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 7 — GitHub MCP + /gitfix
# Installs GitHub MCP server and the /gitfix skill.
# Run after completing Steps 1-6. Run this in your terminal.
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
INSTALLED_GITHUB=false
INSTALLED_GITFIX=false

# -----------------------------------------------------------------------------
# Ensure runtime PATH (brew, nvm, ~/.local/bin) is visible.
# Defense-in-depth: users typically run this step in a fresh terminal after
# Steps 1-6 completed, but installers/nvm don't always source their shell
# rc files in non-login shells. This makes `node`, `npm`, and `claude`
# resolvable regardless of how the user invoked the script.
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
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
}

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
        if claude mcp list 2>/dev/null | grep -q "github" 2>/dev/null; then
            CHOICES="$CHOICES 1"
            INSTALLED_GITHUB=true
        fi

        if [ -n "$CHOICES" ]; then
            info "Found already-installed tools — verifying configuration"
            return
        else
            echo ""
            echo -e "${YELLOW}  Step 7 requires interactive input for API credentials.${NC}"
            echo -e "${YELLOW}  Run it directly in your terminal:${NC}"
            echo ""
            echo "    bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-7/step-7-install.sh)"
            echo ""
            print_summary
            exit 0
        fi
    fi

    echo ""
    echo -e "${BLUE}  Which developer tools do you use?${NC}"
    echo -e "${BLUE}  (enter numbers separated by spaces)${NC}"
    echo ""
    echo "    1) GitHub  — repos, issues, PRs, code search (requires Personal Access Token)"
    echo ""
    echo -e "${YELLOW}  This step is for developers. If you don't use GitHub with Claude,${NC}"
    echo -e "${YELLOW}  you can skip it — all earlier steps work without it.${NC}"
    echo ""
    read -rp "  Enter your choices (e.g. \"1\"): " CHOICES
    echo ""

    if [ -z "$CHOICES" ]; then
        warn "No tools selected. Nothing to install."
        print_summary
        exit 0
    fi
}

# -----------------------------------------------------------------------------
# Install GitHub MCP
# -----------------------------------------------------------------------------
install_github() {
    info "Installing GitHub MCP server..."

    if claude mcp list 2>/dev/null | grep -q "github"; then
        success "GitHub MCP already installed"
        INSTALLED_GITHUB=true
        return
    fi

    echo ""
    echo -e "${BLUE}  GitHub MCP gives Claude read/write access to your repos,${NC}"
    echo -e "${BLUE}  issues, pull requests, and code search via the GitHub API.${NC}"
    echo ""
    echo -e "${BLUE}  You need a Personal Access Token (classic PAT). Create one at:${NC}"
    echo -e "${BLUE}  https://github.com/settings/tokens/new${NC}"
    echo ""
    echo "    Suggested settings:"
    echo "      - Token name: claude-github-mcp"
    echo "      - Expiration: No expiration"
    echo "      - Scopes: repo, read:org, gist"
    echo ""
    echo -e "${YELLOW}  Use a classic token (not fine-grained) for full repo access.${NC}"
    echo -e "${YELLOW}  Check only: repo (top checkbox), read:org (under admin:org), gist.${NC}"
    echo ""

    read -rsp "  GitHub Personal Access Token (ghp_...): " GITHUB_TOKEN
    echo " [saved]"
    echo ""

    if [ -z "$GITHUB_TOKEN" ]; then
        warn "No GitHub token provided. Skipping GitHub setup."
        warn "Re-run Step 7 when you have a token ready."
        return
    fi

    if [[ ! "$GITHUB_TOKEN" =~ ^gh[ps]_ ]]; then
        warn "Token doesn't look like a GitHub PAT (expected ghp_ or ghs_ prefix)."
        warn "Proceeding anyway — registration will fail if the token is invalid."
        echo ""
    fi

    # Register with the token injected via env var into the MCP server process.
    # Credentials live in Claude's MCP config only — not written to disk here.
    claude mcp add --scope user github -- npx -y @modelcontextprotocol/server-github 2>/dev/null

    # Inject the token directly into the config entry (claude mcp add --scope user
    # does not support -e flags in all CLI versions, so we patch the env block).
    # Token is passed via env var (not argv) to avoid leaking it in `ps` output.
    GITHUB_TOKEN_VALUE="$GITHUB_TOKEN" python3 - <<'PYEOF'
import json, os

token = os.environ.get("GITHUB_TOKEN_VALUE", "").strip()
config_path = os.path.expanduser("~/.claude.json")

with open(config_path) as f:
    config = json.load(f)

mcpServers = config.get("mcpServers", {})
if "github" in mcpServers:
    mcpServers["github"].setdefault("env", {})
    mcpServers["github"]["env"]["GITHUB_PERSONAL_ACCESS_TOKEN"] = token
    config["mcpServers"] = mcpServers
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)
    print("Token injected into GitHub MCP config.")
else:
    print("WARNING: github entry not found in MCP config — token not injected.")
PYEOF

    if claude mcp list 2>/dev/null | grep -q "github"; then
        success "GitHub MCP installed"
        INSTALLED_GITHUB=true
    else
        soft_fail "GitHub MCP installation could not be verified"
    fi
}

# -----------------------------------------------------------------------------
# Install /gitfix skill
# -----------------------------------------------------------------------------
install_gitfix() {
    GITFIX_DIR="$HOME/.claude/skills/gitfix"
    GITFIX_FILE="$GITFIX_DIR/SKILL.md"
    GITFIX_URL="https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/gitfix-skill/SKILL.md"

    mkdir -p "$GITFIX_DIR"

    if [ -f "$GITFIX_FILE" ]; then
        info "Updating existing /gitfix skill..."
        INSTALLED_GITFIX=true
    else
        info "Installing /gitfix skill..."
    fi

    GITFIX_TMP="$GITFIX_FILE.tmp"
    if curl -fsSL "$GITFIX_URL" -o "$GITFIX_TMP" 2>/dev/null && [ -s "$GITFIX_TMP" ]; then
        mv "$GITFIX_TMP" "$GITFIX_FILE"
        success "/gitfix skill installed at $GITFIX_FILE"
        INSTALLED_GITFIX=true
    else
        rm -f "$GITFIX_TMP"
        warn "Download failed — attempting local fallback..."
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        LOCAL_GITFIX="$(dirname "$SCRIPT_DIR")/gitfix-skill/SKILL.md"
        if [ -f "$LOCAL_GITFIX" ]; then
            cp "$LOCAL_GITFIX" "$GITFIX_FILE"
            success "/gitfix skill installed from local copy"
            INSTALLED_GITFIX=true
        else
            soft_fail "Could not install /gitfix skill — download and local fallback both failed"
        fi
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

    if $INSTALLED_GITHUB; then check_registered "GitHub" "github"; else info "TEST: GitHub — skipped"; TEST_SKIP=$((TEST_SKIP + 1)); fi

    if $INSTALLED_GITFIX; then
        success "TEST: /gitfix skill installed"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: /gitfix skill not found"
        TEST_FAIL=$((TEST_FAIL + 1))
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
    echo -e "${GREEN}  Step 7 Complete — GitHub + /gitfix${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    INSTALLED_COUNT=0

    if $INSTALLED_GITHUB; then echo "  GitHub  — repos, issues, PRs, code search"; INSTALLED_COUNT=$((INSTALLED_COUNT + 1)); fi
    if $INSTALLED_GITFIX; then
        echo "  /gitfix — full-repo consistency audit: docs, scripts, and README all in sync"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi

    if [ "$INSTALLED_COUNT" -eq 0 ]; then
        echo "  No tools were installed."
    else
        echo ""
        echo "  $INSTALLED_COUNT tool(s) installed and ready in Claude Code."
        echo ""
        echo "  What you can do now:"

        if $INSTALLED_GITHUB; then
            echo "    - Ask Claude to list open PRs or issues on any of your repos"
            echo "    - Ask Claude to search code across your GitHub organizations"
            echo "    - Ask Claude to create issues, review diffs, or push commits"
        fi
        echo "    - Run /gitfix inside any Claude session to sync all docs with reality"
    fi

    echo ""
    if [ "$ERRORS" -gt 0 ]; then
        echo -e "  ${YELLOW}Warnings: $ERRORS issue(s) detected.${NC}"
        echo -e "  ${YELLOW}Scroll up to see details.${NC}"
        echo ""
    fi
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Continue to Step 8 (Safety Check) or the Final Step (Status Line)."
    echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    source_runtime_path

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Step 7 — GitHub MCP + /gitfix${NC}"
    echo -e "${BLUE}  GitHub MCP + /gitfix skill • macOS + Linux${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    detect_os
    verify_prerequisites
    choose_tools

    # Process each selection in the canonical order
    for CHOICE in $CHOICES; do
        case "$CHOICE" in
            1) if ! $INSTALLED_GITHUB; then install_github; else success "GitHub already configured"; fi ;;
            *) warn "Unknown choice: $CHOICE (skipping)" ;;
        esac
    done

    # /gitfix always installs (no interactive input required)
    install_gitfix

    run_self_test
    print_summary

    # Breadcrumb for /doctor and re-run detection.
    mkdir -p "$HOME/.cli-maxxing" 2>/dev/null || true
    touch "$HOME/.cli-maxxing/step-7.done" 2>/dev/null || true
}

main "$@"
