#!/usr/bin/env bash

# Define the options
options="Shutdown\nRestart\nSuspend\nLogout"

# Use fuzzel to get the user's choice
chosen=$(echo -e "$options" | fuzzel --dmenu -p "Session Action: ")

# If no choice is made (e.g., user pressed Esc), exit
if [[ -z "$chosen" ]]; then
    exit 0
fi

# Confirmation step
confirmation=$(echo -e "Yes\nNo" | fuzzel --dmenu -p "Are you sure you want to $chosen?")

# If no confirmation is made (e.g., user pressed Esc), exit
if [[ "$confirmation" != "Yes" ]]; then
    exit 0
fi

# Execute the corresponding command
case "$chosen" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Restart")
        systemctl reboot
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Logout")
        niri msg action quit
        ;;
esac
