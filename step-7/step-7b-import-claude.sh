#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 7b — Import Claude conversation history into your vault
# Parses Claude data export into project folders and notes
# Run inside a cskip session
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

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Step 7b — Import Claude History${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# =============================================================================
# 1. Find the Obsidian vault
# =============================================================================
VAULT_PATH="${VAULT_PATH:-}"
if [ -z "$VAULT_PATH" ]; then
    for candidate in \
        "$HOME/Desktop/2ndBrain" \
        "$HOME/Desktop/Second-Brain" \
        "$HOME/Desktop/Vault" \
        "$HOME/Documents/2ndBrain" \
        "$HOME/Documents/Second-Brain"; do
        if [ -d "$candidate/00-Inbox" ]; then
            VAULT_PATH="$candidate"
            break
        fi
    done
    # Broader search
    if [ -z "$VAULT_PATH" ]; then
        FOUND=$(find "$HOME/Desktop" "$HOME/Documents" -maxdepth 3 -name "00-Inbox" -type d 2>/dev/null | head -1)
        if [ -n "$FOUND" ]; then
            VAULT_PATH="$(dirname "$FOUND")"
        fi
    fi
fi

if [ -z "$VAULT_PATH" ] || [ ! -d "$VAULT_PATH/00-Inbox" ]; then
    fail "Could not find your vault. Run Step 7a first, or set VAULT_PATH manually."
fi

success "Vault found at: $VAULT_PATH"

# =============================================================================
# 2. Find the Claude data export zip
# =============================================================================
echo ""
info "Looking for Claude data export..."

# --- FIX A: Proper zip detection with CLAUDE_ZIP env var priority ----------
find_claude_zip() {
  # 1. Check if CLAUDE_ZIP env var is already set and points to a valid file
  if [ -n "${CLAUDE_ZIP:-}" ] && [ -f "$CLAUDE_ZIP" ]; then
    echo "$CLAUDE_ZIP"
    return 0
  fi

  # 2. Scan common download locations for Claude data export zips
  #    Claude exports use the pattern: data-<uuid>-batch-<n>.zip
  local SEARCH_DIRS="$HOME/Downloads $HOME/Desktop $HOME/Documents"
  for dir in $SEARCH_DIRS; do
    if [ -d "$dir" ]; then
      # Match the actual Claude export filename pattern first
      local found
      found=$(find "$dir" -maxdepth 2 -name "data-*-batch-*.zip" -type f 2>/dev/null | sort -r | head -1)
      if [ -n "$found" ]; then
        echo "$found"
        return 0
      fi
      # Fall back to any zip with "claude" in the name
      found=$(find "$dir" -maxdepth 2 -iname "*claude*" -name "*.zip" -type f 2>/dev/null | sort -r | head -1)
      if [ -n "$found" ]; then
        echo "$found"
        return 0
      fi
      # Also check for Anthropic-named exports
      found=$(find "$dir" -maxdepth 2 -iname "*anthropic*" -name "*.zip" -type f 2>/dev/null | sort -r | head -1)
      if [ -n "$found" ]; then
        echo "$found"
        return 0
      fi
    fi
  done

  return 1
}

ZIP_PATH=$(find_claude_zip)
if [ -z "$ZIP_PATH" ]; then
  echo ""
  warn "No Claude data export zip found."
  echo ""
  echo -e "  ${YELLOW}Option 1: Set the path directly${NC}"
  echo "    export CLAUDE_ZIP=/path/to/your/data-export.zip"
  echo "    bash step-7b-import-claude.sh"
  echo ""
  echo -e "  ${YELLOW}Option 2: Place the zip in ~/Downloads/${NC}"
  echo "    Claude exports are named like: data-<uuid>-batch-1.zip"
  echo "    Move it to ~/Downloads/ and rerun this script."
  echo ""
  echo -e "  ${YELLOW}Haven't exported your data yet?${NC}"
  echo "    1. Go to https://claude.ai in your browser"
  echo "    2. Click your profile icon (bottom-left) → Settings → Privacy"
  echo "    3. Click 'Download my data' → 'All time' → 'Request download'"
  echo "    4. Check your email for the download link"
  echo "    5. Save the zip to ~/Downloads/ and rerun this script"
  echo ""
  exit 1
fi
success "Found Claude export: $ZIP_PATH"

# =============================================================================
# 3. Create import staging area and extract
# =============================================================================
STAGING="$VAULT_PATH/.import-staging"
mkdir -p "$STAGING"

info "Extracting Claude data to staging area..."
unzip -qo "$ZIP_PATH" -d "$STAGING" 2>/dev/null
if [ $? -ne 0 ]; then
    fail "Failed to extract $ZIP_PATH — is the zip file valid?"
fi
success "Extracted to: $STAGING"

# Count what we found
CONV_COUNT=$(find "$STAGING" -name "*.json" -o -name "*.txt" -o -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
info "Found $CONV_COUNT files to process"

# =============================================================================
# 4. Create projects directory structure
# =============================================================================
info "Setting up project folders..."
mkdir -p "$VAULT_PATH/07-Projects"

# =============================================================================
# 5. Summary and next steps
# =============================================================================
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Step 7b — Ready for Claude to Parse${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Vault:       $VAULT_PATH"
echo "  Claude data: extracted to $STAGING"
echo "  Files found: $CONV_COUNT"
echo ""
echo "  What to tell Claude next:"
echo ""
echo "  'Parse my Claude data export at $STAGING into my vault"
echo "   at $VAULT_PATH. Create project folders in 07-Projects/"
echo "   based on my Claude Projects. For each project, create an"
echo "   index note with a summary and conversation log links."
echo "   Extract key insights into permanent notes in 03-Permanent/"
echo "   and create bidirectional links between related projects.'"
echo ""
echo "  Claude will ask you about folder names and organization."
echo "  This is the conversational part. Just answer its questions."
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
