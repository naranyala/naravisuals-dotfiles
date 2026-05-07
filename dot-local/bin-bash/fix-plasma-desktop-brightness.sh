#!/bin/bash
# /usr/local/bin/set-brightness-menu.sh

set -euo pipefail

# 🧪 Check for brightnessctl
if ! command -v brightnessctl &>/dev/null; then
  echo "🔧 brightnessctl not found. Attempting to install..."

  if command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm brightnessctl
  elif command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y brightnessctl
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y brightnessctl
  elif command -v zypper &>/dev/null; then
    sudo zypper install -y brightnessctl
  else
    echo "❌ Unsupported package manager. Please install brightnessctl manually."
    exit 1
  fi
fi

# 🔍 Detect backlight device
BACKLIGHT_DEVICE=$(ls /sys/class/backlight | head -n 1)
MAX=$(cat /sys/class/backlight/"$BACKLIGHT_DEVICE"/max_brightness)

# Define brightness levels as percentages of MAX
declare -A LEVELS=(
  [1]=$(( MAX * 10 / 100 ))  # 10%
  [2]=$(( MAX * 20 / 100 ))  # 20%
  [3]=$(( MAX * 30 / 100 ))  # 30%
  [4]=$(( MAX * 40 / 100 ))  # 40%
  [5]=$(( MAX * 50 / 100 ))  # 50%
  [6]=$(( MAX * 60 / 100 ))  # 60%
  [7]=$(( MAX * 70 / 100 ))  # 70%
  [8]=$(( MAX * 80 / 100 ))  # 80%
  [9]=$(( MAX * 100 / 100 )) # 100%
)

echo ""
echo "💡 Choose Brightness Level:"
echo "  [1] 10%"
echo "  [2] 20%"
echo "  [3] 30%"
echo "  [4] 40%"
echo "  [5] 50%"
echo "  [6] 60%"
echo "  [7] 70%"
echo "  [8] 80%"
echo "  [9] 100%"
echo ""

read -rp "Enter your choice (1-9): " CHOICE

if [[ -z "${LEVELS[$CHOICE]+_}" ]]; then
  echo "❌ Invalid option. Please pick between 1–9."
  exit 1
fi

echo "✅ Setting brightness to ${LEVELS[$CHOICE]}..."
brightnessctl --device="$BACKLIGHT_DEVICE" set "${LEVELS[$CHOICE]}"
