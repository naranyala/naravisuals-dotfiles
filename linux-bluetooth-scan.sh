#!/bin/bash

# Bluetooth Control Script
# Requires: bluetoothctl, rfkill, fzf

# --- Root check ---
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run as root. Try again with: sudo $0"
  exit 1
fi

# --- Dependencies check ---
for cmd in bluetoothctl rfkill fzf; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ Required command '$cmd' not found. Please install it first."
    exit 1
  fi
done

# --- Functions ---
bt_on() {
  echo "🔵 Turning Bluetooth ON..."
  rfkill unblock bluetooth
  bluetoothctl power on
}

bt_off() {
  echo "🔴 Turning Bluetooth OFF..."
  bluetoothctl power off
  rfkill block bluetooth
}

bt_scan_connect() {
  echo "🔍 Scanning for devices (10s)..."
  bluetoothctl scan on &
  scan_pid=$!
  sleep 10
  kill $scan_pid
  bluetoothctl scan off

  echo "📡 Fetching device list..."
  devices=$(bluetoothctl devices | awk '{print $2 " " $3}')
  if [[ -z "$devices" ]]; then
    echo "❌ No devices found."
    return
  fi

  selected=$(echo "$devices" | fzf --prompt="Select device> ")
  mac=$(echo "$selected" | awk '{print $1}')

  if [[ -z "$mac" ]]; then
    echo "❌ No device selected."
    return
  fi

  echo "🔗 Connecting to $selected..."
  bluetoothctl pair "$mac"
  bluetoothctl trust "$mac"
  bluetoothctl connect "$mac"
}

bt_view_detach() {
  echo "📡 Listing all devices..."
  all_devices=$(bluetoothctl devices | awk '{print $2 " " $3}')

  echo "🔗 Listing connected devices..."
  connected_devices=$(bluetoothctl info | grep "Device" | awk '{print $2 " " $3}')

  combined=$(printf "ALL DEVICES:\n%s\n\nCONNECTED DEVICES:\n%s\n" "$all_devices" "$connected_devices")

  selected=$(echo "$combined" | fzf --prompt="Detach device> ")
  mac=$(echo "$selected" | awk '{print $1}')

  if [[ -z "$mac" ]]; then
    echo "❌ No device selected."
    return
  fi

  echo "🔌 Detaching $selected..."
  bluetoothctl disconnect "$mac"
  bluetoothctl remove "$mac"
  echo "✅ Device detached."
}

# --- Main Loop ---
while true; do
  echo ""
  echo "Bluetooth Control Menu"
  echo "1) Turn ON Bluetooth"
  echo "2) Turn OFF Bluetooth"
  echo "3) Scan & Connect Device"
  echo "4) View Devices & Detach"
  echo "5) Exit"
  read -p "Choose an option [1-5]: " choice

  case $choice in
    1) bt_on ;;
    2) bt_off ;;
    3) bt_scan_connect ;;
    4) bt_view_detach ;;
    5) echo "👋 Exiting..."; break ;;
    *) echo "❌ Invalid choice" ;;
  esac
done

