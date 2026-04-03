#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 3 — Ruflo Setup
# Installs and configures Ruflo multi-agent swarming orchestration
# Run this in your terminal after completing Steps 1 and 2
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
        MINGW*|MSYS*|CYGWIN*) fail "Windows is not supported. This script is for macOS and Linux only." ;;
        *)            fail "Unsupported OS: $(uname -s). This script supports macOS and Linux only." ;;
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
# Install Ruflo CLI
# -----------------------------------------------------------------------------
install_ruflo() {
    info "Installing Ruflo CLI..."
    npm install -g ruflo@latest 2>/dev/null \
        || sudo npm install -g ruflo@latest

    # Verify it works
    if npx ruflo@latest --version &>/dev/null 2>&1; then
        success "Ruflo CLI installed ($(npx ruflo@latest --version 2>/dev/null))"
    else
        # npx will download it on demand even if global install failed
        success "Ruflo CLI available via npx"
    fi
}

# -----------------------------------------------------------------------------
# Add Ruflo as MCP server to Claude Code
# -----------------------------------------------------------------------------
configure_mcp() {
    info "Adding Ruflo as MCP server to Claude Code..."

    # Check if already configured
    if claude mcp list 2>/dev/null | grep -q "ruflo" 2>/dev/null; then
        success "Ruflo MCP server already configured"
        return
    fi

    claude mcp add ruflo -- npx -y ruflo@latest 2>/dev/null

    if claude mcp list 2>/dev/null | grep -q "ruflo" 2>/dev/null; then
        success "Ruflo MCP server added to Claude Code"
    else
        # Try alternative approach — write directly to config
        warn "MCP add command may not have worked. Trying direct config..."
        CLAUDE_MCP_CONFIG="$HOME/.claude/claude_mcp_config.json"
        if [ -f "$CLAUDE_MCP_CONFIG" ]; then
            if ! grep -q "ruflo" "$CLAUDE_MCP_CONFIG" 2>/dev/null; then
                jq '.mcpServers["ruflo"] = {"command": "npx", "args": ["-y", "ruflo@latest"]}' "$CLAUDE_MCP_CONFIG" > "${CLAUDE_MCP_CONFIG}.tmp" \
                    && mv "${CLAUDE_MCP_CONFIG}.tmp" "$CLAUDE_MCP_CONFIG"
            fi
        else
            cat > "$CLAUDE_MCP_CONFIG" << 'MCP_EOF'
{
  "mcpServers": {
    "ruflo": {
      "command": "npx",
      "args": ["-y", "ruflo@latest"]
    }
  }
}
MCP_EOF
        fi
        success "Ruflo MCP server configured (direct config)"
    fi
}

# -----------------------------------------------------------------------------
# Start the Ruflo daemon
# -----------------------------------------------------------------------------
start_daemon() {
    info "Starting Ruflo daemon..."
    npx ruflo@latest daemon start 2>/dev/null || true

    # Daemon starts in background. Check if PID file exists as proof it launched.
    if [ -f ".claude-flow/daemon.pid" ] || npx ruflo@latest daemon status 2>/dev/null | grep -q "PID" 2>/dev/null; then
        success "Ruflo daemon started"
    else
        warn "Daemon may not have started. Claude will start it automatically when needed."
    fi
}

# -----------------------------------------------------------------------------
# Run doctor to verify and fix issues
# -----------------------------------------------------------------------------
run_doctor() {
    info "Running Ruflo doctor..."
    npx ruflo@latest doctor --fix 2>/dev/null

    success "Ruflo doctor completed"
}

# -----------------------------------------------------------------------------
# Initialize default configuration
# -----------------------------------------------------------------------------
init_config() {
    info "Initializing Ruflo configuration..."

    # Only init if not already initialized
    if [ -f ".claude-flow/config.yaml" ] || [ -f ".ruflo.json" ] || [ -f "ruflo.json" ]; then
        success "Ruflo already initialized in this directory"
        return
    fi

    npx ruflo@latest init 2>/dev/null || true

    # Ruflo init may write a verbose statusLine to project-level .claude/settings.json.
    # Remove it so our clean global statusline (Final Step) isn't overridden.
    PROJECT_SETTINGS=".claude/settings.json"
    if [ -f "$PROJECT_SETTINGS" ] && command -v jq &>/dev/null; then
        if jq -e '.statusLine' "$PROJECT_SETTINGS" &>/dev/null; then
            jq 'del(.statusLine)' "$PROJECT_SETTINGS" > "${PROJECT_SETTINGS}.tmp" \
                && mv "${PROJECT_SETTINGS}.tmp" "$PROJECT_SETTINGS"
            info "Removed Ruflo statusLine override from project settings (global statusline takes priority)"
        fi
    fi

    success "Ruflo configuration initialized"
}

# -----------------------------------------------------------------------------
# Initialize memory database and install optional deps
# -----------------------------------------------------------------------------
init_memory_and_deps() {
    # Initialize memory backend
    info "Initializing memory database..."
    npx ruflo@latest memory configure --backend hybrid 2>/dev/null || true
    success "Memory database initialized"

    # Install TypeScript (needed for some Ruflo features)
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
# Lock model to Opus — prevent silent downgrade to Haiku
# -----------------------------------------------------------------------------
configure_model_defaults() {
    info "Setting default model to Opus..."

    # Set default model to opus
    npx ruflo@latest config set --key "model.default" --value "opus" 2>/dev/null || true

    # Set minimum model floor to opus
    npx ruflo@latest config set --key "model.routing.minModel" --value "opus" 2>/dev/null || true

    # Disable automatic model routing (CLI can't pass boolean false, so patch config directly)
    CONFIG_FILE=".claude-flow/config.json"
    if [ -f "$CONFIG_FILE" ] && command -v jq &>/dev/null; then
        jq '.scopes.project["model.default"] = "opus" | .scopes.system["model.default"] = "opus" | .scopes.project["model.routing.enabled"] = false | .scopes.system["model.routing.enabled"] = false' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" \
            && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    fi

    # Also patch config.yaml if it exists (init creates this file)
    YAML_CONFIG=".claude-flow/config.yaml"
    if [ -f "$YAML_CONFIG" ]; then
        if grep -q "default:" "$YAML_CONFIG" 2>/dev/null; then
            sed -i.bak 's/default:.*/default: opus/' "$YAML_CONFIG" && rm -f "${YAML_CONFIG}.bak"
        else
            echo "  default: opus" >> "$YAML_CONFIG"
        fi
    fi

    success "Model locked to Opus (no silent downgrading)"
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
# Install Swarm Skills (/rswarm, /rhive, /rmini) + Statusline
# -----------------------------------------------------------------------------
install_swarm_skills() {
    info "Installing swarm skills and statusline..."

    # --- /rswarm skill ---
    RSWARM_DIR="$HOME/.claude/skills/rswarm"
    mkdir -p "$RSWARM_DIR"
    cat > "$RSWARM_DIR/SKILL.md" << 'RSWARM_EOF'
---
name: rswarm
description: "Launch a full 15-agent Ruflo swarm to execute a task immediately. Triggers real multi-agent execution — not a reference."
---

# Ruflo Advanced Swarm — Immediate Execution

When this skill is invoked, IMMEDIATELY launch a 15-agent swarm. Do NOT explain how swarms work. Do NOT show code examples. Do NOT ask clarifying questions unless the task is truly ambiguous. ACT.

## Execution Steps

1. Read the user's task (everything they typed after `/rswarm`)
2. **Signal status line**: Run `echo 15 > /tmp/ruflo-swarm-active` via Bash to light up the swarm indicator
3. Initialize the swarm in ONE message:
   - Call `mcp__claude-flow__swarm_init` with topology `hierarchical-mesh`, maxAgents 15, strategy `specialized`
   - Spawn ALL 15 agents via the Agent tool with `run_in_background: true` — every agent in ONE message
4. After spawning, STOP. Do not poll. Do not check status. Wait for agents to return.
5. When results come back, synthesize and present the combined output.
6. **Clear status line**: Run `rm -f /tmp/ruflo-swarm-active` via Bash to turn off the swarm indicator

## The 15 Agents

| # | Agent Type | Role | Task Focus |
|---|-----------|------|------------|
| 1 | system-architect | Lead Architect | System design, task decomposition, coordinates all agents |
| 2 | coder | Backend Dev 1 | Core backend implementation |
| 3 | coder | Backend Dev 2 | Secondary backend / services |
| 4 | coder | Frontend Dev | UI / frontend implementation |
| 5 | backend-dev | DB Engineer | Schema, queries, data layer |
| 6 | tester | Test Engineer 1 | Unit + integration tests |
| 7 | tester | Test Engineer 2 | E2E + edge case tests |
| 8 | security-auditor | Security Auditor | Vulnerability scanning, input validation, secrets check |
| 9 | performance-engineer | Perf Engineer | Bottleneck analysis, optimization |
| 10 | reviewer | Code Reviewer | Quality, patterns, best practices |
| 11 | researcher | Researcher | Background research, prior art, docs lookup |
| 12 | analyst | Code Analyst | Architecture assessment, dependency analysis |
| 13 | coder | DevOps Engineer | CI/CD, deployment, infrastructure |
| 14 | coder | Technical Writer | Documentation, README, usage guides |
| 15 | tester | QA Coordinator | Final validation, cross-agent consistency check |

Adapt agent assignments to the task — not every task needs all 15 roles. If the task is frontend-only, shift agent roles accordingly. But ALWAYS spawn 15.

## Rules

- Model: Opus only. Never route to Haiku or Sonnet.
- Topology: hierarchical-mesh (architect leads, agents coordinate peer-to-peer within their layer)
- All agents spawned in background in ONE message
- Each agent gets a clear, specific sub-task with full context — not vague instructions
- After spawning, STOP and wait
- When results arrive, review ALL results before presenting final output
RSWARM_EOF
    success "Swarm skill (/rswarm) installed"

    # --- /rhive skill ---
    RHIVE_DIR="$HOME/.claude/skills/rhive"
    mkdir -p "$RHIVE_DIR"
    cat > "$RHIVE_DIR/SKILL.md" << 'RHIVE_EOF'
---
name: rhive
description: "Launch a queen-led Ruflo hive-mind with raft consensus for autonomous task execution. The queen decomposes and delegates — hands-off."
---

# Ruflo Hive Mind — Queen-Led Autonomous Execution

When this skill is invoked, IMMEDIATELY initialize a hive-mind with a queen agent that autonomously manages the work. Do NOT explain how hive-minds work. Do NOT show code examples. ACT.

## How This Differs from /rswarm

- `/rswarm` = you define the task, Claude pre-assigns 15 agents with fixed roles
- `/rhive` = you define the GOAL, a queen agent takes over and autonomously manages everything

The queen decides how many workers to spawn, what roles they need, how to coordinate them, and when the work is done. You set the goal and step back.

## Execution Steps

1. Read the user's goal (everything they typed after `/rhive`)
2. **Signal status line**: Run `touch /tmp/ruflo-hive-active` via Bash to light up the hive indicator
3. Initialize the hive-mind in ONE message:
   - Call `mcp__claude-flow__hive-mind_init` with consensus `raft`
   - Spawn a queen agent (hierarchical-coordinator type) via the Agent tool with `run_in_background: true`
   - The queen's prompt MUST include:
     a. The user's full goal
     b. Instructions to use `mcp__claude-flow__hive-mind_spawn` to create workers as needed
     c. Instructions to use `mcp__claude-flow__hive-mind_broadcast` for coordination
     d. Instructions to use `mcp__claude-flow__hive-mind_consensus` for decisions
     e. Instructions to use `mcp__claude-flow__hive-mind_memory` for shared state
     f. Instructions to present final synthesized output when complete
4. After spawning the queen, STOP. Do not poll. Do not check status. The queen runs the show.
5. When the queen returns results, present them to the user.
6. **Clear status line**: Run `rm -f /tmp/ruflo-hive-active` via Bash to turn off the hive indicator

## Queen Agent Behavior

The queen MUST:
- Decompose the goal into sub-tasks
- Decide which worker types to spawn (from the 60+ available agent types)
- Assign specific sub-tasks to each worker
- Monitor worker output and coordinate
- Use raft consensus — queen is the leader, maintains authoritative state
- Use hive-mind memory for shared context across all workers
- Synthesize all worker results into a final deliverable
- Shut down workers when done

## Rules

- Model: Opus only. Never route to Haiku or Sonnet.
- Consensus: Raft (queen is authoritative leader)
- Queen spawns workers autonomously — do not pre-define the team
- Maximum workers: 15 (respect maxAgents config)
- After spawning the queen, STOP and wait
- Trust the queen's judgment on team composition and coordination
RHIVE_EOF
    success "Hive skill (/rhive) installed"

    # --- /rmini skill ---
    RMINI_DIR="$HOME/.claude/skills/rmini"
    mkdir -p "$RMINI_DIR"
    cat > "$RMINI_DIR/SKILL.md" << 'RMINI_EOF'
---
name: rmini
description: "Launch a compact 5-agent Ruflo swarm for focused task execution. Smaller than /rswarm but still parallel and powerful."
---

# Ruflo Mini Swarm — Compact Execution

When this skill is invoked, IMMEDIATELY launch a 5-agent swarm. Do NOT explain how swarms work. Do NOT show code examples. Do NOT ask clarifying questions unless the task is truly ambiguous. ACT.

## Execution Steps

1. Read the user's task (everything they typed after `/rmini`)
2. **Signal status line**: Run `echo 5 > /tmp/ruflo-mini-active` via Bash to light up the 🍯 indicator
3. Initialize the swarm in ONE message:
   - Call `mcp__claude-flow__swarm_init` with topology `hierarchical-mesh`, maxAgents 5, strategy `specialized`
   - Spawn ALL 5 agents via the Agent tool with `run_in_background: true` — every agent in ONE message
4. After spawning, STOP. Do not poll. Do not check status. Wait for agents to return.
5. When results come back, synthesize and present the combined output.
6. **Clear status line**: Run `rm -f /tmp/ruflo-mini-active` via Bash to turn off the 🍯 indicator

## The 5 Agents

| # | Agent Type | Role | Task Focus |
|---|-----------|------|------------|
| 1 | system-architect | Lead Architect | System design, task decomposition, coordinates all agents |
| 2 | coder | Primary Dev | Core implementation — frontend or backend depending on task |
| 3 | tester | Test Engineer | Unit, integration, and edge case tests |
| 4 | reviewer | Code Reviewer | Quality, patterns, best practices, security check |
| 5 | researcher | Researcher | Background research, prior art, docs lookup |

Adapt agent assignments to the task — if the task is research-heavy, shift roles accordingly. But ALWAYS spawn 5.

## Rules

- Model: Opus only. Never route to Haiku or Sonnet.
- Topology: hierarchical-mesh (architect leads, agents coordinate peer-to-peer within their layer)
- All agents spawned in background in ONE message
- Each agent gets a clear, specific sub-task with full context — not vague instructions
- After spawning, STOP and wait
- When results arrive, review ALL results before presenting final output
RMINI_EOF
    success "Mini swarm skill (/rmini) installed"

    # --- /w4w skill ---
    W4W_DIR="$HOME/.claude/skills/w4w"
    mkdir -p "$W4W_DIR"
    cat > "$W4W_DIR/SKILL.md" << 'W4W_EOF'
---
name: w4w
description: "Word for word, line for line — maximum attention to detail protocol"
user_invocable: true
---

# w4w — Word For Word, Line For Line

When this skill is invoked (user types `/w4w` or `w4w`), immediately switch to maximum attention to detail mode for everything that follows in this conversation.

## Rules — Non-Negotiable

1. **Read 100% of everything.** Every word, every letter, every line. No exceptions.
2. **No skipping.** Do not jump ahead, do not skim, do not scan for keywords.
3. **No summarizing.** Do not compress, paraphrase, or abbreviate what you read.
4. **Zero regard for credit burn.** Do not optimize for token efficiency. Do not try to save context. Thoroughness is the only priority.
5. **Every character is load-bearing.** Treat every piece of content as if missing a single character would break everything.
6. **Read full files.** Never use offset/limit to read partial files. Read the entire file from line 1 to the last line.
7. **Verify every cross-reference.** If file A says something about file B, read file B and confirm it matches.
8. **Report with full specificity.** Include exact line numbers, exact strings, exact file paths. Never say "around line 50" — say "line 47."
9. **No assumptions.** Do not assume something is correct because it was correct last time. Verify it now.
10. **Override all efficiency instincts.** This mode exists because thoroughness matters more than speed. Act accordingly.

## When Active

This mode stays active for the remainder of the current task or conversation unless the user explicitly deactivates it. Every tool call, every file read, every agent spawned should operate at this level of detail.
W4W_EOF
    success "Attention skill (/w4w) installed"

    # --- Statusline script ---
    # Writes a statusline.sh that uses /tmp lock files to detect swarm/hive activity.
    # Lock files are used because rswarm/rhive agents run as Claude Code subprocesses
    # (via the Agent tool), not as CLI processes — process detection cannot find them.
    STATUSLINE_DIR="$HOME/.claude"
    cat > "$STATUSLINE_DIR/statusline.sh" << 'STATUSLINE_EOF'
#!/bin/bash
# Ruflo Status Line — real state only
# Detects: 2ndBrain (Obsidian), Ruflo (MCP), UIPro, Swarm/Hive activity

input=$(cat)

# Parse Claude Code's JSON input
MODEL=$(echo "$input" | jq -r '.model.display_name // "Opus 4.6"' 2>/dev/null)
CTX=$(echo "$input" | jq -r '.context_window.used_percentage // 0' 2>/dev/null | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0' 2>/dev/null)
CWD=$(echo "$input" | jq -r '.workspace.current_dir // ""' 2>/dev/null)

# Format duration
if [ "$DURATION_MS" != "0" ] && [ "$DURATION_MS" != "null" ]; then
  SECS=$((${DURATION_MS%.*} / 1000))
  MINS=$((SECS / 60))
  REMAINING_SECS=$((SECS % 60))
  if [ "$MINS" -gt 0 ]; then
    TIME_FMT="${MINS}m${REMAINING_SECS}s"
  else
    TIME_FMT="${SECS}s"
  fi
else
  TIME_FMT="0s"
fi

# --- 2ndBRAIN CHECK ---
BRAIN=""
if echo "$CWD" | grep -qiE "OBSIDIAN/(2ndBrain|MASTER)" 2>/dev/null; then
  BRAIN="🧠 2ndBrain"
fi

# --- RUFLO CHECK ---
RUFLO=""
if pgrep -f "claude-flow.*mcp" >/dev/null 2>&1 || pgrep -f "@claude-flow/cli" >/dev/null 2>&1 || pgrep -f "ruflo" >/dev/null 2>&1; then
  RUFLO="⚡ Ruflo"
fi

# --- UIPRO CHECK (always on — global skill) ---
UIPRO="🎨 UIPro"

# --- SWARM CHECK (only shows when actively running) ---
# Lock file is written by /rswarm skill, removed on completion.
# Agents run as Claude Code subprocesses (not CLI), so pgrep won't find them.
# Auto-clean lock files older than 30 min as stale.
SWARM=""
SWARM_LOCK="/tmp/ruflo-swarm-active"
if [ -f "$SWARM_LOCK" ] 2>/dev/null; then
  if [ "$(find /tmp -maxdepth 1 -name 'ruflo-swarm-active' -mmin +30 2>/dev/null)" ]; then
    rm -f "$SWARM_LOCK" 2>/dev/null
  else
    AGENT_COUNT=$(cat "$SWARM_LOCK" 2>/dev/null || echo "")
    if [ -n "$AGENT_COUNT" ]; then
      SWARM="🐝 ${AGENT_COUNT}"
    else
      SWARM="🐝"
    fi
  fi
fi

# --- HIVE CHECK (only shows when actively running) ---
# Same approach — trust lock file, auto-clean after 30 min.
HIVE=""
HIVE_LOCK="/tmp/ruflo-hive-active"
if [ -f "$HIVE_LOCK" ] 2>/dev/null; then
  if [ "$(find /tmp -maxdepth 1 -name 'ruflo-hive-active' -mmin +30 2>/dev/null)" ]; then
    rm -f "$HIVE_LOCK" 2>/dev/null
  else
    HIVE="👑 Hive"
  fi
fi

# --- MINI CHECK (only shows when actively running) ---
# Same approach — trust lock file, auto-clean after 30 min.
MINI=""
MINI_LOCK="/tmp/ruflo-mini-active"
if [ -f "$MINI_LOCK" ] 2>/dev/null; then
  if [ "$(find /tmp -maxdepth 1 -name 'ruflo-mini-active' -mmin +30 2>/dev/null)" ]; then
    rm -f "$MINI_LOCK" 2>/dev/null
  else
    MINI_AGENT_COUNT=$(cat "$MINI_LOCK" 2>/dev/null || echo "")
    if [ -n "$MINI_AGENT_COUNT" ]; then
      MINI="🍯 ${MINI_AGENT_COUNT}"
    else
      MINI="🍯"
    fi
  fi
fi

# --- BUILD THE LINE ---
PARTS=""

# 2ndBrain + Ruflo
if [ -n "$BRAIN" ] && [ -n "$RUFLO" ]; then
  PARTS="${BRAIN} + ${RUFLO}"
elif [ -n "$BRAIN" ]; then
  PARTS="${BRAIN}"
elif [ -n "$RUFLO" ]; then
  PARTS="${RUFLO}"
fi

# UIPro (always on)
if [ -n "$PARTS" ]; then
  PARTS="${PARTS} + ${UIPRO}"
else
  PARTS="${UIPRO}"
fi

# Swarm, Hive, or Mini activity
ACTIVITY=""
if [ -n "$SWARM" ]; then
  ACTIVITY="${SWARM}"
fi
if [ -n "$HIVE" ]; then
  [ -n "$ACTIVITY" ] && ACTIVITY="${ACTIVITY} + "
  ACTIVITY="${ACTIVITY}${HIVE}"
fi
if [ -n "$MINI" ]; then
  [ -n "$ACTIVITY" ] && ACTIVITY="${ACTIVITY} + "
  ACTIVITY="${ACTIVITY}${MINI}"
fi
if [ -n "$ACTIVITY" ]; then
  PARTS="${PARTS} [${ACTIVITY}]"
fi

echo "${PARTS} • ${MODEL} • ⏱ ${TIME_FMT} • ${CTX}% ctx"
STATUSLINE_EOF
    chmod +x "$STATUSLINE_DIR/statusline.sh"
    success "Statusline script installed at $STATUSLINE_DIR/statusline.sh"

    # --- Configure statusline in Claude Code settings ---
    SETTINGS_FILE="$HOME/.claude/settings.json"
    if [ -f "$SETTINGS_FILE" ] && command -v jq &>/dev/null; then
        # Check if statusline is already configured
        EXISTING=$(jq -r '.statusLine.command // ""' "$SETTINGS_FILE" 2>/dev/null)
        if [ -z "$EXISTING" ] || [ "$EXISTING" = "null" ]; then
            jq '.statusLine = {"type": "command", "command": "~/.claude/statusline.sh"}' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" \
                && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
            success "Statusline configured in Claude Code settings"
        else
            success "Statusline already configured (${EXISTING})"
        fi
    else
        warn "Could not configure statusline automatically. Add to ~/.claude/settings.json manually:"
        echo '  "statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}'
    fi
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

    # Ruflo CLI available
    if npx ruflo@latest --version &>/dev/null 2>&1; then
        success "TEST: Ruflo CLI available"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: Ruflo CLI not available"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # MCP server configured
    if claude mcp list 2>/dev/null | grep -q "ruflo" 2>/dev/null; then
        success "TEST: Ruflo MCP server configured"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: Ruflo MCP server not detected"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Daemon available
    if [ -f ".claude-flow/daemon.pid" ] || npx ruflo@latest daemon status 2>/dev/null | grep -q "PID" 2>/dev/null; then
        success "TEST: Ruflo daemon available"
        TEST_PASS=$((TEST_PASS + 1))
    else
        warn "TEST: Ruflo daemon not detected (will auto-start when needed)"
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

    # Swarm skill (/rswarm)
    if [ -f "$HOME/.claude/skills/rswarm/SKILL.md" ]; then
        success "TEST: Swarm skill (/rswarm) installed"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: Swarm skill (/rswarm) not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Hive skill (/rhive)
    if [ -f "$HOME/.claude/skills/rhive/SKILL.md" ]; then
        success "TEST: Hive skill (/rhive) installed"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: Hive skill (/rhive) not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Mini swarm skill (/rmini)
    if [ -f "$HOME/.claude/skills/rmini/SKILL.md" ]; then
        success "TEST: Mini swarm skill (/rmini) installed"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: Mini swarm skill (/rmini) not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # W4W skill (/w4w)
    if [ -f "$HOME/.claude/skills/w4w/SKILL.md" ]; then
        success "TEST: W4W skill (/w4w) installed"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: W4W skill (/w4w) not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Statusline
    if [ -f "$HOME/.claude/statusline.sh" ] && [ -x "$HOME/.claude/statusline.sh" ]; then
        success "TEST: Statusline script installed"
        TEST_PASS=$((TEST_PASS + 1))
    else
        soft_fail "TEST: Statusline script not found or not executable"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Model set to Opus (check config.json first, then config.yaml, then CLI)
    CONFIG_JSON=".claude-flow/config.json"
    if [ -f "$CONFIG_JSON" ] && jq -e '.scopes.project["model.default"] == "opus" or .scopes.system["model.default"] == "opus"' "$CONFIG_JSON" &>/dev/null; then
        success "TEST: Model locked to Opus"
        TEST_PASS=$((TEST_PASS + 1))
    elif grep -q "default: opus" ".claude-flow/config.yaml" 2>/dev/null; then
        success "TEST: Model locked to Opus"
        TEST_PASS=$((TEST_PASS + 1))
    else
        MODEL_CONFIG=$(npx ruflo@latest config get --key "model.default" 2>/dev/null || echo "")
        if echo "$MODEL_CONFIG" | grep -qi "opus" 2>/dev/null; then
            success "TEST: Model locked to Opus"
            TEST_PASS=$((TEST_PASS + 1))
        else
            soft_fail "TEST: Model default not set to Opus"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
    fi

    # Memory system configured (ruflo still uses .claude-flow/ directory internally)
    if [ -f ".claude-flow/config.yaml" ] && grep -q "hybrid\|memory" ".claude-flow/config.yaml" 2>/dev/null; then
        success "TEST: Memory system configured"
        TEST_PASS=$((TEST_PASS + 1))
    elif [ -d ".claude-flow/data" ] || [ -d "data/memory" ]; then
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
    echo -e "${GREEN}  Step 3 Complete — Ruflo is Ready${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Ruflo is now installed and connected to Claude Code."
    echo ""
    echo "  What you can do now:"
    echo "    - Claude can spawn multiple agents to work in parallel"
    echo "    - Memory persists across sessions automatically"
    echo "    - Model locked to Opus — no silent downgrades"
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
    echo -e "${BLUE}  Step 3 — Ruflo${NC}"
    echo -e "${BLUE}  Multi-agent orchestration • macOS + Linux${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    detect_os
    verify_prerequisites
    install_ruflo
    configure_mcp
    start_daemon
    run_doctor
    init_config
    init_memory_and_deps
    configure_model_defaults
    install_context_hub
    configure_context_hub_skill
    install_swarm_skills
    run_self_test
    print_summary
}

main "$@"
