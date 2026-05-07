#!/usr/bin/env bash
# suspend.sh — force system suspend if needed

set -euo pipefail

echo "[+] Attempting systemctl suspend..."
if systemctl suspend; then
    exit 0
fi

echo "[!] systemctl failed, trying pm-suspend..."
if command -v pm-suspend >/dev/null 2>&1; then
    if pm-suspend; then
        exit 0
    fi
fi

echo "[!] Falling back to /sys/power/state (force suspend)..."
if [[ -w /sys/power/state ]]; then
    echo mem | sudo tee /sys/power/state
    exit 0
fi

echo "[x] Suspend failed: no supported method found."
exit 1

