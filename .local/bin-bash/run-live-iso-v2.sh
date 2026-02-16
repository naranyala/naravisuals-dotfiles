#!/bin/bash
set -eo pipefail

ISO_PATH="$1"

# --- 0. Check for QEMU installation ---
if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "Error: qemu-system-x86_64 not found."
    echo "Install it with: sudo dnf install @virtualization qemu-kvm"
    exit 1
fi

if ! command -v qemu-img >/dev/null 2>&1; then
    echo "Error: qemu-img not found."
    echo "Install it with: sudo dnf install qemu-img"
    exit 1
fi

# --- 1. ISO validation ---
if [[ -z "$ISO_PATH" ]]; then
    echo "Usage: $0 <iso_path>"
    exit 1
fi

if [[ ! -f "$ISO_PATH" ]]; then
    echo "Error: ISO file '$ISO_PATH' not found."
    exit 1
fi

# --- 2. Storage directory setup ---
ISO_NAME=$(basename "$ISO_PATH" | sed 's/\.[^.]*$//')
ISO_NAME=$(echo "$ISO_NAME" | tr -cs '[:alnum:]' '_')

QCOW_DIR="$HOME/VMs/$ISO_NAME"
mkdir -p "$QCOW_DIR"

DISK_IMG="${QCOW_DIR}/${ISO_NAME}_storage.qcow2"

# --- 3. Automated Storage Management ---
if [[ ! -f "$DISK_IMG" ]]; then
    echo "Creating unique 64GB virtual disk: $DISK_IMG"
    qemu-img create -f qcow2 "$DISK_IMG" 64G
else
    echo "Using existing storage for this ISO: $DISK_IMG"
fi

# --- 4. Performance & Cache Configuration ---
STORAGE_OPTS="file=$DISK_IMG,format=qcow2,if=virtio,cache=none,aio=native"

ACCEL="-machine q35"
if [[ -e /dev/kvm ]]; then
    ACCEL+=",accel=kvm"
    CPU_TYPE="host"
else
    CPU_TYPE="max"
fi

# --- 5. Networking (modern Fedora syntax) ---
NET_OPTS="-netdev user,id=net0 -device virtio-net-pci,netdev=net0"

# --- 6. Execution ---
echo "Launching VM for $ISO_NAME..."
exec qemu-system-x86_64 \
    $ACCEL \
    -m 8G \
    -smp 4 \
    -cpu $CPU_TYPE \
    -drive "$STORAGE_OPTS" \
    -cdrom "$ISO_PATH" \
    $NET_OPTS \
    -vga virtio \
    -usb -device usb-tablet \
    -boot order=d,menu=on

