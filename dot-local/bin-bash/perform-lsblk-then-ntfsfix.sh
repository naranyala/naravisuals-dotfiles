#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run this script as root."
  exit 1
fi

echo "🔍 Scanning for NTFS partitions..."
# Get list of NTFS partitions
mapfile -t ntfs_partitions < <(lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT -nr | awk '$2 == "ntfs" {print $1, $3, $4}')

if [[ ${#ntfs_partitions[@]} -eq 0 ]]; then
  echo "✅ No NTFS partitions found."
  exit 0
fi

echo "📋 Found NTFS partitions:"
for i in "${!ntfs_partitions[@]}"; do
  echo "$((i+1)). ${ntfs_partitions[$i]}"
done

# Prompt user to choose a partition
read -p "👉 Enter the number of the partition you want to fix: " choice

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#ntfs_partitions[@]} )); then
  echo "❌ Invalid selection."
  exit 1
fi

# Extract device name
selected_line="${ntfs_partitions[$((choice-1))]}"
selected_device="/dev/$(echo "$selected_line" | awk '{print $1}')"

echo "🔧 Running ntfsfix on $selected_device..."
ntfsfix -d "$selected_device"
echo "✅ Finished ntfsfix on $selected_device"

