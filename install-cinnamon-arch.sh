#!/usr/bin/env bash
# cinnamon-install.sh
# Robust installer for Cinnamon Desktop on Arch Linux
# Features: error handling, rollback, presets, and DM switching

set -euo pipefail

# === CONFIGURATION ===
DM="lightdm"          # Options: lightdm, gdm, sddm
PRESET="enriched"     # Options: minimal, enriched

# === FUNCTIONS ===
error_exit() {
    echo "❌ Error: $1" >&2
    rollback
    exit 1
}

rollback() {
    echo "↩️ Rolling back installation..."
    sudo pacman -Rns --noconfirm cinnamon cinnamon-translations || true
    case "$DM" in
        lightdm) sudo pacman -Rns --noconfirm lightdm lightdm-gtk-greeter || true ;;
        gdm)     sudo pacman -Rns --noconfirm gdm || true ;;
        sddm)    sudo pacman -Rns --noconfirm sddm || true ;;
    esac
}

install_base() {
    echo "📦 Installing Cinnamon base..."
    sudo pacman -Syu --noconfirm cinnamon cinnamon-translations || error_exit "Failed to install Cinnamon"
}

install_dm() {
    echo "📦 Installing Display Manager: $DM..."
    case "$DM" in
        lightdm)
            sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter || error_exit "Failed to install LightDM"
            ;;
        gdm)
            sudo pacman -S --noconfirm gdm || error_exit "Failed to install GDM"
            ;;
        sddm)
            sudo pacman -S --noconfirm sddm || error_exit "Failed to install SDDM"
            ;;
        *)
            error_exit "Unknown display manager: $DM"
            ;;
    esac
    switch_dm
}

switch_dm() {
    local current_dm
    if [[ -L /etc/systemd/system/display-manager.service ]]; then
        current_dm=$(readlink -f /etc/systemd/system/display-manager.service | awk -F'/' '{print $NF}')
        echo "🔍 Current display manager: $current_dm"
    else
        current_dm="none"
        echo "ℹ️ No display manager currently enabled."
    fi

    if [[ "$current_dm" == "$DM.service" ]]; then
        echo "✅ $DM is already the active display manager."
        return 0
    fi

    # Disable current DM if different
    if [[ "$current_dm" != "none" ]]; then
        echo "⏹ Disabling $current_dm..."
        sudo systemctl disable "$current_dm" || echo "⚠️ Failed to disable $current_dm, continuing..."
    fi

    # Enable new DM
    echo "🚀 Enabling $DM..."
    if ! sudo systemctl enable "$DM.service"; then
        echo "❌ Failed to enable $DM. Rolling back..."
        [[ "$current_dm" != "none" ]] && sudo systemctl enable "$current_dm"
        exit 1
    fi

    echo "✅ Switched to $DM successfully."
}

install_preset() {
    if [[ "$PRESET" == "minimal" ]]; then
        echo "🌱 Minimal preset: Cinnamon only."
    elif [[ "$PRESET" == "enriched" ]]; then
        echo "🌳 Enriched preset: Adding extras..."
        sudo pacman -S --noconfirm gnome-terminal nemo xed || error_exit "Failed to install extras"
    else
        error_exit "Unknown preset: $PRESET"
    fi
}

# === MAIN ===
echo "🚀 Starting Cinnamon installation..."
install_base
install_dm
install_preset
echo "✅ Cinnamon installation complete. Reboot to start your new desktop!"

