#!/bin/bash

# List of commonly used XFCE plugins/applets
plugins=(
  xfce4-whiskermenu-plugin         # Modern application menu
  xfce4-battery-plugin             # Battery monitor
  xfce4-weather-plugin             # Weather display
  xfce4-netload-plugin             # Network load monitor
  xfce4-cpugraph-plugin            # CPU usage graph
  xfce4-diskperf-plugin            # Disk performance monitor
  xfce4-sensors-plugin             # Hardware sensors (needs lm-sensors)
  xfce4-systemload-plugin          # System load monitor
  xfce4-timer-plugin               # Countdown timer
  xfce4-places-plugin              # Quick access to folders
  xfce4-pulseaudio-plugin          # Audio volume control
  xfce4-clipman-plugin             # Clipboard manager
  xfce4-genmon-plugin              # Generic monitor (run custom scripts)
  xfce4-mailwatch-plugin           # Mail checker
  xfce4-smartbookmark-plugin       # Quick web search
  xfce4-datetime-plugin            # Enhanced date/time display
  xfce4-notes-plugin               # Sticky notes
  xfce4-taskmanager                # Lightweight task manager
  xfce4-xkb-plugin                 # Keyboard layout switcher
  xfce4-eyes-plugin                # Fun eyes that follow your cursor
)

echo "🔄 Updating package list..."
sudo apt update

echo "📦 Installing XFCE plugins..."
for plugin in "${plugins[@]}"; do
  if dpkg -l | grep -q "$plugin"; then
    echo "✅ $plugin is already installed."
  else
    echo "⬇️ Installing $plugin..."
    sudo apt install -y "$plugin"
  fi
done

echo "🔧 Optional: Detecting hardware sensors (for xfce4-sensors-plugin)..."
if command -v sensors >/dev/null 2>&1; then
  echo "✅ lm-sensors already installed."
else
  echo "⬇️ Installing lm-sensors..."
  sudo apt install -y lm-sensors
  sudo sensors-detect --auto
fi

echo "🎉 All done! You can restart the panel with: xfce4-panel -r"

