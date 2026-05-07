#!/usr/bin/env bash

# Interface name
INTERFACE="wlp2s0"

# Get the state and active connection
INFO=$(nmcli -t -f GENERAL.STATE,GENERAL.CONNECTION device show "$INTERFACE")
STATE=$(echo "$INFO" | grep "GENERAL.STATE" | cut -d: -f2)
CONN=$(echo "$INFO" | grep "GENERAL.CONNECTION" | cut -d: -f2)

if [[ "$STATE" == *"connected"* ]]; then
    # Get the SSID from the active connection
    if [ -n "$CONN" ]; then
        SSID=$(nmcli -t -f 802-11-wireless.ssid connection show "$CONN" | cut -d: -f2)
    fi
    
    if [ -n "$SSID" ]; then
        TEXT="[ net $SSID ]"
    else
        TEXT="[ net connected ]"
    fi
else
    TEXT="[ net disconnected ]"
fi

echo "{\"text\": \"$TEXT\"}"
