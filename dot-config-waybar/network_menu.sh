#!/usr/bin/env bash

# Interface name
INTERFACE="wlp2s0"

# Main Menu
options="Turn On WiFi\nTurn Off WiFi"
chosen=$(echo -e "$options" | fuzzel --dmenu -p "Network Action: ")

case "$chosen" in
    "Turn On WiFi")
        nmcli radio wifi on
        sleep 2 # Give it time to enable and scan
        
        # Scan for networks
        nmcli device wifi rescan
        sleep 1

        # List available SSIDs (sorted, unique)
        # -t: terse, -f SSID: only SSID field
        SSIDS=$(nmcli -t -f SSID device wifi list | grep -v '^$' | sort -u)
        
        if [ -z "$SSIDS" ]; then
            notify-send "Network" "No available networks found"
            exit 0
        fi

        # Pick an SSID
        SELECTED_SSID=$(echo -e "$SSIDS" | fuzzel --dmenu -p "Select Network: ")
        
        if [ -n "$SELECTED_SSID" ]; then
            # Prompt for password
            PASSWORD=$(fuzzel --dmenu -p "Enter Password for $SELECTED_SSID: ")
            
            if [ -n "$PASSWORD" ]; then
                # Attempt to connect
                if nmcli device wifi connect "$SELECTED_SSID" password "$PASSWORD"; then
                    notify-send "Network" "Successfully connected to $SELECTED_SSID"
                else
                    notify-send "Network" "Failed to connect to $SELECTED_SSID"
                fi
            else
                notify-send "Network" "Password cannot be empty"
            fi
        fi
        ;;
    "Turn Off WiFi")
        nmcli radio wifi off
        notify-send "Network" "WiFi turned off"
        ;;
esac
