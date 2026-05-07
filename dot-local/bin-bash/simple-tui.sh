#!/bin/bash
while true; do
    choice=$(dialog --menu "System Menu" 12 40 5 \
        1 "Disk Usage" \
        2 "Processes" \
        3 "Network" \
        4 "Exit" 2>&1 >/dev/tty)
    case $choice in
        1) df -h ;;
        2) subchoice=$(dialog --menu "Processes" 10 40 3 \
            1 "CPU" 2 "Memory" 3 "PID" 2>&1 >/dev/tty)
           case $subchoice in
               1) top ;;
               2) htop ;;
               3) ps -aux | sort -k 2 ;;
           esac ;;
        3) ifconfig ;;
        4) break ;;
    esac
done
clear
sudo apt install dialog
