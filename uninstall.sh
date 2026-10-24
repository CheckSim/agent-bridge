#!/usr/bin/env bash
# ==============================================================================
# agent-bridge Uninstaller
# ==============================================================================

set -e

INSTALL_BIN_DIR="$HOME/.local/bin"
BIN_TARGET="$INSTALL_BIN_DIR/agent-bridge"

echo "Uninstalling agent-bridge..."

# Remove binary
if [ -f "$BIN_TARGET" ]; then
    rm -f "$BIN_TARGET"
    echo "✓ Removed $BIN_TARGET"
fi

# Remove skills
rm -rf "$HOME/.gemini/antigravity-cli/skills/cross-agent-memory" 2>/dev/null || true
rm -rf "$HOME/.claude/skills/cross-agent-memory" 2>/dev/null || true
echo "✓ Removed installed skills"

# Clean shell config
clean_shell() {
    local cfg="$1"
    if [ -f "$cfg" ] && grep -q "# --- agent-bridge shell integration ---" "$cfg"; then
        sed -i '' '/# --- agent-bridge shell integration ---/,/# --- end agent-bridge ---/d' "$cfg"
        echo "✓ Cleaned $cfg"
    fi
}

clean_shell "$HOME/.zshrc"
clean_shell "$HOME/.bashrc"

echo "✓ Uninstallation complete. Please restart your terminal."
