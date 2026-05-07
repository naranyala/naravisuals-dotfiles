#!/bin/bash

# Define your proxy settings here. 
# IMPORTANT: Replace with your actual proxy IP and Port.
# If you don't use a proxy, you can leave these blank, but often 
# explicitly setting them (even to a non-existent local one) can 
# satisfy the underlying library's request for a valid string.

PROXY_IP="127.0.0.1"
PROXY_PORT="8080"
NO_PROXY_LIST="localhost,127.0.0.1,192.168.0.1"

# Combine the settings into a full URI
if [ -n "$PROXY_IP" ] && [ -n "$PROXY_PORT" ]; then
    PROXY_URI="http://$PROXY_IP:$PROXY_PORT"
    echo "Setting all_proxy to $PROXY_URI"
    export all_proxy=$PROXY_URI
    export https_proxy=$PROXY_URI
    export http_proxy=$PROXY_URI
else
    echo "Proxy settings are empty, skipping export."
    # If you prefer to UNSET them if empty:
    # unset all_proxy https_proxy http_proxy
fi

echo "Setting no_proxy to $NO_PROXY_LIST"
export no_proxy=$NO_PROXY_LIST

# --- Run your Tauri Application ---
echo "Launching Tauri application..."
# Change this command to whatever you use to start your app (e.g., yarn tauri dev)

# Note: These environment variables will be cleared when this script finishes 
# and you close the terminal session you run it in.

