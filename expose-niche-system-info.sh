#!/bin/bash

# --- Styling & Colors ---
B=$(tput bold); C=$(tput setaf 6); G=$(tput setaf 2); Y=$(tput setaf 3); R=$(tput sgr0)

# --- Helper Function: Centralized Formatter ---
# Usage: print_info "Label" "Value" "Color_Variable"
print_info() {
    printf "  ${G}%-15s${R} : %b%s${R}\n" "$1" "$3" "$2"
}

# --- 1. Gather All Data ---
OS=$(grep '^PRETTY_NAME' /etc/os-release | cut -d'=' -f2 | tr -d '"')
KERNEL=$(uname -r)
SESSION="$XDG_SESSION_TYPE ($(echo $XDG_CURRENT_DESKTOP))"
BOARD=$(sudo dmidecode -s baseboard-product-name 2>/dev/null || echo "Run as sudo")
CPU=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
MEM=$(free -h | awk '/^Mem:/ {print $3 " / " $2}')
TEMP=$(sensors 2>/dev/null | grep 'Package id 0:' | awk '{print $4}' || echo "N/A")

# Font Data
FONT_NAME=$(fc-match monospace | cut -d'"' -f2)
FONT_PATH=$(fc-match -f "%{file}" monospace)
AA=$(gsettings get org.gnome.settings-daemon.plugins.xsettings antialiasing 2>/dev/null | tr -d "'" || echo "N/A")

# Internal Data
ENTROPY=$(cat /proc/sys/kernel/random/entropy_avail)
[[ $ENTROPY -lt 256 ]] && E_COL=$Y || E_COL=$R
LSM=$(cat /sys/kernel/security/lsm 2>/dev/null || echo "N/A")
FILES=$(cat /proc/sys/fs/file-nr | awk '{print $1 " / " $3}')

# --- 2. Display Output ---
clear
echo -e "${C}${B}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${R}"
echo -e "  ${B}${C}SYSTEM CORE${R}"
print_info "OS" "$OS" "$R"
print_info "Kernel" "$KERNEL" "$R"
print_info "Session" "$SESSION" "$R"

echo -e "\n  ${B}${C}HARDWARE & THERMALS${R}"
print_info "Mainboard" "$BOARD" "$R"
print_info "Processor" "$CPU" "$R"
print_info "Memory" "$MEM" "$R"
print_info "Temperature" "$TEMP" "$Y"

echo -e "\n  ${B}${C}FONT ARCHITECTURE${R}"
print_info "Active Font" "$FONT_NAME" "$R"
print_info "Font Path" "$FONT_PATH" "$Y"
print_info "Antialiasing" "$AA" "$R"

echo -e "\n  ${B}${C}KERNEL INTERNALS${R}"
print_info "Entropy" "$ENTROPY bits" "$E_COL"
print_info "Security" "$LSM" "$R"
print_info "File Handles" "$FILES" "$R"
echo -e "${C}${B}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${R}"

