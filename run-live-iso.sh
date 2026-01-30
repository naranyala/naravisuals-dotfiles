#!/bin/bash
set -eo pipefail  # Exit immediately on error or undefined variables

ISO_PATH="$1"
DISK_IMG="vm_storage.qcow2"
# Modern Windows 11 / Linux 2026 requirements
MEM="8G"          # Minimum 4GB for Win11; 8GB recommended
CORES="4"         # 2+ cores required

# --- Error Handling & Environment Checks ---
if [[ -z "$ISO_PATH" ]]; then
    echo "Usage: $0 <iso_path>"
    exit 1
fi

if [[ ! -f "$ISO_PATH" ]]; then
    echo "Error: ISO file '$ISO_PATH' not found."
    exit 1
fi

# Check for QEMU installation
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "Error: qemu-system-x86_64 not found. Please install QEMU."
    exit 1
fi

# Create disk if missing
if [[ ! -f "$DISK_IMG" ]]; then
    echo "Creating 64GB virtual disk..." # Win11 requires min 64GB
    qemu-img create -f qcow2 "$DISK_IMG" 64G || { echo "Failed to create disk"; exit 1; }
fi

# --- Hardware Acceleration Detection ---
ACCEL="-machine q35" # q35 is required for modern features like PCIe/UEFI
if [[ -e /dev/kvm ]]; then
    ACCEL+=",accel=kvm"
    CPU_TYPE="host"
else
    echo "Warning: KVM hardware acceleration not available. VM will be VERY slow."
    CPU_TYPE="max"
fi

# --- Execution ---
echo "Launching VM with $ISO_PATH..."

# Note: For Windows 11, you typically need to add -drive if=pflash for UEFI/OVMF.
# The following is a universal stable config for both Linux and Windows.
qemu-system-x86_64 \
    $ACCEL \
    -m $MEM \
    -smp $CORES \
    -cpu $CPU_TYPE \
    -drive file="$DISK_IMG",format=qcow2,if=virtio \
    -cdrom "$ISO_PATH" \
    -net nic,model=virtio -net user \
    -vga virtio \
    -display gtk,zoom-to-fit=on \
    -usb -device usb-tablet \
    -boot order=d,menu=on

