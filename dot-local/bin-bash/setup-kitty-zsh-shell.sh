#!/usr/bin/env bash
#
# setup-kitty-zsh.sh
# One-shot script to install zsh, set it as default shell,
# and configure Kitty to always launch into zsh.
#
# Safe, auditable, and reversible.

set -euo pipefail

# === CONFIG ===
KITTY_CONF_DIR="${HOME}/.config/kitty"
KITTY_CONF_FILE="${KITTY_CONF_DIR}/kitty.conf"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"
ZSH_PATH="$(command -v zsh || true)"

# === FUNCTIONS ===

install_zsh() {
    echo "[*] Checking for zsh..."
    if [[ -z "$ZSH_PATH" ]]; then
        echo "[*] zsh not found, installing..."
        if command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y zsh
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y zsh
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -Sy --noconfirm zsh
        else
            echo "[!] Unsupported package manager. Install zsh manually."
            exit 1
        fi
        ZSH_PATH="$(command -v zsh)"
    else
        echo "[*] zsh already installed at $ZSH_PATH"
    fi
}

set_default_shell() {
    echo "[*] Setting zsh as default shell for user $USER..."
    if [[ "$SHELL" != "$ZSH_PATH" ]]; then
        chsh -s "$ZSH_PATH"
        echo "[*] Default shell changed. You may need to log out and back in."
    else
        echo "[*] zsh is already your default shell."
    fi
}

configure_kitty() {
    echo "[*] Configuring Kitty to use zsh..."
    mkdir -p "$KITTY_CONF_DIR"

    if [[ -f "$KITTY_CONF_FILE" ]]; then
        cp "$KITTY_CONF_FILE" "$KITTY_CONF_FILE$BACKUP_SUFFIX"
        echo "[*] Backed up existing kitty.conf to $KITTY_CONF_FILE$BACKUP_SUFFIX"
    fi

    # Append or replace shell directive
    if grep -q "^shell " "$KITTY_CONF_FILE" 2>/dev/null; then
        sed -i "s|^shell .*|shell $ZSH_PATH|" "$KITTY_CONF_FILE"
    else
        echo "shell $ZSH_PATH" >> "$KITTY_CONF_FILE"
    fi

    # Enable shell integration
    if ! grep -q "^shell_integration enabled" "$KITTY_CONF_FILE" 2>/dev/null; then
        echo "shell_integration enabled" >> "$KITTY_CONF_FILE"
    fi

    echo "[*] Kitty configured to use zsh."
}

# === MAIN ===
install_zsh
set_default_shell
configure_kitty

echo "[✓] Setup complete. Restart Kitty and log out/in to fully apply."

