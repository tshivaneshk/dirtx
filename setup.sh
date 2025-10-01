#!/bin/bash

# ===============================================
# dirtx Setup Script
# ===============================================
# MIT License
# Copyright (c) 2025 T Shivanesh Kumar
# ===============================================

RED="\033[0;31m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Installation directory (default: /usr/local/bin)
INSTALL_DIR="/usr/local/bin"

echo -e "${CYAN}dirtx Setup - Installing globally...${RESET}"

# Check for sudo/root permission
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}Warning: You are not running as root. You may need to enter your password for sudo.${RESET}"
fi

# Copy dirtx.sh to INSTALL_DIR
echo -e "${CYAN}Copying dirtx.sh to $INSTALL_DIR...${RESET}"
sudo cp dirtx.sh "$INSTALL_DIR/dirtx"
sudo chmod +x "$INSTALL_DIR/dirtx"

# Verify installation
if command -v dirtx >/dev/null 2>&1; then
    echo -e "${GREEN}dirtx installed successfully!${RESET}"
    echo -e "${CYAN}You can now run 'dirtx' from any directory.${RESET}"
else
    echo -e "${RED}Installation failed. Check permissions and try again.${RESET}"
    exit 1
fi

# Optional: add alias for bash/zsh (if desired)
SHELL_RC=""
if [[ -n "$BASH_VERSION" ]]; then
    SHELL_RC="$HOME/.bashrc"
elif [[ -n "$ZSH_VERSION" ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

if [[ -n "$SHELL_RC" ]]; then
    grep -qxF 'alias dirtx="dirtx"' "$SHELL_RC" || echo 'alias dirtx="dirtx"' >> "$SHELL_RC"
    echo -e "${CYAN}Alias added to $SHELL_RC (reload your shell or run 'source $SHELL_RC')${RESET}"
fi

echo -e "${GREEN}Setup complete! Enjoy using dirtx 🚀${RESET}"
