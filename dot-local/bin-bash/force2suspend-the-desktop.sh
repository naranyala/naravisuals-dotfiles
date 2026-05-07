#!/bin/bash

# Simple menu for suspend options
# Requires: systemctl, zenity or whiptail (choose one)

# --- CONFIG ---
# Use 'zenity' for a GUI dialog, or 'whiptail' for terminal menu
USE_GUI=false

# Function to set suspend mode
set_suspend_mode() {
    local mode=$1
    echo "$mode" | sudo tee /sys/power/mem_sleep >/dev/null
    echo "Suspend mode set to: $mode"
}

# Function to unload USB modules (example)
disable_usb() {
    echo "Disabling USB devices..."
    for mod in uhci_hcd ehci_hcd xhci_hcd; do
        sudo modprobe -r $mod 2>/dev/null
    done
}

# Function to re-enable USB modules
enable_usb() {
    echo "Re-enabling USB devices..."
    for mod in uhci_hcd ehci_hcd xhci_hcd; do
        sudo modprobe $mod 2>/dev/null
    done
}

# Menu options
OPTIONS=(
    "1" "Suspend normally"
    "2" "Set deep sleep mode then suspend"
    "3" "Disable USB devices before suspend"
    "4" "Cancel"
)

# Show menu
if $USE_GUI && command -v zenity >/dev/null; then
    CHOICE=$(zenity --list --title="Suspend Menu" \
        --column="Option" --column="Description" \
        "${OPTIONS[@]}" --height=300 --width=400)
else
    CHOICE=$(whiptail --title "Suspend Menu" \
        --menu "Choose an action:" 15 60 4 \
        "${OPTIONS[@]}" 3>&1 1>&2 2>&3)
fi

# Handle choice
case $CHOICE in
    1)
        echo "Suspending normally..."
        systemctl suspend
        ;;
    2)
        set_suspend_mode deep
        systemctl suspend
        ;;
    3)
        disable_usb
        systemctl suspend
        enable_usb
        ;;
    *)
        echo "Cancelled."
        ;;
esac

