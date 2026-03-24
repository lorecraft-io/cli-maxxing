#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Step 5c — Import existing notes into your vault
# Handles Apple Notes, OneNote, Notion, Evernote, and raw files
# Converts docx/pptx/xlsx/html to markdown via Pandoc
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
echo -e "${BLUE}  Step 5c — Import Your Existing Notes${NC}"
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

# Check for Pandoc
if command -v pandoc &>/dev/null; then
    success "Pandoc available for file conversion"
else
    warn "Pandoc not found. Run Step 2 first for file conversion support."
fi

# Check for xlsx2csv
if python3 -c "import xlsx2csv" &>/dev/null 2>&1; then
    success "xlsx2csv available for spreadsheet conversion"
else
    warn "xlsx2csv not found. Spreadsheet conversion may be limited."
fi

# Look for exported notes in common locations
echo ""
info "Looking for exported notes..."
NOTES_FOUND=0

for search_dir in "$HOME/Desktop" "$HOME/Downloads" "$HOME/Documents"; do
    # Count relevant files
    COUNT=$(find "$search_dir" -maxdepth 2 \( \
        -name "*.md" -o -name "*.txt" -o -name "*.docx" -o -name "*.pptx" \
        -o -name "*.xlsx" -o -name "*.html" -o -name "*.htm" -o -name "*.rtf" \
        -o -name "*.enex" -o -name "*.json" \
    \) 2>/dev/null | wc -l | tr -d ' ')
    if [ "$COUNT" -gt 0 ]; then
        info "Found $COUNT potential note files in $search_dir"
        NOTES_FOUND=$((NOTES_FOUND + COUNT))
    fi
done

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Step 5c — Ready for Claude to Import${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Vault: $VAULT_PATH"
echo "  Potential files found: $NOTES_FOUND"
echo ""
echo "  Tell Claude where your exported notes are. For example:"
echo ""
echo "  'Import my Apple Notes export from ~/Desktop/apple-notes-export"
echo "   into my vault at $VAULT_PATH. Convert everything to markdown,"
echo "   validate the files, and move them into 00-Inbox for processing.'"
echo ""
echo "  Claude will:"
echo "  - Convert docx, pptx, xlsx, html files to markdown using Pandoc"
echo "  - Validate every file (catch corrupt or empty files)"
echo "  - Move everything into your Inbox"
echo "  - Ask you how you want things organized"
echo ""
echo "  Supported formats: .md .txt .docx .pptx .xlsx .html .rtf .enex"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
