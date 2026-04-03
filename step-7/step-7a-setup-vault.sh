#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 7a — Set up Second Brain vault structure
# Creates Zettelkasten folders, templates, CLAUDE.md, and sync script
# Run inside a cskip session after installing Obsidian
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
# Install Obsidian
# -----------------------------------------------------------------------------
install_obsidian() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Checking Obsidian Installation${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo "[INFO] Installing Obsidian..."
    if [ -d "/Applications/Obsidian.app" ] || [ -d "$HOME/Applications/Obsidian.app" ]; then
        echo "[OK] Obsidian already installed"
    else
        if command -v brew &>/dev/null; then
            brew install --cask obsidian
            echo "[OK] Obsidian installed"
        else
            echo "[WARN] Homebrew not found — install Obsidian manually from https://obsidian.md"
        fi
    fi
}

# -----------------------------------------------------------------------------
# Find the vault
# -----------------------------------------------------------------------------
find_vault() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Step 7a — Set Up Your Second Brain Vault${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Looking for your Obsidian vault..."
    echo ""

    # Try common locations
    VAULT_PATH=""
    for candidate in \
        "$HOME/Desktop/2ndBrain" \
        "$HOME/Desktop/Second-Brain" \
        "$HOME/Desktop/Vault" \
        "$HOME/Desktop/VAULT" \
        "$HOME/Documents/2ndBrain" \
        "$HOME/Documents/Second-Brain" \
        "$HOME/Documents/Vault"; do
        if [ -d "$candidate" ]; then
            VAULT_PATH="$candidate"
            break
        fi
    done

    # Also check for any .obsidian folder
    if [ -z "$VAULT_PATH" ]; then
        FOUND=$(find "$HOME/Desktop" "$HOME/Documents" -maxdepth 3 -name ".obsidian" -type d 2>/dev/null | head -1)
        if [ -n "$FOUND" ]; then
            VAULT_PATH="$(dirname "$FOUND")"
        fi
    fi

    if [ -n "$VAULT_PATH" ]; then
        echo -e "  Found vault at: ${GREEN}$VAULT_PATH${NC}"
        echo ""
        echo "  If this is wrong, set VAULT_PATH manually and re-run."
    else
        echo -e "  ${YELLOW}Could not auto-detect your vault.${NC}"
        echo ""
        echo "  Please tell Claude where your vault is. For example:"
        echo "  'My vault is at ~/Desktop/2ndBrain'"
        echo ""
        echo "  Or set it manually:"
        echo "  export VAULT_PATH=~/Desktop/YourVaultName"
        echo ""
        # Default to Desktop/2ndBrain so the script can continue
        VAULT_PATH="$HOME/Desktop/2ndBrain"
        warn "Defaulting to $VAULT_PATH. Change this if needed."
    fi

    export VAULT_PATH
}

# -----------------------------------------------------------------------------
# Create folder structure
# -----------------------------------------------------------------------------
create_folders() {
    info "Creating Zettelkasten folder structure..."

    mkdir -p "$VAULT_PATH/00-Inbox"
    mkdir -p "$VAULT_PATH/01-Fleeting"
    mkdir -p "$VAULT_PATH/02-Literature"
    mkdir -p "$VAULT_PATH/03-Permanent"
    mkdir -p "$VAULT_PATH/04-MOC"
    mkdir -p "$VAULT_PATH/05-Templates"
    mkdir -p "$VAULT_PATH/06-Assets"
    mkdir -p "$VAULT_PATH/07-Projects"

    # Set up Obsidian config to exclude non-note folders from graph
    mkdir -p "$VAULT_PATH/.obsidian"
    cat > "$VAULT_PATH/.obsidian/app.json" << 'APPJSON_EOF'
{
  "promptDelete": false,
  "attachmentFolderPath": "06-Assets",
  "useMarkdownLinks": false,
  "newLinkFormat": "shortest",
  "userIgnoreFilters": [
    "node_modules/",
    ".agents/",
    ".git/",
    ".import-staging/",
    ".claude/",
    ".claude-flow/",
    ".swarm/",
    "scripts/",
    "package.json",
    "package-lock.json",
    "skills-lock.json",
    ".DS_Store",
    ".sync-claude-to-vault.sh"
  ]
}
APPJSON_EOF

    success "Folder structure created"
}

# -----------------------------------------------------------------------------
# Create note templates
# -----------------------------------------------------------------------------
create_templates() {
    info "Creating note templates..."

    # Fleeting note template
    cat > "$VAULT_PATH/05-Templates/Fleeting-Template.md" << 'EOF'
---
title: "{{title}}"
date: {{date}}
type: fleeting
tags: []
related: []
---

{{content}}
EOF

    # Literature note template
    cat > "$VAULT_PATH/05-Templates/Literature-Template.md" << 'EOF'
---
title: "{{title}}"
date: {{date}}
type: literature
tags: []
source: "{{source}}"
related: []
---

## Summary

{{summary}}

## Key Ideas

-

## Links

-
EOF

    # Permanent note template
    cat > "$VAULT_PATH/05-Templates/Permanent-Template.md" << 'EOF'
---
title: "{{title}}"
date: {{date}}
type: permanent
tags: []
related: []
---

{{content}}

## Related

-
EOF

    # MOC template
    cat > "$VAULT_PATH/05-Templates/MOC-Template.md" << 'EOF'
---
title: "MOC — {{topic}}"
date: {{date}}
type: moc
tags: []
related: []
---

# {{topic}}

## Overview



## Notes

-

## Related MOCs

-
EOF

    # Project index template
    cat > "$VAULT_PATH/05-Templates/Project-Index-Template.md" << 'EOF'
---
title: "{{project_name}}"
date: {{date}}
type: project
tags: [project]
related: []
---

# {{project_name}}

## Overview



## Knowledge Base

-

## Conversation Logs

-

## Related Projects

-
EOF

    success "Note templates created in 05-Templates/"
}

# -----------------------------------------------------------------------------
# Create CLAUDE.md
# -----------------------------------------------------------------------------
create_claude_md() {
    info "Creating CLAUDE.md..."

    cat > "$VAULT_PATH/CLAUDE.md" << 'CLAUDEEOF'
# CLAUDE.md — 2ndBrain

This file provides guidance to Claude Code when working with this Obsidian vault.

## Vault Purpose

Personal knowledge management system (PKM) in Obsidian built on Zettelkasten principles for capturing, connecting, and retrieving knowledge.

## Vault Structure

```
2ndBrain/
├── 00-Inbox/        # Raw captures — URLs, quick thoughts, unprocessed notes
├── 01-Fleeting/     # Quick ideas and thoughts, lightly formatted
├── 02-Literature/   # Notes from articles, videos, books, podcasts (sourced content)
├── 03-Permanent/    # Refined atomic notes — one concept per note, densely linked
├── 04-MOC/          # Maps of Content — index notes that link to related permanent notes
├── 05-Templates/    # Note templates
├── 06-Assets/       # Images, attachments, PDFs
├── 07-Projects/     # Active projects with index notes
```

## Note Creation Conventions

### Linking Philosophy
- **Link liberally**: Create wikilinks (\`[[ ]]\` syntax) to concepts, people, projects, and ideas
- **Prefer atomic notes**: One concept per note, well-linked to related concepts
- **Use aliases**: \`[​[Machine Learning|ML]]\` when shorthand is clearer (note the pipe for display text)
- **Always link back**: Every note should link to at least one other note or MOC
- **Never put wikilinks inside tables**: Obsidian graph view cannot detect them. Use bullet lists instead.

### Frontmatter Standards

Every note should include YAML frontmatter:

```yaml
---
title: "Note Title"
date: YYYY-MM-DD
type: fleeting | literature | permanent | moc | project
tags: []
source: ""        # URL or reference (for literature notes)
related: []       # Links to related notes
---
```

### Note Types

#### Inbox Notes (00-Inbox/)
- Raw captures, minimal formatting
- Filename: `YYYY-MM-DD-brief-description.md`
- These get processed into fleeting or literature notes

#### Fleeting Notes (01-Fleeting/)
- Quick ideas, observations
- Filename: `YYYY-MM-DD-brief-description.md`
- Should be reviewed and either promoted to permanent or discarded

#### Literature Notes (02-Literature/)
- Summarize content from external sources
- Filename: `LIT-brief-description.md`
- Always include the source URL/reference
- Capture key ideas in your own words, not copy-paste
- Link to any existing permanent notes on the same concepts

#### Permanent Notes (03-Permanent/)
- Refined, atomic notes — one clear concept per note
- Filename: `brief-concept-name.md`
- Written in complete sentences as if explaining to someone else
- Densely linked to other permanent notes and MOCs

#### Maps of Content (04-MOC/)
- Index notes that group and link related permanent notes
- Filename: `MOC-topic-name.md`
- Provide structure and navigation to the vault

#### Projects (07-Projects/)
- Each project has its own folder with an index note
- Index note contains: overview, knowledge base links, conversation logs, related projects
- All related links must be bidirectional

### Tagging Conventions
- Use lowercase, hyphenated tags: `#machine-learning`, `#web-dev`
- Keep tags broad — linking does the granular work
- Common tags: `#concept`, `#tool`, `#person`, `#project`, `#idea`, `#question`

## WebFetch Workflow

When asked to capture content from a URL:
1. Use WebFetch to pull the page content
2. Create a Literature Note in `02-Literature/`
3. Summarize the key ideas in the user's own words
4. Extract atomic concepts and create/update Permanent Notes in `03-Permanent/`
5. Link the literature note to relevant permanent notes
6. Link permanent notes to relevant MOCs
7. Update MOCs if new topic areas emerge

## Processing Inbox

When asked to process the inbox:
1. Review each note in `00-Inbox/`
2. Determine if it's a fleeting thought or sourced content
3. Move/convert to appropriate folder (01-Fleeting or 02-Literature)
4. Extract permanent notes where concepts are clear
5. Link everything appropriately
6. Delete or archive the original inbox note

## Important Rules
- ALWAYS create bidirectional links (if A links to B, B must link to A)
- NEVER put wikilinks inside markdown tables (use bullet lists)
- ALWAYS add frontmatter to every note
- ALWAYS link new notes to at least one existing note or MOC
- Prefer creating a new linked note over adding a long section to an existing note
CLAUDEEOF

    success "CLAUDE.md created"
}

# -----------------------------------------------------------------------------
# Create sync script
# -----------------------------------------------------------------------------
create_sync_script() {
    info "Creating sync automation script..."

    cat > "$VAULT_PATH/sync.sh" << 'SYNCEOF'
#!/usr/bin/env bash
# Vault Sync Script — run this to process inbox and fix links
# Usage: bash sync.sh (from inside your vault directory)

echo "Processing vault..."
echo "Run this inside a Claude session for best results."
echo ""
echo "Suggested prompt for Claude:"
echo "  'Process my inbox, fix any broken bidirectional links,"
echo "   update MOCs, and validate all files in my vault.'"
SYNCEOF

    chmod +x "$VAULT_PATH/sync.sh"
    success "Sync script created at sync.sh"
}

# -----------------------------------------------------------------------------
# Register vault in Obsidian config
# -----------------------------------------------------------------------------
register_vault_in_obsidian() {
    info "Registering vault in Obsidian..."

    # Auto-register vault in Obsidian config
    OBSIDIAN_CONFIG_DIR="$HOME/Library/Application Support/obsidian"
    if [ "$(uname)" = "Darwin" ]; then
        mkdir -p "$OBSIDIAN_CONFIG_DIR"
        VAULT_ABS=$(cd "$VAULT_PATH" && pwd)
        TS=$(date +%s)000
        if [ -f "$OBSIDIAN_CONFIG_DIR/obsidian.json" ]; then
            # Add vault to existing config using jq
            if command -v jq &>/dev/null; then
                jq --arg path "$VAULT_ABS" --arg ts "$TS" '.vaults["2ndbrain"] = {"path": $path, "ts": ($ts | tonumber)}' "$OBSIDIAN_CONFIG_DIR/obsidian.json" > "$OBSIDIAN_CONFIG_DIR/obsidian.json.tmp" && mv "$OBSIDIAN_CONFIG_DIR/obsidian.json.tmp" "$OBSIDIAN_CONFIG_DIR/obsidian.json"
            fi
        else
            cat > "$OBSIDIAN_CONFIG_DIR/obsidian.json" << OBSIDIAN_EOF
{"vaults":{"2ndbrain":{"path":"$VAULT_ABS","ts":$TS}}}
OBSIDIAN_EOF
        fi
        success "Vault registered in Obsidian"
    else
        warn "Vault auto-registration is only supported on macOS"
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

    # Test: Obsidian installed
    if [ -d "/Applications/Obsidian.app" ] || [ -d "$HOME/Applications/Obsidian.app" ]; then
        success "TEST: Obsidian is installed"
        TEST_PASS=$((TEST_PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} TEST: Obsidian is not installed"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Test: Vault folders
    for folder in "00-Inbox" "01-Fleeting" "02-Literature" "03-Permanent" "04-MOC" "05-Templates" "06-Assets" "07-Projects"; do
        if [ -d "$VAULT_PATH/$folder" ]; then
            success "TEST: $folder exists"
            TEST_PASS=$((TEST_PASS + 1))
        else
            echo -e "${RED}[FAIL]${NC} TEST: $folder missing"
            TEST_FAIL=$((TEST_FAIL + 1))
        fi
    done

    if [ -f "$VAULT_PATH/CLAUDE.md" ]; then
        success "TEST: CLAUDE.md exists"
        TEST_PASS=$((TEST_PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} TEST: CLAUDE.md missing"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    TEMPLATE_COUNT=$(find "$VAULT_PATH/05-Templates" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$TEMPLATE_COUNT" -ge 4 ]; then
        success "TEST: $TEMPLATE_COUNT templates created"
        TEST_PASS=$((TEST_PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} TEST: Only $TEMPLATE_COUNT templates found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    if [ -f "$VAULT_PATH/sync.sh" ]; then
        success "TEST: sync.sh exists"
        TEST_PASS=$((TEST_PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} TEST: sync.sh missing"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    # Test: Vault registered in Obsidian
    OBSIDIAN_CONFIG_DIR="$HOME/Library/Application Support/obsidian"
    if [ -f "$OBSIDIAN_CONFIG_DIR/obsidian.json" ]; then
        if command -v jq &>/dev/null; then
            if jq -e '.vaults["2ndbrain"]' "$OBSIDIAN_CONFIG_DIR/obsidian.json" &>/dev/null; then
                success "TEST: Vault registered in Obsidian config"
                TEST_PASS=$((TEST_PASS + 1))
            else
                echo -e "${RED}[FAIL]${NC} TEST: Vault not found in Obsidian config"
                TEST_FAIL=$((TEST_FAIL + 1))
            fi
        else
            if grep -q "2ndbrain" "$OBSIDIAN_CONFIG_DIR/obsidian.json" 2>/dev/null; then
                success "TEST: Vault registered in Obsidian config"
                TEST_PASS=$((TEST_PASS + 1))
            else
                echo -e "${RED}[FAIL]${NC} TEST: Vault not found in Obsidian config"
                TEST_FAIL=$((TEST_FAIL + 1))
            fi
        fi
    else
        echo -e "${RED}[FAIL]${NC} TEST: Obsidian config file not found"
        TEST_FAIL=$((TEST_FAIL + 1))
    fi

    echo ""
    if [ "$TEST_FAIL" -eq 0 ]; then
        echo -e "  ${GREEN}All $TEST_PASS tests passed.${NC}"
    else
        echo -e "  ${GREEN}$TEST_PASS passed${NC}, ${RED}$TEST_FAIL failed${NC}."
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
    echo -e "${GREEN}  Step 7a Complete — Vault Structure Ready${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Vault: $VAULT_PATH"
    echo ""
    echo "  Created:"
    echo "    Obsidian installed (or verified)"
    echo "    8 Zettelkasten folders"
    echo "    5 note templates"
    echo "    CLAUDE.md (vault instructions for Claude)"
    echo "    sync.sh (automation script)"
    echo "    Vault registered in Obsidian config"
    echo ""
    echo "  Next: Run Step 7b to import your Claude history."
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    install_obsidian
    find_vault
    create_folders
    create_templates
    create_claude_md
    create_sync_script
    register_vault_in_obsidian
    run_self_test
    print_summary
}

main "$@"
