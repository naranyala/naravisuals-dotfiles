#!/usr/bin/env bash
set -euo pipefail

echo "fix virtualbox ..."

# dnf install akmod-VirtualBox kernel-devel-$(uname -r)
#
# systemctl restart vboxdrv.service


# ─────────────────────────────────────────────
# 🧠 Purpose: Disable KVM modules to fix VirtualBox VMX root mode conflict
# 🛠️ Compatible: Intel & AMD CPUs, Debian-based distros
# 🧾 Logs: /var/log/disable_kvm.log
# ─────────────────────────────────────────────

LOG_FILE="/var/log/disable_kvm.log"
BLACKLIST_FILE="/etc/modprobe.d/blacklist-kvm.conf"

log() {
    echo "[$(date +'%F %T')] $*" | tee -a "$LOG_FILE"
}

detect_cpu_vendor() {
    grep -q 'GenuineIntel' /proc/cpuinfo && echo "intel" && return
    grep -q 'AuthenticAMD' /proc/cpuinfo && echo "amd" && return
    echo "unknown"
}

unload_kvm_modules() {
    log "🔍 Attempting to unload KVM modules..."
    sudo modprobe -r kvm || log "⚠️ Could not unload kvm (may not be loaded)"
    if [[ "$1" == "intel" ]]; then
        sudo modprobe -r kvm_intel || log "⚠️ Could not unload kvm_intel"
    elif [[ "$1" == "amd" ]]; then
        sudo modprobe -r kvm_amd || log "⚠️ Could not unload kvm_amd"
    fi
}

blacklist_kvm_modules() {
    log "🧱 Writing blacklist to $BLACKLIST_FILE..."
    echo "blacklist kvm" | sudo tee "$BLACKLIST_FILE" > /dev/null
    if [[ "$1" == "intel" ]]; then
        echo "blacklist kvm_intel" | sudo tee -a "$BLACKLIST_FILE" > /dev/null
    elif [[ "$1" == "amd" ]]; then
        echo "blacklist kvm_amd" | sudo tee -a "$BLACKLIST_FILE" > /dev/null
    fi
}

update_initramfs() {
    log "🔄 Updating initramfs..."
    if command -v update-initramfs &>/dev/null; then
        sudo update-initramfs -u
    elif command -v dracut &>/dev/null; then
        sudo dracut -f
    else
        log "⚠️ No initramfs tool found. Please update manually."
    fi
}

main() {
    log "🚀 Starting KVM disable script for VirtualBox..."
    CPU_VENDOR=$(detect_cpu_vendor)
    log "🧠 Detected CPU vendor: $CPU_VENDOR"

    unload_kvm_modules "$CPU_VENDOR"
    blacklist_kvm_modules "$CPU_VENDOR"
    update_initramfs

    log "✅ KVM modules disabled. Please reboot to apply changes."
}

main "$@"

