#!/usr/bin/env bash
# c2danger installer — adds c2danger command to ~/.local/bin

install_c2danger() {
  local BIN_DIR="$HOME/.local/bin"
  mkdir -p "$BIN_DIR"

  cat > "$BIN_DIR/c2danger" << 'EOF'
#!/usr/bin/env bash
# c2danger — Launch Claude Code in 2ndBrain Obsidian vault with full permissions
VAULT="$HOME/Desktop/2ndBrain"
if [ ! -d "$VAULT" ]; then
  echo "Error: 2ndBrain vault not found at $VAULT"
  exit 1
fi
cd "$VAULT" && exec claude --dangerously-skip-permissions "$@"
EOF

  chmod +x "$BIN_DIR/c2danger"

  # Ensure ~/.local/bin is in PATH
  local SHELL_RC="$HOME/.zshrc"
  [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.bashrc"

  if ! grep -q '.local/bin' "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
  fi

  echo "[OK] c2danger installed at $BIN_DIR/c2danger"
}

install_c2danger
