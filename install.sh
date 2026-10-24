#!/usr/bin/env bash
# ==============================================================================
# agent-bridge Installer
# Seamless Bidirectional Handoff Bridge for AI Coding Agents
# Repository: https://github.com/CheckSim/agent-bridge
# ==============================================================================

set -e

REPO_RAW_URL="https://raw.githubusercontent.com/CheckSim/agent-bridge/main"
INSTALL_BIN_DIR="$HOME/.local/bin"
BIN_TARGET="$INSTALL_BIN_DIR/agent-bridge"

BOLD="\033[1m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${CYAN}"
cat << "EOF"
   ___                    __     ____       _     __           
  / _ | ___ ____ ___  ___/ /_   / __ )____ (_)___/ /__ ____ ___
 / __ |/ _ `/ -_) _ \/ _  / -_)/ _  / __// // _  / _ `/ -_) _ \
/_/ |_|\_, /\__/_//_/\_,_/\__//_____/_/  /_/ \_,_/\_, /\__/_//_/
      /___/                                      /___/         
EOF
echo -e "${RESET}"
echo -e "${BOLD}Installing agent-bridge...${RESET}\n"

# 1. Prerequisite Checks
if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${YELLOW}[!] Python 3 is required but not found. Please install Python 3.8+ and try again.${RESET}"
    exit 1
fi

mkdir -p "$INSTALL_BIN_DIR"

# 2. Install Executable
if [ -f "$(dirname "$0")/bin/agent-bridge" ]; then
    # Local install
    echo "-> Installing binary from local repository..."
    cp "$(dirname "$0")/bin/agent-bridge" "$BIN_TARGET"
else
    # Remote install via curl
    echo "-> Downloading agent-bridge from GitHub..."
    curl -fsSL "$REPO_RAW_URL/bin/agent-bridge" -o "$BIN_TARGET"
fi

chmod +x "$BIN_TARGET"
echo -e "   ${GREEN}✓${RESET} Binary installed at: ${BOLD}$BIN_TARGET${RESET}"

# 3. Install Skills for Antigravity & Claude Code
install_skill() {
    local target_dir="$1"
    local agent_name="$2"
    if [ -d "$target_dir" ]; then
        local skill_dir="$target_dir/skills/cross-agent-memory"
        mkdir -p "$skill_dir"
        if [ -f "$(dirname "$0")/skills/cross-agent-memory/SKILL.md" ]; then
            cp "$(dirname "$0")/skills/cross-agent-memory/SKILL.md" "$skill_dir/SKILL.md"
        else
            curl -fsSL "$REPO_RAW_URL/skills/cross-agent-memory/SKILL.md" -o "$skill_dir/SKILL.md"
        fi
        echo -e "   ${GREEN}✓${RESET} Skill installed for $agent_name ($skill_dir)"
    fi
}

install_skill "$HOME/.gemini/antigravity-cli" "Antigravity CLI"
install_skill "$HOME/.claude" "Claude Code"

# 4. Shell Integration
SHELL_CONFIG=""
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "*/zsh" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
fi

SNIPPET_START="# --- agent-bridge shell integration ---"
SNIPPET_END="# --- end agent-bridge ---"

if [ -n "$SHELL_CONFIG" ]; then
    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$INSTALL_BIN_DIR:"* ]]; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_CONFIG" 2>/dev/null; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
        fi
    fi

    # Check if already present
    if ! grep -q "$SNIPPET_START" "$SHELL_CONFIG" 2>/dev/null; then
        echo "-> Configuring shell helpers in $SHELL_CONFIG..."
        cat << 'EOF' >> "$SHELL_CONFIG"

# --- agent-bridge shell integration ---
agy2claude() {
  "$HOME/.local/bin/agent-bridge" --to-claude "$@"
}
claude2agy() {
  "$HOME/.local/bin/agent-bridge" --to-agy "$@"
}
agent-status() {
  "$HOME/.local/bin/agent-bridge" --status "$@"
}
# --- end agent-bridge ---
EOF
        echo -e "   ${GREEN}✓${RESET} Shell helpers added to $SHELL_CONFIG"
    else
        echo -e "   ${GREEN}✓${RESET} Shell helpers already present in $SHELL_CONFIG"
    fi
fi

echo -e "\n${GREEN}${BOLD}✓ Installation complete!${RESET}"
echo -e "\n${BOLD}Quick Start:${RESET}"
echo -e "  * Restart your shell or run: ${CYAN}source $SHELL_CONFIG${RESET}"
echo -e "  * Check status in any repo:   ${CYAN}agent-status${RESET}"
echo -e "  * Handoff Antigravity -> Claude: ${CYAN}agy2claude${RESET}"
echo -e "  * Handoff Claude -> Antigravity: ${CYAN}claude2agy${RESET}"
echo -e "\nEnjoy seamless cross-agent coding!"
