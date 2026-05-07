#!/usr/bin/env bash

# Path to the file storing the selected partition
CONFIG_FILE="/home/naranyala/.config/waybar/selected_disk"

# Read the selected partition, fallback to root /
if [ -f "$CONFIG_FILE" ]; then
    PARTITION=$(cat "$CONFIG_FILE")
else
    PARTITION="/"
fi

# Get the usage percentage for the partition
# df -h [path] | tail -1 | awk '{print $5}' gives something like '45%'
USAGE=$(df -h "$PARTITION" | tail -1 | awk '{print $5}')

# If USAGE is empty (e.g. partition unmounted), show Error
if [ -z "$USAGE" ]; then
    USAGE="N/A"
fi

# Output as JSON for Waybar
echo "{\"text\": \"[ disk $USAGE ]\"}"
