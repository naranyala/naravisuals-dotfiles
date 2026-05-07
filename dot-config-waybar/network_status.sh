#!/usr/bin/env bash

# Interface name
INTERFACE="wlp2s0"

# Get state and connection name in one call
# Output format: state:connection
INFO=$(nmcli -t -f GENERAL.STATE,GENERAL.CONNECTION device show "$INTERFACE")
STATE=$(echo "$INFO" | cut -d: -f1)
CONN=$(echo "$INFO" | cut -d: -f2)

if [ "$STATE" == "connected" ]; then
    # Get the actual SSID of the active connection
    SSID=$(nmcli -t -f 802-11-wireless.ssid connection show "$CONN" | cut -d: -f2)
    if [ -n "$SSID" ]; then
        TEXT="[ net $SSID ]"
    else
        TEXT="[ net WiFi ]"
    fi
elif [ "$STATE" == "disconnected" ] || [ "$STATE" == "unavailable" ]; then
    # Check if Ethernet is connected as fallback
    ETH_CONN=$(nmcli -t -f DEVICE,STATE device | grep "ethernet" | grep "connected")
    if [ -n "$ETH_CONN" ]; then
        TEXT="[ net ETH ]"
    else
        TEXT="[ net OFF ]"
    fi
else
    TEXT="[ net $STATE ]"
fi

echo "{\"text\": \"$TEXT\"}"
