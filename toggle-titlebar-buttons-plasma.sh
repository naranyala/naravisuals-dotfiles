#!/usr/bin/env bash
#
# window-buttons-layout.sh
# Manage KDE Plasma window button layouts (left/right).
# Supports presets, backup, and rollback.

set -euo pipefail

CONFIG_FILE="$HOME/.config/kwinrc"
BACKUP_FILE="$CONFIG_FILE.bak.$(date +%s)"

# Reload KWin
reload_kwin() {
    echo "Reloading KWin..."
    qdbus org.kde.KWin /KWin reconfigure || true
}

# Rollback to backup
rollback() {
    if [[ -f "$BACKUP_FILE" ]]; then
        echo "Rolling back to previous configuration..."
        cp "$BACKUP_FILE" "$CONFIG_FILE"
        reload_kwin
        echo "Rollback complete."
    else
        echo "No backup found. Cannot rollback."
    fi
}

# Apply layout
apply_layout() {
    local left="$1"
    local right="$2"

    # Backup only if file exists
    if [[ -f "$CONFIG_FILE" ]]; then
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        echo "Backup saved to $BACKUP_FILE"
    else
        echo "No kwinrc found at $CONFIG_FILE, skipping backup."
    fi

    echo "Applying layout: Left=[$left], Right=[$right]"
    kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft "$left"
    kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight "$right"
    reload_kwin
}

# Presets
preset_kde_default() { apply_layout "" "M,A,X"; }
preset_gnome_style() { apply_layout "X,M,A" ""; }
preset_macos_style() { apply_layout "X,M,A" ""; } # tweak order if desired
preset_all_left()   { apply_layout "X,M,A,S,K,B,F,H" ""; }

# Warn if running as root
if [[ "$EUID" -eq 0 ]]; then
    echo "⚠️ Warning: You are running as root. Plasma configs usually live in your normal user’s home (~/.config/kwinrc)."
fi

# Main
case "${1:-}" in
    kde)    preset_kde_default ;;
    gnome)  preset_gnome_style ;;
    macos)  preset_macos_style ;;
    left)   preset_all_left ;;
    rollback) rollback ;;
    *)
        echo "Usage: $0 [kde|gnome|macos|left|rollback]"
        echo "Presets:"
        echo "  kde      → KDE default (buttons on right)"
        echo "  gnome    → GNOME-style (close,minimize,maximize on left)"
        echo "  macos    → macOS-style (similar to GNOME)"
        echo "  left     → All buttons on left"
        echo "  rollback → Restore last backup"
        ;;
esac

