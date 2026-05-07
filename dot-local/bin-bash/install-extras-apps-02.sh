#!/bin/bash
set -e

# Constants
LOG_FILE="/var/log/lightweight_extras_install.log"
DISTRO_CHECK=$(grep -Ei 'debian|buntu' /etc/os-release 2>/dev/null || true)
MULTIMEDIA_PACKAGES="vlc mpv audacious"
INTERNET_PACKAGES="firefox-esr transmission-gtk qutebrowser hexchat"
SYSTEM_PACKAGES="lxterminal htop pcmanfm galculator"
OFFICE_PACKAGES="abiword gnumeric evince zathura"
DEV_PACKAGES="geany codeblocks vim nano"
# PERSONAL_PACKAGES="lxcalendar keepassxc galculator xpad"
PERSONAL_PACKAGES="keepassxc galculator xpad"
# GRAPHICS_PACKAGES="feh mirage gimp inkscape"
GRAPHICS_PACKAGES="feh mirage inkscape"
# EDU_PACKAGES="stellarium anki tuxmath freeciv"
EDU_PACKAGES="tuxmath freeciv"
ALL_CATEGORIES=("MULTIMEDIA" "INTERNET" "SYSTEM" "OFFICE" "DEV" "PERSONAL" "GRAPHICS" "EDU")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}ERROR: $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "Please run as root: sudo $0"
    fi
}

check_distro() {
    if [ -z "$DISTRO_CHECK" ]; then
        error "This script is designed for Debian-based systems."
    fi
}

check_internet() {
    log "Checking internet connectivity..."
    if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        error "No internet connection detected. Please check your network."
    fi
}

check_package_installed() {
    local package="$1"
    dpkg -s "$package" >/dev/null 2>&1
}

install_packages() {
    local package_list="$1"
    local section_name="$2"
    local dry_run="$3"
    log "[$section_name] Checking packages..."
    local to_install=""
    for pkg in $package_list; do
        if ! check_package_installed "$pkg"; then
            to_install="$to_install $pkg"
        else
            log "  $pkg is already installed, skipping."
        fi
    done
    if [ -n "$to_install" ]; then
        if [ "$dry_run" = "true" ]; then
            log "  [DRY-RUN] Would install: $to_install"
        else
            if ! apt install -y --no-install-recommends $to_install >>"$LOG_FILE" 2>&1; then
                error "Failed to install packages: $to_install"
            fi
            log "  Installed: $to_install"
        fi
    else
        log "  No new packages to install."
    fi
}

display_menu() {
    echo -e "${YELLOW}Select lightweight package categories to install:${NC}"
    echo "1. Multimedia Tools (${MULTIMEDIA_PACKAGES})"
    echo "2. Internet/Communication Tools (${INTERNET_PACKAGES})"
    echo "3. System Utilities (${SYSTEM_PACKAGES})"
    echo "4. Office/Document Tools (${OFFICE_PACKAGES})"
    echo "5. Development/Admin Tools (${DEV_PACKAGES})"
    echo "6. Personal Utilities (${PERSONAL_PACKAGES})"
    echo "7. Graphics Tools (${GRAPHICS_PACKAGES})"
    echo "8. Educational Tools (${EDU_PACKAGES})"
    echo "9. Install All"
    echo "0. Exit"
}

get_user_selection() {
    local selections=()
    while true; do
        read -p "Enter choice (0-9, or multiple e.g., '1 3 5'): " -r input
        if [[ "$input" =~ ^[0-9]([[:space:]][0-9])*$ ]]; then
            for choice in $input; do
                if [ "$choice" -eq 0 ]; then
                    log "Installation aborted by user."
                    exit 0
                elif [ "$choice" -ge 1 ] && [ "$choice" -le 9 ]; then
                    selections+=("$choice")
                else
                    echo -e "${RED}Invalid choice: $choice${NC}"
                    continue 2
                fi
            done
            break
        else
            echo -e "${RED}Invalid input. Use numbers 0-9, space-separated.${NC}"
        fi
    done
    echo "${selections[@]}"
}

main() {
    local dry_run=false
    if [ "$1" = "--dry-run" ]; then
        dry_run=true
        log "Running in dry-run mode..."
    fi

    # Initialize log
    touch "$LOG_FILE" || error "Cannot create log file at $LOG_FILE"
    log "Starting lightweight extras installation..."

    # Pre-flight checks
    check_root
    check_distro
    check_internet

    # Display menu and get selections
    display_menu
    selections=$(get_user_selection)
    if [ -z "$selections" ]; then
        error "No valid selections made."
    fi

    # Update package lists
    log "[0/6] Updating package lists..."
    if [ "$dry_run" = "true" ]; then
        log "  [DRY-RUN] Would update package lists."
    else
        if ! apt update >>"$LOG_FILE" 2>&1; then
            error "Failed to update package lists"
        fi
    fi

    # Process selections
    local step=1
    for choice in $selections; do
        if [ "$choice" -eq 9 ]; then
            for i in "${!ALL_CATEGORIES[@]}"; do
                eval "pkg_list=\$${ALL_CATEGORIES[$i]}_PACKAGES"
                install_packages "$pkg_list" "$((step++))/6 Installing ${ALL_CATEGORIES[$i]} Tools" "$dry_run"
            done
            break
        else
            case $choice in
                1) install_packages "$MULTIMEDIA_PACKAGES" "$((step++))/6 Installing Multimedia Tools" "$dry_run";;
                2) install_packages "$INTERNET_PACKAGES" "$((step++))/6 Installing Internet/Communication Tools" "$dry_run";;
                3) install_packages "$SYSTEM_PACKAGES" "$((step++))/6 Installing System Utilities" "$dry_run";;
                4) install_packages "$OFFICE_PACKAGES" "$((step++))/6 Installing Office/Document Tools" "$dry_run";;
                5) install_packages "$DEV_PACKAGES" "$((step++))/6 Installing Development/Admin Tools" "$dry_run";;
                6) install_packages "$PERSONAL_PACKAGES" "$((step++))/6 Installing Personal Utilities" "$dry_run";;
                7) install_packages "$GRAPHICS_PACKAGES" "$((step++))/6 Installing Graphics Tools" "$dry_run";;
                8) install_packages "$EDU_PACKAGES" "$((step++))/6 Installing Educational Tools" "$dry_run";;
            esac
        fi
    done

    # Final cleanup
    log "[✔] Cleaning up unused packages..."
    if [ "$dry_run" = "true" ]; then
        log "  [DRY-RUN] Would clean up unused packages."
    else
        if ! apt autoremove -y >>"$LOG_FILE" 2>&1; then
            error "Failed to clean up unused packages"
        fi
    fi

    log "[✅] Lightweight Suite Extras installation completed."
    echo -e "${GREEN}Lightweight Suite Extras installation completed. Enjoy!${NC}"
}

# Execute main
main "$@"
