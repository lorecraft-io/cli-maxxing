#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 5b — Import Claude conversation history into your vault
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
echo -e "${BLUE}  Step 5b — Import Claude History${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Find vault
VAULT_PATH="${VAULT_PATH:-}"
if [ -z "$VAULT_PATH" ]; then
    for candidate in \
        "$HOME/Desktop/Brain" \
        "$HOME/Desktop/Second-Brain" \
        "$HOME/Desktop/Vault" \
        "$HOME/Documents/Brain" \
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
    fail "Could not find your vault. Run Step 5a first, or set VAULT_PATH manually."
fi

success "Vault found at: $VAULT_PATH"

# Find Claude data export
echo ""
echo "  Looking for Claude data export..."
CLAUDE_ZIP=""
for candidate in \
    "$HOME/Desktop/claude"*.zip \
    "$HOME/Downloads/claude"*.zip \
    "$HOME/Desktop/Claude"*.zip \
    "$HOME/Downloads/Claude"*.zip; do
    if [ -f "$candidate" ] 2>/dev/null; then
        CLAUDE_ZIP="$candidate"
        break
    fi
done

if [ -n "$CLAUDE_ZIP" ]; then
    success "Found Claude export: $CLAUDE_ZIP"
else
    warn "Could not find a Claude data export zip file."
    echo ""
    echo "  If you haven't downloaded it yet:"
    echo "  1. Go to claude.ai in your browser"
    echo "  2. Profile icon (bottom left) → Settings → Privacy"
    echo "  3. Download my data → All time → Request download"
    echo "  4. Check your email for the download link"
    echo "  5. Save the zip to your Desktop"
    echo ""
    echo "  Then tell Claude where the zip file is."
    echo ""
    echo "  To set it manually: export CLAUDE_ZIP=~/Desktop/your-file.zip"
fi

# Create import staging area
STAGING="$VAULT_PATH/.import-staging"
mkdir -p "$STAGING"

# If we have a zip, extract it
if [ -n "$CLAUDE_ZIP" ] && [ -f "$CLAUDE_ZIP" ]; then
    info "Extracting Claude data..."
    unzip -qo "$CLAUDE_ZIP" -d "$STAGING" 2>/dev/null
    success "Extracted to staging area"

    # Count what we found
    CONV_COUNT=$(find "$STAGING" -name "*.json" -o -name "*.txt" -o -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    info "Found $CONV_COUNT files to process"
fi

# Create projects directory structure
info "Setting up project folders..."
mkdir -p "$VAULT_PATH/07-Projects"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Step 5b — Ready for Claude to Parse${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Vault: $VAULT_PATH"
if [ -n "$CLAUDE_ZIP" ]; then
echo "  Claude data: extracted to $STAGING"
fi
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
