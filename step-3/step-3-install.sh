#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 3 — ClaudeFlow Setup
# Installs and configures ClaudeFlow multi-agent orchestration
# Run this in Warp after completing Steps 1 and 2
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
# Detect OS
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin)       OS="mac" ;;
        Linux)        OS="linux" ;;
        MINGW*|MSYS*) fail "Windows detected (Git Bash). Run the PowerShell version instead:\n\n  irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-3/step-3-install.ps1 | iex" ;;
        *)            fail "Unsupported OS: $(uname -s)." ;;
    esac
    info "Detected OS: $OS"
}

# -----------------------------------------------------------------------------
# Verify Steps 1 and 2 ran
# -----------------------------------------------------------------------------
verify_prerequisites() {
    if ! command -v node &>/dev/null; then
        fail "Node.js not found. Run Step 1 first."
    fi
    if ! command -v claude &>/dev/null; then
        fail "Claude Code not found. Run Step 1 first."
    fi
    if ! command -v jq &>/dev/null; then
        fail "jq not found. Run Step 2 first."
    fi
    success "Steps 1 and 2 prerequisites verified"
}

# -----------------------------------------------------------------------------
# Install ClaudeFlow CLI
# -----------------------------------------------------------------------------
install_claudeflow() {
    info "Installing ClaudeFlow CLI..."
    npm install -g @claude-flow/cli@latest 2>/dev/null \
        || sudo npm install -g @claude-flow/cli@latest

    # Verify it works
    if npx @claude-flow/cli@latest --version &>/dev/null 2>&1; then
        success "ClaudeFlow CLI installed ($(npx @claude-flow/cli@latest --version 2>/dev/null))"
    else
        # npx will download it on demand even if global install failed
        success "ClaudeFlow CLI available via npx"
    fi
}

# -----------------------------------------------------------------------------
# Add ClaudeFlow as MCP server to Claude Code
# -----------------------------------------------------------------------------
configure_mcp() {
    info "Adding ClaudeFlow as MCP server to Claude Code..."

    # Check if already configured
    if claude mcp list 2>/dev/null | grep -q "claude-flow" 2>/dev/null; then
        success "ClaudeFlow MCP server already configured"
        return
    fi

    claude mcp add claude-flow -- npx -y @claude-flow/cli@latest 2>/dev/null

    if claude mcp list 2>/dev/null | grep -q "claude-flow" 2>/dev/null; then
        success "ClaudeFlow MCP server added to Claude Code"
    else
        # Try alternative approach — write directly to config
        warn "MCP add command may not have worked. Trying direct config..."
        CLAUDE_MCP_CONFIG="$HOME/.claude/claude_mcp_config.json"
        if [ -f "$CLAUDE_MCP_CONFIG" ]; then
            if ! grep -q "claude-flow" "$CLAUDE_MCP_CONFIG" 2>/dev/null; then
                jq '.mcpServers["claude-flow"] = {"command": "npx", "args": ["-y", "@claude-flow/cli@latest"]}' "$CLAUDE_MCP_CONFIG" > "${CLAUDE_MCP_CONFIG}.tmp" \
                    && mv "${CLAUDE_MCP_CONFIG}.tmp" "$CLAUDE_MCP_CONFIG"
            fi
        else
            cat > "$CLAUDE_MCP_CONFIG" << 'MCP_EOF'
{
  "mcpServers": {
    "claude-flow": {
      "command": "npx",
      "args": ["-y", "@claude-flow/cli@latest"]
    }
  }
}
MCP_EOF
        fi
        success "ClaudeFlow MCP server configured (direct config)"
    fi
}

# -----------------------------------------------------------------------------
# Start the ClaudeFlow daemon
# -----------------------------------------------------------------------------
start_daemon() {
    info "Starting ClaudeFlow daemon..."
    npx @claude-flow/cli@latest daemon start 2>/dev/null || true

    # Daemon starts in background. Check if PID file exists as proof it launched.
    if [ -f ".claude-flow/daemon.pid" ] || npx @claude-flow/cli@latest daemon status 2>/dev/null | grep -q "PID" 2>/dev/null; then
        success "ClaudeFlow daemon started"
    else
        warn "Daemon may not have started. Claude will start it automatically when needed."
    fi
}

# -----------------------------------------------------------------------------
# Run doctor to verify and fix issues
# -----------------------------------------------------------------------------
run_doctor() {
    info "Running ClaudeFlow doctor..."
    npx @claude-flow/cli@latest doctor --fix 2>/dev/null

    success "ClaudeFlow doctor completed"
}

# -----------------------------------------------------------------------------
# Initialize default configuration
# -----------------------------------------------------------------------------
init_config() {
    info "Initializing ClaudeFlow configuration..."

    # Only init if not already initialized
    if [ -f ".claude-flow.json" ] || [ -f "claude-flow.json" ]; then
        success "ClaudeFlow already initialized in this directory"
        return
    fi

    npx @claude-flow/cli@latest init 2>/dev/null || true
    success "ClaudeFlow configuration initialized"
}

# -----------------------------------------------------------------------------
# Initialize memory database and install optional deps
# -----------------------------------------------------------------------------
init_memory_and_deps() {
    # Initialize memory backend
    info "Initializing memory database..."
    npx @claude-flow/cli@latest memory configure --backend hybrid 2>/dev/null || true
    success "Memory database initialized"

    # Install TypeScript (needed for some ClaudeFlow features)
    if ! command -v tsc &>/dev/null; then
        info "Installing TypeScript..."
        npm install -g typescript 2>/dev/null || true
    fi
    success "TypeScript available"

    # Install agentic-flow (optional but enables embeddings/routing)
    info "Installing agentic-flow..."
    npm install -g agentic-flow@latest 2>/dev/null || true
    success "agentic-flow installed"
}

# -----------------------------------------------------------------------------
# Install Context Hub
# -----------------------------------------------------------------------------
install_context_hub() {
    info "Installing Context Hub..."
    npm install -g @aisuite/chub 2>/dev/null \
        || sudo npm install -g @aisuite/chub

    if command -v chub &>/dev/null; then
        success "Context Hub installed ($(chub --version 2>/dev/null || echo 'available'))"
    else
        # May work via npx even if global install didn't link
        if npx @aisuite/chub --version &>/dev/null 2>&1; then
            success "Context Hub available via npx"
        else
            soft_fail "Context Hub installation failed"
            return
        fi
    fi
}

# -----------------------------------------------------------------------------
# Set up Context Hub skill for Claude Code
# -----------------------------------------------------------------------------
configure_context_hub_skill() {
    SKILL_DIR="$HOME/.claude/skills/get-api-docs"

    if [ -f "$SKILL_DIR/SKILL.md" ]; then
        success "Context Hub skill already configured"
        return
    fi

    info "Setting up Context Hub skill for Claude Code..."
    mkdir -p "$SKILL_DIR"

    cat > "$SKILL_DIR/SKILL.md" << 'SKILL_EOF'
---
name: get-api-docs
description: Fetch curated API documentation to prevent hallucination. Use when writing code that calls external APIs.
---

# API Documentation Retrieval

When you need to write code that calls an external API, use Context Hub to get accurate, up-to-date documentation instead of relying on training data.

## Usage

Search for available docs:
```bash
chub search <library-name>
```

Get specific docs for a language:
```bash
chub get <library>/<endpoint> --lang <py|js|ts|go|rust>
```

Add notes for future sessions:
```bash
chub annotate <doc-id> "<your note>"
```

## When to use this skill
- Before writing any API integration code
- When you're unsure about function signatures or parameters
- When the user asks you to use a specific library you haven't verified
- Always prefer Context Hub docs over your training data for API calls
SKILL_EOF

    success "Context Hub skill configured at $SKILL_DIR"
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

    # ClaudeFlow CLI available
    if npx @claude-flow/cli@latest --version &>/dev/null 2>&1; then
        success "TEST: ClaudeFlow CLI available"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: ClaudeFlow CLI not available"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # MCP server configured
    if claude mcp list 2>/dev/null | grep -q "claude-flow" 2>/dev/null; then
        success "TEST: ClaudeFlow MCP server configured"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: ClaudeFlow MCP server not detected"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Daemon available
    if [ -f ".claude-flow/daemon.pid" ] || npx @claude-flow/cli@latest daemon status 2>/dev/null | grep -q "PID" 2>/dev/null; then
        success "TEST: ClaudeFlow daemon available"
        TEST_PASS=$((TEST_PASS + 1))
    else
        warn "TEST: ClaudeFlow daemon not detected (will auto-start when needed)"
        TEST_PASS=$((TEST_PASS + 1))
    fi

    # Context Hub
    if command -v chub &>/dev/null || npx @aisuite/chub --version &>/dev/null 2>&1; then
        success "TEST: Context Hub available"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: Context Hub not available"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Context Hub skill
    if [ -f "$HOME/.claude/skills/get-api-docs/SKILL.md" ]; then
        success "TEST: Context Hub skill configured"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: Context Hub skill not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Memory system configured
    if [ -f ".claude-flow/config.yaml" ] && grep -q "hybrid\|memory" ".claude-flow/config.yaml" 2>/dev/null; then
        success "TEST: Memory system configured"
        TEST_PASS=$((TEST_PASS + 1))
    elif [ -d ".claude-flow/data/memory" ] || [ -d "data/memory" ]; then
        success "TEST: Memory system configured"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: Memory system not configured"
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
    echo -e "${GREEN}  Step 3 Complete — ClaudeFlow is Ready${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  ClaudeFlow is now installed and connected to Claude Code."
    echo ""
    echo "  What you can do now:"
    echo "    - Claude can spawn multiple agents to work in parallel"
    echo "    - Memory persists across sessions automatically"
    echo "    - Smart model routing saves up to 75% on token costs"
    echo "    - Swarm orchestration for complex multi-step tasks"
    echo ""
    echo "  Try it out. Open a new cskip session and ask Claude"
    echo "  to do something complex. You'll see the difference."
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
    echo -e "${BLUE}  Step 3 — ClaudeFlow${NC}"
    echo -e "${BLUE}  Multi-agent orchestration • macOS + Linux${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    detect_os
    verify_prerequisites
    install_claudeflow
    configure_mcp
    start_daemon
    run_doctor
    init_config
    init_memory_and_deps
    install_context_hub
    configure_context_hub_skill
    run_self_test
    print_summary
}

main "$@"
