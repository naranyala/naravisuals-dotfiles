
#!/bin/bash

# Get current user
USER_NAME=$(whoami)
MOUNT_BASE="/media/$USER_NAME"

# Ensure mount base exists
mkdir -p "$MOUNT_BASE"

# Scan mounted partitions under MOUNT_BASE
echo "🔍 Scanning mounted partitions..."
MOUNTED_POINTS=($(find "$MOUNT_BASE" -mindepth 1 -maxdepth 1 -type d))

if [ ${#MOUNTED_POINTS[@]} -eq 0 ]; then
    echo "📭 No mounted partitions found under $MOUNT_BASE"
    exit 0
fi

# Display list of mounted partitions
echo "📋 Mounted partitions:"
for i in "${!MOUNTED_POINTS[@]}"; do
    MP="${MOUNTED_POINTS[$i]}"
    DEVICE=$(findmnt -n -o SOURCE --target "$MP")
    echo "$i) $DEVICE → $MP"
done

# Ask user to pick a mount point to unmount
read -p "👉 Enter the number of the mount point to unmount: " CHOICE

# Validate input
if [[ ! "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -ge "${#MOUNTED_POINTS[@]}" ]; then
    echo "❌ Invalid choice. Exiting."
    exit 1
fi

# Get selected mount point
SELECTED_MP="${MOUNTED_POINTS[$CHOICE]}"
DEVICE=$(findmnt -n -o SOURCE --target "$SELECTED_MP")

# Attempt to unmount
echo "📤 Unmounting $DEVICE from $SELECTED_MP..."
umount "$SELECTED_MP"

if [ $? -eq 0 ]; then
    echo "✅ Successfully unmounted $DEVICE"
    # Optionally remove empty mount directory
    rmdir "$SELECTED_MP" 2>/dev/null && echo "🧹 Removed $SELECTED_MP"
else
    echo "❌ Failed to unmount $DEVICE"
fi
