#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# Bonus — Ghostty Terminal
# Installs Ghostty and configures it with a polished, fully-featured setup.
# GPU-accelerated, customizable, clickable links, tabbed interface.
# Usage: curl -fsSL <hosted-url>/bonus-ghostty/bonus-ghostty.sh | bash
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
# Detect OS
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin)       OS="mac" ;;
        Linux)        OS="linux" ;;
        MINGW*|MSYS*|CYGWIN*) fail "Windows is not supported." ;;
        *)            fail "Unsupported OS: $(uname -s)" ;;
    esac
    info "Detected OS: $OS"
}

# -----------------------------------------------------------------------------
# Install Ghostty
# -----------------------------------------------------------------------------
install_ghostty() {
    if [ "$OS" = "mac" ]; then
        # Check if Ghostty.app already exists
        if [ -d "/Applications/Ghostty.app" ]; then
            success "Ghostty already installed"
            return
        fi

        if ! command -v brew &>/dev/null; then
            fail "Homebrew not found. Run Step 1 first."
        fi

        info "Installing Ghostty via Homebrew..."
        brew install --cask ghostty || fail "Ghostty installation failed"
        success "Ghostty installed"
    else
        # Linux — Ghostty is available via package managers on some distros
        if command -v ghostty &>/dev/null; then
            success "Ghostty already installed"
            return
        fi

        info "Installing Ghostty..."
        if command -v apt-get &>/dev/null; then
            # Ubuntu/Debian — Ghostty may need a PPA or manual install
            warn "Ghostty may not be in default repos. Trying snap..."
            sudo snap install ghostty 2>/dev/null || {
                warn "Snap install failed. Visit https://ghostty.org/download for Linux install instructions."
                warn "Skipping Ghostty install — continuing with config setup."
                return
            }
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y ghostty 2>/dev/null || {
                warn "dnf install failed. Visit https://ghostty.org/download for Linux install instructions."
                warn "Skipping Ghostty install — continuing with config setup."
                return
            }
        else
            warn "Could not detect package manager. Visit https://ghostty.org/download for install instructions."
            return
        fi
        success "Ghostty installed"
    fi
}

# -----------------------------------------------------------------------------
# Install JetBrains Mono font (if not present)
# -----------------------------------------------------------------------------
install_font() {
    if [ "$OS" = "mac" ]; then
        # Check if JetBrains Mono is already installed
        if fc-list 2>/dev/null | grep -qi "JetBrains Mono" || [ -f "$HOME/Library/Fonts/JetBrainsMono-Regular.ttf" ] || ls /Library/Fonts/JetBrainsMono* &>/dev/null 2>&1; then
            success "JetBrains Mono font already installed"
            return
        fi

        info "Installing JetBrains Mono font..."
        brew install --cask font-jetbrains-mono 2>/dev/null || {
            # Fallback: try the Homebrew fonts tap
            brew tap homebrew/cask-fonts 2>/dev/null
            brew install --cask font-jetbrains-mono 2>/dev/null || {
                warn "Could not auto-install JetBrains Mono. Download it from https://www.jetbrains.com/mono/"
                warn "Ghostty will fall back to a default monospace font."
                return
            }
        }
        success "JetBrains Mono font installed"
    else
        if fc-list 2>/dev/null | grep -qi "JetBrains Mono"; then
            success "JetBrains Mono font already installed"
            return
        fi

        info "Installing JetBrains Mono font..."
        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"
        TMPDIR_FONT=$(mktemp -d)
        curl -fsSL "https://github.com/JetBrains/JetBrainsMono/releases/latest/download/JetBrainsMono-2.304.zip" -o "$TMPDIR_FONT/jbmono.zip" 2>/dev/null
        if [ -f "$TMPDIR_FONT/jbmono.zip" ]; then
            unzip -q "$TMPDIR_FONT/jbmono.zip" -d "$TMPDIR_FONT/jbmono" 2>/dev/null
            find "$TMPDIR_FONT/jbmono" -name "*.ttf" -exec cp {} "$FONT_DIR/" \;
            fc-cache -f "$FONT_DIR" 2>/dev/null
            success "JetBrains Mono font installed"
        else
            warn "Could not download JetBrains Mono. Download it from https://www.jetbrains.com/mono/"
        fi
        rm -rf "$TMPDIR_FONT"
    fi
}

# -----------------------------------------------------------------------------
# Configure Ghostty
# -----------------------------------------------------------------------------
configure_ghostty() {
    if [ "$OS" = "mac" ]; then
        CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
    else
        CONFIG_DIR="$HOME/.config/ghostty"
    fi

    CONFIG_FILE="$CONFIG_DIR/config"

    mkdir -p "$CONFIG_DIR"

    if [ -f "$CONFIG_FILE" ]; then
        if grep -q "CLI Maxxing" "$CONFIG_FILE" 2>/dev/null; then
            success "Ghostty config already configured — skipping"
            return
        fi
        info "Ghostty config already exists — backing up to config.backup"
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    fi

    info "Writing Ghostty config..."

    cat > "$CONFIG_FILE" << 'CONFIG_EOF'
# =============================================================================
# Ghostty Configuration — CLI Maxxing
# GPU-accelerated terminal with polished defaults
# =============================================================================

# Font
font-family = JetBrains Mono
font-size = 14

# Window — tabbed interface with native macOS traffic lights (red/yellow/green)
window-padding-x = 8
window-padding-y = 8
window-decoration = true
macos-titlebar-style = tabs

# Links — Cmd+Click to open URLs, file paths, and more
link-url = true

# Warp Dark Theme — Core
background = 000000
foreground = ffffff
cursor-color = 00c2ff
selection-background = 264f78
selection-foreground = ffffff

# Warp Dark Theme — Normal Colors (0-7)
palette = 0=#616161
palette = 1=#ff8272
palette = 2=#b4fa72
palette = 3=#fefdc2
palette = 4=#a5d5fe
palette = 5=#ff8ffd
palette = 6=#d0d1fe
palette = 7=#f1f1f1

# Warp Dark Theme — Bright Colors (8-15)
palette = 8=#8e8e8e
palette = 9=#ffc4bd
palette = 10=#d6fcb9
palette = 11=#fefdd5
palette = 12=#c1e3fe
palette = 13=#ffb1fe
palette = 14=#e5e6fe
palette = 15=#feffff
CONFIG_EOF

    success "Ghostty config written to $CONFIG_FILE"
}

# -----------------------------------------------------------------------------
# Set default file opener for Cmd+Click (macOS — TextEdit for text files)
# -----------------------------------------------------------------------------
configure_link_opener() {
    if [ "$OS" != "mac" ]; then
        return
    fi

    # Ghostty uses macOS default handlers for Cmd+Click.
    # URLs open in your default browser. File paths open in the default app
    # for that file type. To make text files open in TextEdit (instead of
    # Xcode or another editor), we set TextEdit as the default for common
    # text file types using duti (if available) or tell the user how.

    if command -v duti &>/dev/null; then
        info "Setting TextEdit as default for text files (for Cmd+Click)..."
        duti -s com.apple.TextEdit .txt all 2>/dev/null
        duti -s com.apple.TextEdit .md all 2>/dev/null
        duti -s com.apple.TextEdit .log all 2>/dev/null
        duti -s com.apple.TextEdit .json all 2>/dev/null
        duti -s com.apple.TextEdit .yaml all 2>/dev/null
        duti -s com.apple.TextEdit .yml all 2>/dev/null
        duti -s com.apple.TextEdit .sh all 2>/dev/null
        duti -s com.apple.TextEdit .conf all 2>/dev/null
        duti -s com.apple.TextEdit .cfg all 2>/dev/null
        success "TextEdit set as default for text/config files"
    else
        info "Installing duti for file association management..."
        brew install duti 2>/dev/null && {
            duti -s com.apple.TextEdit .txt all 2>/dev/null
            duti -s com.apple.TextEdit .md all 2>/dev/null
            duti -s com.apple.TextEdit .log all 2>/dev/null
            duti -s com.apple.TextEdit .json all 2>/dev/null
            duti -s com.apple.TextEdit .yaml all 2>/dev/null
            duti -s com.apple.TextEdit .yml all 2>/dev/null
            duti -s com.apple.TextEdit .sh all 2>/dev/null
            duti -s com.apple.TextEdit .conf all 2>/dev/null
            duti -s com.apple.TextEdit .cfg all 2>/dev/null
            success "TextEdit set as default for text/config files"
        } || {
            warn "Could not install duti. Cmd+Click will still work — files will open in whatever app macOS currently defaults to."
            warn "To change defaults manually: right-click a file > Get Info > Open With > TextEdit > Change All."
        }
    fi
}

# -----------------------------------------------------------------------------
# Window tiling commands (g2, g4) — macOS only
# -----------------------------------------------------------------------------
install_window_tiling() {
    if [ "$OS" != "mac" ]; then
        info "Skipping window tiling commands (macOS only)"
        return
    fi

    SHELL_RC="$HOME/.zshrc"
    case "${SHELL:-/bin/bash}" in
        */bash) SHELL_RC="$HOME/.bashrc" ;;
    esac

    if grep -q 'g2()' "$SHELL_RC" 2>/dev/null; then
        success "Window tiling commands already installed (g2, g4)"
        return
    fi

    info "Installing window tiling commands (g2, g4)..."
    cat >> "$SHELL_RC" << 'TILING_EOF'

# Ghostty window tiling — g2 (split), g4 (quad)
g2() {
  osascript <<'APPLESCRIPT'
use framework "AppKit"
tell application "Ghostty" to activate
delay 0.3
tell application "System Events" to tell process "Ghostty"
  set winCount to count of windows
  repeat (2 - winCount) times
    keystroke "n" using command down
    delay 0.5
  end repeat
  delay 0.3
  set wins to every window
  if (count of wins) < 2 then return
  set mainScreen to current application's NSScreen's mainScreen()
  set screenFrame to mainScreen's frame()
  set visFrame to mainScreen's visibleFrame()
  set fullH to (item 2 of item 2 of screenFrame) as integer
  set visX to (item 1 of item 1 of visFrame) as integer
  set visYBottom to (item 2 of item 1 of visFrame) as integer
  set visW to (item 1 of item 2 of visFrame) as integer
  set visH to (item 2 of item 2 of visFrame) as integer
  set topY to fullH - visYBottom - visH
  set halfW to visW div 2
  set size of item 2 of wins to {halfW, visH}
  set position of item 2 of wins to {visX, topY}
  delay 0.1
  set size of item 1 of wins to {halfW, visH}
  set position of item 1 of wins to {visX + halfW, topY}
  delay 0.1
  perform action "AXRaise" of item 2 of wins
end tell
APPLESCRIPT
}

g4() {
  osascript <<'APPLESCRIPT'
use framework "AppKit"
tell application "Ghostty" to activate
delay 0.3
tell application "System Events" to tell process "Ghostty"
  set winCount to count of windows
  repeat (4 - winCount) times
    keystroke "n" using command down
    delay 0.5
  end repeat
  delay 0.3
  set wins to every window
  if (count of wins) < 4 then return
  set mainScreen to current application's NSScreen's mainScreen()
  set screenFrame to mainScreen's frame()
  set visFrame to mainScreen's visibleFrame()
  set fullH to (item 2 of item 2 of screenFrame) as integer
  set visX to (item 1 of item 1 of visFrame) as integer
  set visYBottom to (item 2 of item 1 of visFrame) as integer
  set visW to (item 1 of item 2 of visFrame) as integer
  set visH to (item 2 of item 2 of visFrame) as integer
  set topY to fullH - visYBottom - visH
  set halfW to visW div 2
  set halfH to visH div 2
  set size of item 1 of wins to {halfW, halfH}
  set position of item 1 of wins to {visX, topY}
  delay 0.1
  set size of item 2 of wins to {halfW, halfH}
  set position of item 2 of wins to {visX + halfW, topY}
  delay 0.1
  set size of item 3 of wins to {halfW, halfH}
  set position of item 3 of wins to {visX, topY + halfH}
  delay 0.1
  set size of item 4 of wins to {halfW, halfH}
  set position of item 4 of wins to {visX + halfW, topY + halfH}
end tell
APPLESCRIPT
}
TILING_EOF
    success "Window tiling commands installed (g2, g4)"
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
print_summary() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  Ghostty Terminal — Installed & Configured${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  What you got:"
    echo "    GPU-accelerated rendering (Metal on Mac, OpenGL on Linux)"
    echo "    JetBrains Mono font, size 14"
    echo "    Tabbed interface with native title bar"
    echo "    macOS traffic light buttons (red, yellow, green)"
    echo "    Warp Dark color theme"
    echo "    Cmd+Click to open URLs in your browser"
    echo "    Cmd+Click to open file paths (text files open in TextEdit)"
    if [ "$OS" = "mac" ]; then
        echo "    g2 — tile 2 Ghostty windows side by side"
        echo "    g4 — tile 4 Ghostty windows in a quad grid"
    fi
    echo ""
    echo "  How to use it:"
    echo "    Open Ghostty from Spotlight (Cmd+Space, type Ghostty)"
    echo "    Cmd+T to open a new tab"
    echo "    Cmd+Click any URL or file path to open it"
    echo "    Shell aliases from later steps (cskip, cbrain, etc.) work here automatically"
    echo ""
    if [ "$OS" = "mac" ]; then
        echo "  Config location:"
        echo "    ~/Library/Application Support/com.mitchellh.ghostty/config"
    else
        echo "  Config location:"
        echo "    ~/.config/ghostty/config"
    fi
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Bonus — Ghostty Terminal${NC}"
    echo -e "${BLUE}  GPU-accelerated • Customizable • Clickable links${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    detect_os
    install_ghostty
    install_font
    configure_ghostty
    configure_link_opener
    install_window_tiling
    print_summary
}

main "$@"
