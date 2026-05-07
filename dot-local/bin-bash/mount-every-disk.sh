#!/bin/bash

# Ask for root password
PASSWORD=$(zenity --password --title="Root Access Required")
[ $? -ne 0 ] && exit 1   # User cancelled

USER_NAME=$(whoami)
BASE="/run/media/$USER_NAME"

echo "$PASSWORD" | sudo -S mkdir -p "$BASE"

# Find all partitions with a filesystem
for dev in $(lsblk -lnpo NAME,TYPE | awk '$2=="part"{print $1}'); do
    fs=$(blkid -o value -s TYPE "$dev")
    [ -n "$fs" ] || continue   # skip if no filesystem

    # Prefer LABEL, fallback to UUID
    label=$(blkid -o value -s LABEL "$dev")
    [ -z "$label" ] && label=$(blkid -o value -s UUID "$dev")

    mnt="$BASE/$label"
    echo "$PASSWORD" | sudo -S mkdir -p "$mnt"

    # Try to mount
    echo "$PASSWORD" | sudo -S mount "$dev" "$mnt" 2>/tmp/mount_err.log
    if [ $? -eq 0 ]; then
        mounted="$mounted\n$dev → $mnt"
    else
        failed="$failed\n$dev (see /tmp/mount_err.log)"
    fi
done

# Show results
zenity --info --title="Mount Results" --text="Mounted:$mounted\n\nFailed:$failed"

