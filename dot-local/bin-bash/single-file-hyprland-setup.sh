#!/usr/bin/env bash

set -euo pipefail

# 🧩 Optional flags
WITH_ROFI=false
WITH_MAKO=false

# 🧩 Parse flags
for arg in "$@"; do
  case "$arg" in
    --with-rofi) WITH_ROFI=true ;;
    --with-mako) WITH_MAKO=true ;;
    *) echo "⚠️ Unknown option: $arg" ;;
  esac
done

# 📁 Config paths
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$CONFIG_HOME"

# 🧩 Check required tools
check_requirements() {
  for cmd in nix-shell nix-env; do
    command -v "$cmd" >/dev/null || {
      echo "❌ Required command '$cmd' not found. Please install Nix."
      exit 1
    }
  done
}

# 📦 Install packages
install_packages() {
  echo "📦 Installing core packages..."
  nix-env -iA \
    nixpkgs.hyprland \
    nixpkgs.waybar \
    nixpkgs.wofi \
    nixpkgs.alacritty \
    nixpkgs.swww \
    nixpkgs.brightnessctl \
    nixpkgs.pavucontrol \
    nixpkgs.dunst \
    nixpkgs.grim \
    nixpkgs.slurp \
    nixpkgs.wl-clipboard \
    nixpkgs.xdg-desktop-portal-hyprland

  $WITH_ROFI && nix-env -iA nixpkgs.rofi
  $WITH_MAKO && nix-env -iA nixpkgs.mako
}

# 🧾 Hyprland config
generate_hyprland_config() {
  local cfg="$CONFIG_HOME/hypr/hyprland.conf"
  mkdir -p "$(dirname "$cfg")"
  cat > "$cfg" <<'EOF'
exec-once = waybar &
exec-once = wofi --show drun &
exec-once = dunst &
exec-once = swww init &
exec-once = alacritty &
EOF
  echo "✅ Hyprland config written to $cfg"
}

# 🧾 Waybar config
generate_waybar_config() {
  local cfg="$CONFIG_HOME/waybar/config"
  mkdir -p "$(dirname "$cfg")"
  cat > "$cfg" <<'EOF'
{
  "layer": "top",
  "position": "top",
  "modules-left": ["hyprland/workspaces", "clock"],
  "modules-right": ["pulseaudio", "network", "battery"],
  "clock": { "format": "{:%H:%M}" },
  "battery": {
    "format": "{capacity}% {icon}",
    "states": { "warning": 20, "critical": 10 }
  }
}
EOF
  echo "✅ Waybar config written to $cfg"
}

# 🧾 Wofi config
generate_wofi_config() {
  local cfg="$CONFIG_HOME/wofi/config"
  mkdir -p "$(dirname "$cfg")"
  cat > "$cfg" <<'EOF'
show = drun
prompt = Wofi
width = 50%
height = 40%
location = center
allow_markup = true
EOF
  echo "✅ Wofi config written to $cfg"
}

# 🖼️ Wallpaper setup
setup_wallpaper() {
  local wallpaper="$HOME/Pictures/wallpaper.jpg"
  command -v swww >/dev/null || {
    echo "⚠️ swww not found. Skipping wallpaper setup."
    return
  }

  swww query || swww init
  [[ -f "$wallpaper" ]] && swww img "$wallpaper" --transition-type any \
    && echo "🖼️ Wallpaper set via swww." \
    || echo "⚠️ No wallpaper found at $wallpaper."
}

# 🚀 Hyprland launch script
generate_launcher() {
  local launcher="$HOME/start-hyprland.sh"
  cat > "$launcher" <<'EOF'
#!/usr/bin/env bash
export XDG_SESSION_TYPE=wayland
export GDK_BACKEND=wayland
exec Hyprland
EOF
  chmod +x "$launcher"
  echo "🚀 Launch Hyprland with: $launcher"
}

# 🧩 Run all steps
main() {
  check_requirements
  install_packages
  generate_hyprland_config
  generate_waybar_config
  generate_wofi_config
  setup_wallpaper
  generate_launcher
  echo "🎉 Hyprland setup complete!"
}

main "$@"

