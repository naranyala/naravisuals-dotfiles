#!/bin/bash
# Debian/Ubuntu: Pre-check for dpkg/apt locks, clear if safe, then run full-upgrade

set -euo pipefail

LOCK_FILES=(
    "/var/lib/dpkg/lock-frontend"
    "/var/lib/dpkg/lock"
    "/var/cache/apt/archives/lock"
)

echo "=== Checking for root privileges ==="
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (e.g., sudo $0)"
    exit 1
fi

check_and_clear_locks() {
    echo "=== Pre-checking for apt/dpkg locks ==="
    for lock in "${LOCK_FILES[@]}"; do
        if [ -f "$lock" ]; then
            echo "Found lock file: $lock"
            pid=$(fuser "$lock" 2>/dev/null || true)
            if [ -n "$pid" ]; then
                echo "Process $pid is holding $lock — killing it"
                kill -9 "$pid" || true
            fi
            rm -f "$lock"
        fi
    done
    echo "=== Reconfiguring dpkg ==="
    dpkg --configure -a || true
}

run_upgrade() {
    echo "=== Updating package lists ==="
    apt update
    echo "=== Running full-upgrade ==="
    apt full-upgrade -y
}

# 1. Always clear locks first
check_and_clear_locks

# 2. Then run the upgrade
run_upgrade

echo "=== Upgrade complete! ==="

