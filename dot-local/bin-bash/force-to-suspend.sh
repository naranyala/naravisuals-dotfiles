
#!/usr/bin/env bash

echo "🔍 Detecting suspend method..."

confirm_suspend() {
    read -rp "Confirm suspend (y/n)? " choice
    case "$choice" in
        [Yy]*) return 0 ;;
        *)     echo "Suspend cancelled."; exit 0 ;;
    esac
}

suspend_with_systemctl() {
    echo "✅ Using systemctl to suspend..."
    systemctl suspend
}

suspend_with_sysfs() {
    if [[ -w /sys/power/state ]]; then
        echo "✅ Using /sys/power/state to suspend..."
        echo -n mem > /sys/power/state
    else
        echo "❌ Cannot suspend: /sys/power/state not writable." >&2
        exit 3
    fi
}

main() {
    confirm_suspend

    if command -v systemctl &> /dev/null; then
        suspend_with_systemctl
    else
        suspend_with_sysfs
    fi
}

main
