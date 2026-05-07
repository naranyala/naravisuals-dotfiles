#!/usr/bin/env bash

# Get a list of all mount points from df, excluding pseudo-filesystems
# We take the mount point (last column)
OPTIONS=$(df -h | grep '^/dev/' | awk '{print $NF}')

# Use fuzzel to pick one
SELECTED=$(echo -e "$OPTIONS" | fuzzel --dmenu -p "Pick Disk Partition: ")

# If something was selected, save it to a file
if [ -n "$SELECTED" ]; then
    echo "$SELECTED" > /home/naranyala/.config/waybar/selected_disk
fi
