#!/bin/bash
# Disk manager script for Arch Linux
# Lists block devices and allows mounting or ejecting

list_devices() {
    echo "Available block devices:"
    lsblk -o NAME,TYPE,SIZE,MOUNTPOINT,RM,MODEL
    echo
}

mount_device() {
    read -p "Enter device (e.g., /dev/sdb1): " dev
    read -p "Enter mount point (must exist, e.g., /mnt/usb): " mp
    if [ ! -d "$mp" ]; then
        echo "Mount point does not exist. Create it first."
        return
    fi
    sudo mount "$dev" "$mp" && echo "Mounted $dev at $mp"
}

eject_device() {
    read -p "Enter device (e.g., /dev/sdb1): " dev
    mp=$(lsblk -no MOUNTPOINT "$dev" 2>/dev/null | head -n1)
    if [ -n "$mp" ]; then
        echo "Unmounting $dev from $mp..."
        sudo umount "$dev" && echo "Unmounted $dev"
    fi
    echo "Trying to eject $dev..."
    sudo eject "$dev" && echo "Ejected $dev"
}

while true; do
    echo "-----------------------------------"
    echo "Disk Manager Menu"
    echo "1) List devices"
    echo "2) Mount a device"
    echo "3) Eject a device"
    echo "4) Quit"
    echo "-----------------------------------"
    read -p "Choose an option: " choice

    case $choice in
        1) list_devices ;;
        2) mount_device ;;
        3) eject_device ;;
        4) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid choice" ;;
    esac
done

