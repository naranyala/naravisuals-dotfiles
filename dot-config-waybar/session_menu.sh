#!/usr/bin/env bash

# Define the options
options="Shutdown\nRestart\nSuspend\nLogout"

# Use fuzzel to get the user's choice
chosen=$(echo -e "$options" | fuzzel --dmenu -p "Session Action: ")

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
