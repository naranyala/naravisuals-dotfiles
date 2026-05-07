#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

LOGFILE="/tmp/system_status.log"

# Create a safer logging function
log_output() {
    tee -a "$LOGFILE"
}

get_os_info() {
    echo "=== OS Info ==="
    if command -v lsb_release &>/dev/null; then
        lsb_release -a
    elif [[ -f /etc/os-release ]]; then
        cat /etc/os-release
    else
        echo "OS info not available"
    fi
}

get_kernel_info() {
    echo "=== Kernel Info ==="
    uname -r
}

get_uptime() {
    echo "=== Uptime ==="
    if command -v uptime &>/dev/null; then
        # Try -p flag first, fallback to regular uptime
        uptime -p 2>/dev/null || uptime
    else
        echo "Uptime info not available"
    fi
}

get_cpu_info() {
    echo "=== CPU Info ==="
    if command -v lscpu &>/dev/null; then
        lscpu | grep -E 'Model name|Architecture|CPU\(s\)'
    else
        echo "CPU info not available"
    fi
}

get_mem_info() {
    echo "=== Memory Info ==="
    free -h
}

get_disk_info() {
    echo "=== Disk Usage ==="
    df -hT | grep -E '^/dev/' || echo "No mounted devices found"
}

get_load_avg() {
    echo "=== Load Average ==="
    if [[ -r /proc/loadavg ]]; then
        cat /proc/loadavg
    else
        echo "Load average not available"
    fi
}

get_top_processes() {
    echo "=== Top Processes ==="
    ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n 10
}

get_volume_info() {
    echo "=== Volume Info ==="
    if command -v pamixer &>/dev/null; then
        pamixer --get-volume-human
    elif command -v amixer &>/dev/null; then
        amixer get Master | awk -F'[][]' '/Left:/ { print $2 " (" $4 ")" }'
    elif command -v pactl &>/dev/null; then
        pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null || echo "PulseAudio not available"
    else
        echo "Volume info not available"
    fi
}

get_brightness_info() {
    echo "=== Brightness Info ==="
    if command -v brightnessctl &>/dev/null; then
        brightnessctl | grep -E 'Current brightness|Device'
    elif [[ -d /sys/class/backlight ]]; then
        for dev in /sys/class/backlight/*; do
            if [[ -r "$dev/brightness" && -r "$dev/max_brightness" ]]; then
                cur=$(<"$dev/brightness")
                max=$(<"$dev/max_brightness")
                echo "$(basename "$dev"): $((cur * 100 / max))%"
            fi
        done
    else
        echo "Brightness info not available"
    fi
}

get_battery_info() {
    echo "=== Battery Info ==="
    if command -v acpi &>/dev/null; then
        acpi -b
    elif [[ -d /sys/class/power_supply ]]; then
        for bat in /sys/class/power_supply/BAT*; do
            if [[ -r "$bat/capacity" && -r "$bat/status" ]]; then
                charge=$(<"$bat/capacity")
                status=$(<"$bat/status")
                echo "$(basename "$bat"): $charge% ($status)"
            fi
        done
    else
        echo "Battery info not available"
    fi
}

main() {
    echo "System Status Report - $(date)"
    get_os_info
    get_kernel_info
    get_uptime
    get_cpu_info
    get_mem_info
    get_disk_info
    get_load_avg
    get_top_processes
    get_volume_info
    get_brightness_info
    get_battery_info
    echo "Log saved to: $LOGFILE"
}

# Run with logging
main | log_output
