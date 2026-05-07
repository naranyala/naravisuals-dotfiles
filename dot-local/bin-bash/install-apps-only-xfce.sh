#!/usr/bin/env bash
# xfce-apps-installer.sh
# Installer for XFCE-related apps on Arch Linux without full desktop environment
# Always installs the full enriched set of XFCE apps
# Includes error handling and rollback

set -euo pipefail

# --- CONFIG ---
APPS=(
    # Core utilities
    thunar              # File manager
    thunar-volman       # Removable device manager
    xfce4-terminal      # Terminal emulator
    xfce4-screenshooter # Screenshot tool
    xfce4-taskmanager   # Task manager
    xfce4-notifyd       # Notification daemon
    xfce4-power-manager # Power management
    mousepad            # Lightweight text editor

    # Enriched extras
    xfce4-dict              # Dictionary tool
    xfce4-diskperf          # Disk performance monitor
    xfce4-sensors-plugin    # Hardware sensors
    xfce4-weather-plugin    # Weather panel plugin
    xfce4-clipman-plugin    # Clipboard manager
    xfce4-timer-plugin      # Countdown timer
    xfce4-whiskermenu-plugin # Advanced application menu
    xfce4-pulseaudio-plugin  # Audio control
    xfce4-panel-profiles     # Panel layout manager
)

# --- FUNCTIONS ---
rollback() {
    echo "⚠️ Rolling back installation..."
    sudo pacman -Rns --noconfirm "${APPS[@]}" || true
    echo "Rollback complete."
}

install_apps() {
    echo "Installing full XFCE apps set..."
    if ! sudo pacman -S --needed --noconfirm "${APPS[@]}"; then
        rollback
        exit 1
    fi
    echo "✅ Installation successful."
}

# --- MAIN ---
install_apps

