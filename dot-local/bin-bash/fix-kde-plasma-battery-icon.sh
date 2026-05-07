
#!/usr/bin/env bash

set -euo pipefail

### CONFIG ###
CONFIG_FILE="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP_FILE="$CONFIG_FILE.bak.$(date +%s)"
PLASMA_RESTART_CMD="kquitapp5 plasmashell && kstart5 plasmashell"

### FUNCTIONS ###

log() { echo -e "\e[1;32m[INFO]\e[0m $*"; }
warn() { echo -e "\e[1;33m[WARN]\e[0m $*"; }
error() { echo -e "\e[1;31m[ERROR]\e[0m $*"; }

check_battery() {
    if upower -e | grep -q "battery"; then
        log "Battery detected via upower."
        return 0
    else
        warn "No battery detected. Is this a desktop or VM?"
        return 1
    fi
}

restart_plasma() {
    log "Restarting Plasma shell..."
    eval "$PLASMA_RESTART_CMD"
}

backup_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        log "Backed up Plasma config to $BACKUP_FILE"
    else
        warn "Plasma config file not found. Skipping backup."
    fi
}

reset_tray_config() {
    log "Resetting system tray config (may reset panel layout)..."
    rm -f "$CONFIG_FILE"
    restart_plasma
    log "Plasma restarted. Reconfigure your panel if needed."
}

show_menu() {
    echo -e "\nChoose an action:"
    echo "1) Restart Plasma shell"
    echo "2) Backup and reset tray config"
    echo "3) Check battery detection"
    echo "4) Exit"
    read -rp "Enter choice [1-4]: " choice
    case "$choice" in
        1) restart_plasma ;;
        2) backup_config && reset_tray_config ;;
        3) check_battery ;;
        4) log "Exiting." ;;
        *) error "Invalid choice." ;;
    esac
}

### MAIN ###
log "=== KDE Battery Indicator Fix ==="
check_battery || warn "Battery not detected. Widget may not appear."
show_menu
