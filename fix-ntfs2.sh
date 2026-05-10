#!/bin/bash

USER_NAME="naranyala"
MOUNT_BASE="/media/$USER_NAME"

# Create mount base if it doesn't exist
mkdir -p "$MOUNT_BASE"

echo "🔍 Scanning available partitions..."
PARTITIONS=($(lsblk -lnpo NAME,TYPE | grep 'part' | awk '{print $1}'))

echo "📋 Available partitions:"
for i in "${!PARTITIONS[@]}"; do
    PART="${PARTITIONS[$i]}"
    FS_TYPE=$(lsblk -no FSTYPE "$PART")
    SIZE=$(lsblk -no SIZE "$PART")
    LABEL=$(blkid -s LABEL -o value "$PART")
    echo "$i) $PART — ${LABEL:-NoLabel} — $FS_TYPE — $SIZE"
done

read -p "👉 Enter the number of the partition to mount: " CHOICE

if [[ ! "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -ge "${#PARTITIONS[@]}" ]; then
    echo "❌ Invalid choice. Exiting."
    exit 1
fi

SELECTED_PART="${PARTITIONS[$CHOICE]}"
LABEL=$(blkid -s LABEL -o value "$SELECTED_PART")
UUID=$(blkid -s UUID -o value "$SELECTED_PART")
DISK_NAME="${LABEL:-$UUID}"
MOUNT_POINT="$MOUNT_BASE/$DISK_NAME"

mkdir -p "$MOUNT_POINT"

echo "🔎 Checking if $SELECTED_PART is already mounted..."
if mount | grep -q "$SELECTED_PART"; then
    echo "⚠️ Already mounted. Attempting to unmount..."
    sudo umount "$SELECTED_PART" || sudo umount -l "$SELECTED_PART"
fi

echo "🔎 Checking for processes using $SELECTED_PART..."
PIDS=$(sudo fuser -v "$SELECTED_PART" 2>/dev/null | awk 'NR>1 {print $2}')
if [ -n "$PIDS" ]; then
    echo "⚠️ Killing processes: $PIDS"
    sudo kill -9 $PIDS
fi

echo "🩺 Running fsck on $SELECTED_PART..."
sudo fsck -t ntfs "$SELECTED_PART"

echo "📁 Mounting $SELECTED_PART to $MOUNT_POINT..."
sudo mount -t ntfs-3g "$SELECTED_PART" "$MOUNT_POINT"

if [ $? -eq 0 ]; then
    echo "✅ Successfully mounted at $MOUNT_POINT"
else
    echo "❌ Failed to mount $SELECTED_PART"
    echo "👉 Try running Windows chkdsk for deeper repair."
fi

