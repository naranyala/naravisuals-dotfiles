#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Terminal control
readonly ESC=$'\033'
readonly CLEAR_SCREEN="${ESC}[2J"
readonly MOVE_HOME="${ESC}[H"
readonly HIDE_CURSOR="${ESC}[?25l"
readonly SHOW_CURSOR="${ESC}[?25h"
readonly RESET_COLOR="${ESC}[0m"
readonly BOLD="${ESC}[1m"
readonly REVERSE="${ESC}[7m"

# Tab definitions (1-based indexing)
declare -ra TABS=("" "OS" "CPU" "MEM" "DISK" "NET" "PROC" "PWR" "SYS")
declare -i current_tab=1

# Cleanup on exit
cleanup() {
    printf "%s%s" "$SHOW_CURSOR" "$RESET_COLOR"
    stty echo
}
trap cleanup EXIT

# Initialize terminal
init_terminal() {
    stty -echo
    printf "%s%s" "$HIDE_CURSOR" "$CLEAR_SCREEN"
}

# Draw tab bar
draw_tabs() {
    printf "%s%s" "$MOVE_HOME" "$BOLD"
    for i in $(seq 1 $((${#TABS[@]} - 1))); do
        if [[ $i -eq $current_tab ]]; then
            printf "%s[%d:%s]%s " "$REVERSE" "$i" "${TABS[$i]}" "$RESET_COLOR$BOLD"
        else
            printf " %d:%s  " "$i" "${TABS[$i]}"
        fi
    done
    printf "%s\n" "$RESET_COLOR"
    printf "%.$(tput cols)s\n" "$(printf '=%.0s' {1..80})"
}

# Data collection functions
get_os_data() {
    echo "Operating System Information:"
    echo "----------------------------"
    if command -v lsb_release &>/dev/null; then
        lsb_release -a 2>/dev/null
    elif [[ -f /etc/os-release ]]; then
        cat /etc/os-release
    fi
    echo
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    if command -v uptime &>/dev/null; then
        echo "Uptime: $(uptime -p 2>/dev/null || uptime | cut -d',' -f1)"
    fi
}

get_cpu_data() {
    echo "CPU Information:"
    echo "---------------"
    if command -v lscpu &>/dev/null; then
        lscpu | grep -E 'Model name|Architecture|CPU\(s\)|Thread|Core|Socket|MHz'
    fi
    echo
    echo "Load Average:"
    if [[ -r /proc/loadavg ]]; then
        read -r load1 load5 load15 _ _ < /proc/loadavg
        printf "1min: %s  5min: %s  15min: %s\n" "$load1" "$load5" "$load15"
    fi
}

get_mem_data() {
    echo "Memory Information:"
    echo "------------------"
    free -h
    echo
    if [[ -r /proc/meminfo ]]; then
        echo "Detailed Memory:"
        grep -E 'MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree' /proc/meminfo
    fi
}

get_disk_data() {
    echo "Disk Usage:"
    echo "----------"
    df -hT | head -1
    df -hT | grep -E '^/dev/' | head -10
    echo
    if command -v lsblk &>/dev/null; then
        echo "Block Devices:"
        lsblk -f 2>/dev/null | head -15
    fi
}

get_net_data() {
    echo "Network Information:"
    echo "-------------------"
    if command -v ip &>/dev/null; then
        echo "Interfaces:"
        ip addr show | grep -E '^[0-9]+:|inet ' | head -20
    elif command -v ifconfig &>/dev/null; then
        ifconfig | grep -E 'flags|inet ' | head -15
    fi
    echo
    if [[ -r /proc/net/route ]]; then
        echo "Default Gateway:"
        route -n 2>/dev/null | grep '^0.0.0.0' | head -3
    fi
}

get_proc_data() {
    echo "Top Processes (by Memory):"
    echo "-------------------------"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -15
    echo
    echo "Process Count:"
    echo "Running: $(ps -e --no-headers | wc -l)"
    echo "Zombie: $(ps -eo stat --no-headers | grep -c Z || echo 0)"
}

get_pwr_data() {
    echo "Power & Hardware:"
    echo "----------------"
    
    # Battery
    if command -v acpi &>/dev/null; then
        echo "Battery:"
        acpi -b 2>/dev/null || echo "No battery info available"
    elif [[ -d /sys/class/power_supply ]]; then
        echo "Battery:"
        for bat in /sys/class/power_supply/BAT*; do
            if [[ -r "$bat/capacity" && -r "$bat/status" ]]; then
                charge=$(<"$bat/capacity")
                status=$(<"$bat/status")
                echo "  $(basename "$bat"): $charge% ($status)"
            fi
        done
    fi
    
    echo
    # Temperature
    if [[ -d /sys/class/thermal ]]; then
        echo "Temperature:"
        for thermal in /sys/class/thermal/thermal_zone*; do
            if [[ -r "$thermal/temp" ]]; then
                temp=$(<"$thermal/temp")
                temp_c=$((temp / 1000))
                echo "  Zone $(basename "$thermal" | sed 's/thermal_zone//'): ${temp_c}°C"
            fi
        done
    fi
    
    echo
    # Brightness
    if command -v brightnessctl &>/dev/null; then
        echo "Brightness:"
        brightnessctl | grep -E 'Device|Current'
    fi
}

get_sys_data() {
    echo "System Status:"
    echo "-------------"
    echo "Date: $(date)"
    echo "Timezone: $(timedatectl show --property=Timezone --value 2>/dev/null || date +%Z)"
    echo
    
    # Services (systemd)
    if command -v systemctl &>/dev/null; then
        echo "System Services:"
        echo "Failed: $(systemctl --failed --no-legend | wc -l)"
        echo "Active: $(systemctl list-units --state=active --no-legend | wc -l)"
    fi
    
    echo
    echo "Users:"
    who | head -10
    
    echo
    if [[ -r /proc/version ]]; then
        echo "Kernel Version:"
        cat /proc/version
    fi
}

# Display content for current tab
display_content() {
    case $current_tab in
        1) get_os_data ;;
        2) get_cpu_data ;;
        3) get_mem_data ;;
        4) get_disk_data ;;
        5) get_net_data ;;
        6) get_proc_data ;;
        7) get_pwr_data ;;
        8) get_sys_data ;;
    esac
}

# Main display function
display_ui() {
    printf "%s" "$CLEAR_SCREEN"
    draw_tabs
    echo
    display_content
    echo
    printf "%s" "$BOLD"
    echo "Navigation: [h/←] Previous  [l/→] Next  [r] Refresh  [q] Quit  [1-8] Jump to tab"
    printf "%s" "$RESET_COLOR"
}

# Handle user input
handle_input() {
    local key
    read -rsn1 key
    
    case $key in
        'h'|$'\x1b')
            if [[ $key == $'\x1b' ]]; then
                read -rsn2 key
                if [[ $key == "[D" ]]; then  # Left arrow
                    ((current_tab > 1)) && ((current_tab--))
                elif [[ $key == "[C" ]]; then  # Right arrow
                    ((current_tab < ${#TABS[@]} - 1)) && ((current_tab++))
                fi
            else
                ((current_tab > 1)) && ((current_tab--))
            fi
            ;;
        'l')
            ((current_tab < ${#TABS[@]} - 1)) && ((current_tab++))
            ;;
        'r')
            # Refresh - just redraw
            ;;
        'q'|'Q')
            return 1
            ;;
        [1-8])
            local tab_num=$((key))
            if ((tab_num >= 1 && tab_num <= ${#TABS[@]} - 1)); then
                current_tab=$tab_num
            fi
            ;;
    esac
    return 0
}

# Main loop
main() {
    init_terminal
    
    while true; do
        display_ui
        if ! handle_input; then
            break
        fi
    done
}

# Run the TUI
main
