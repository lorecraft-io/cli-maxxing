#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 9 — Safety Check — Security Auditing
# Installs the /safetycheck Claude Code skill for running security audits
# Run after Step 1 — requires Claude Code installed
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
# 1. Detect OS
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin)       OS="mac" ;;
        Linux)        OS="linux" ;;
        MINGW*|MSYS*|CYGWIN*) fail "Windows is not supported. This script is for macOS and Linux only." ;;
        *)            fail "Unsupported OS: $(uname -s). This script supports macOS and Linux only." ;;
    esac
    info "Detected OS: $OS"

    case "${SHELL:-/bin/bash}" in
        */zsh)  USER_SHELL="zsh";  SHELL_RC="$HOME/.zshrc" ;;
        */bash) USER_SHELL="bash"; SHELL_RC="$HOME/.bashrc" ;;
        *)      USER_SHELL="bash"; SHELL_RC="$HOME/.bashrc" ;;
    esac
    info "Detected shell: $USER_SHELL ($SHELL_RC)"
}

# -----------------------------------------------------------------------------
# 2. Verify prerequisites
# -----------------------------------------------------------------------------
verify_prerequisites() {
    info "Checking prerequisites..."
    echo ""

    PREREQ_PASS=true

    # Check Node.js
    if command -v node &>/dev/null; then
        NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)
        if [ "$NODE_MAJOR" -ge 18 ]; then
            success "Node.js $(node -v) installed"
        else
            warn "Node.js $(node -v) found but too old — need v18+"
            PREREQ_PASS=false
        fi
    else
        warn "Node.js not found — run Step 1 first"
        PREREQ_PASS=false
    fi

    # Check Claude Code
    if command -v claude &>/dev/null; then
        success "Claude Code is installed"
    else
        warn "Claude Code not found — run Step 1 first"
        PREREQ_PASS=false
    fi

    # Check curl (needed for download)
    if command -v curl &>/dev/null; then
        success "curl is available"
    else
        fail "curl is required but not found. Install curl and try again."
    fi

    echo ""

    if [ "$PREREQ_PASS" = false ]; then
        warn "Some prerequisites are missing. The skill can still be installed,"
        warn "but you will need Step 1 completed to use it."
        echo ""
    fi
}

# -----------------------------------------------------------------------------
# 3. Install the /safetycheck skill
# -----------------------------------------------------------------------------
install_skill() {
    SKILL_DIR="$HOME/.claude/skills/safetycheck"
    SKILL_FILE="$SKILL_DIR/SKILL.md"
    # Pinned to a specific commit SHA — prevents rug-pull via mutable branch ref
    # To update: change the SHA to the new commit and update SKILL_SHA256 to match
    SKILL_COMMIT="7b449b652d946a8eef9aca65f0c8e182b4fb80f7"
    SKILL_URL="https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/${SKILL_COMMIT}/step-9/safetycheck-skill/SKILL.md"
    SKILL_SHA256="77e1ef1127fa35cd860925a652b96dd062ab080d438787b3bde348176597ab12"

    info "Creating skill directory..."
    mkdir -p "$SKILL_DIR"
    success "Created $SKILL_DIR"

    # Check for existing skill file
    if [ -f "$SKILL_FILE" ]; then
        if [ ! -t 0 ]; then
            # Non-interactive (curl | bash) — overwrite silently
            info "Updating existing /safetycheck skill..."
        else
            echo ""
            echo -e "${YELLOW}Existing /safetycheck skill found at $SKILL_FILE${NC}"
            read -p "Overwrite with latest version? (Y/n): " OVERWRITE
            if [[ "$OVERWRITE" =~ ^[Nn]$ ]]; then
                info "Keeping existing skill file."
                return
            fi
        fi
    fi

    info "Downloading /safetycheck skill..."
    if curl -fsSL "$SKILL_URL" -o "$SKILL_FILE" 2>/dev/null; then
        success "Skill downloaded to $SKILL_FILE"
    else
        warn "Download failed — attempting fallback install..."
        # Fallback: if the download fails (e.g., repo not yet public),
        # check if the script was run from the CLI-MAXXING repo itself
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        LOCAL_SKILL="$SCRIPT_DIR/safetycheck-skill/SKILL.md"

        if [ -f "$LOCAL_SKILL" ]; then
            cp "$LOCAL_SKILL" "$SKILL_FILE"
            success "Skill installed from local copy"
        else
            soft_fail "Could not download or find the skill file"
            return
        fi
    fi

    # Verify the file is non-empty
    if [ ! -s "$SKILL_FILE" ]; then
        soft_fail "Skill file downloaded but is empty — try again later"
        rm -f "$SKILL_FILE"
        return
    fi

    # Verify SHA-256 integrity — protects against corrupted download or tampered content
    if command -v shasum &>/dev/null; then
        ACTUAL_SHA=$(shasum -a 256 "$SKILL_FILE" | cut -d' ' -f1)
        if [ "$ACTUAL_SHA" = "$SKILL_SHA256" ]; then
            success "Skill file integrity verified (sha256 match)"
        else
            soft_fail "Skill file sha256 mismatch — file may be corrupt or tampered. Expected: ${SKILL_SHA256:0:16}..."
        fi
    elif command -v sha256sum &>/dev/null; then
        ACTUAL_SHA=$(sha256sum "$SKILL_FILE" | cut -d' ' -f1)
        if [ "$ACTUAL_SHA" = "$SKILL_SHA256" ]; then
            success "Skill file integrity verified (sha256 match)"
        else
            soft_fail "Skill file sha256 mismatch — file may be corrupt or tampered. Expected: ${SKILL_SHA256:0:16}..."
        fi
    fi

    # Verify the file contains expected content
    if grep -q "safetycheck" "$SKILL_FILE" 2>/dev/null; then
        success "Skill file content verified"
    else
        soft_fail "Skill file does not contain expected content — may be corrupt"
    fi

    echo ""
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
    SKILL_FILE="$HOME/.claude/skills/safetycheck/SKILL.md"

    # Test 1: Skill directory exists
    if [ -d "$HOME/.claude/skills/safetycheck" ]; then
        success "TEST: Skill directory exists at ~/.claude/skills/safetycheck/"
        TEST_PASS=$((TEST_PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} TEST: Skill directory not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Test 2: Skill file exists
    if [ -f "$SKILL_FILE" ]; then
        success "TEST: SKILL.md exists at $SKILL_FILE"
        TEST_PASS=$((TEST_PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} TEST: SKILL.md not found at $SKILL_FILE"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Test 3: Skill file is non-empty
    if [ -s "$SKILL_FILE" ]; then
        SKILL_SIZE=$(wc -c < "$SKILL_FILE" | xargs)
        success "TEST: SKILL.md is non-empty ($SKILL_SIZE bytes)"
        TEST_PASS=$((TEST_PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} TEST: SKILL.md is empty"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Test 4: Skill file contains expected content
    if grep -q "safetycheck" "$SKILL_FILE" 2>/dev/null; then
        success "TEST: SKILL.md contains safetycheck references"
        TEST_PASS=$((TEST_PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} TEST: SKILL.md does not contain expected content"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Test 5: Skill file contains all 20 checks
    CHECK_COUNT=$(grep -c "^#\{2,4\} Check [0-9][0-9]*" "$SKILL_FILE" 2>/dev/null || echo "0")
    if [ "$CHECK_COUNT" -ge 20 ]; then
        success "TEST: SKILL.md defines all 20 security checks"
        TEST_PASS=$((TEST_PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} TEST: SKILL.md only has $CHECK_COUNT/20 checks"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Test 6: Claude Code is installed
    if command -v claude &>/dev/null; then
        success "TEST: Claude Code is available"
        TEST_PASS=$((TEST_PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} TEST: Claude Code not found — install via Step 1"
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
    echo -e "${GREEN}  Step 9 Complete — /safetycheck Installed (20 checks)${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Installed:"
    echo "    Skill file     ~/.claude/skills/safetycheck/SKILL.md"
    echo ""
    echo "  How to use:"
    echo ""
    echo -e "    Type ${GREEN}/safetycheck${NC} in Claude Code to run a security audit"
    echo ""
    echo "  What it checks:"
    echo ""
    echo "    API Security (checks 1-8):"
    echo "    1. Exposed API Keys        — hardcoded secrets, git history, MCP config"
    echo "    2. Rate Limiting            — endpoint protection middleware"
    echo "    3. Input Sanitization       — eval, innerHTML, SQL injection, tool handlers"
    echo "    4. RLS / Database Security  — parameterized queries, RLS policies"
    echo "    5. Dependency Vulns         — npm audit, MCP SDK CVEs, lockfile hygiene"
    echo "    6. Gitignore Hygiene        — .env, *.pem, MCP config files"
    echo "    7. CI/CD & GitHub Security  — workflows, dependabot, SECURITY.md"
    echo "    8. Error Handling           — raw error exposure, tool response leakage"
    echo ""
    echo "    MCP Security (checks 9-20, activated when MCP project detected):"
    echo "    9.  Tool Description Integrity — injection markers, file paths, cross-tool refs"
    echo "    10. Unicode Smuggling          — invisible chars, zero-width, tag characters"
    echo "    11. Encoded Payloads           — Base64/hex in tool metadata"
    echo "    12. MCP Transport Security     — HTTP vs HTTPS, DNS rebinding CVEs"
    echo "    13. MCP Authentication         — bearer auth on HTTP MCP endpoints"
    echo "    14. Token Scope & Lifecycle    — over-broad scopes, plaintext tokens"
    echo "    15. Input Schema Validation    — tool schemas, additionalProperties"
    echo "    16. Tool Response Sanitization — stack traces in tool results"
    echo "    17. CORS / Origin Validation   — wildcard CORS on MCP endpoints"
    echo "    18. Supply Chain & Config      — @latest pins, lockfile, .mcp.json hygiene"
    echo "    19. Audit Logging              — structured logging, MCP notifications"
    echo "    20. Rug-Pull Defense           — tool mutation, version pinning"
    echo ""
    if [ "$ERRORS" -gt 0 ]; then
        echo -e "  ${YELLOW}Warnings: $ERRORS non-critical issue(s) during install.${NC}"
        echo -e "  ${YELLOW}Scroll up to see details.${NC}"
        echo ""
    fi
    echo -e "  ${YELLOW}Tip: Run /safetycheck in any project. MCP projects get${NC}"
    echo -e "  ${YELLOW}12 additional security checks automatically.${NC}"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Step 9 — Safety Check${NC}"
    echo -e "${BLUE}  Install the /safetycheck security audit skill${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    detect_os
    verify_prerequisites
    install_skill
    run_self_test
    print_summary
}

main "$@"
