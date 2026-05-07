#!/usr/bin/env bash
# Setup Compiz on MATE to mimic Windows workflow & keybindings
# Supports Debian/Ubuntu and Fedora/RHEL-based distros
# Adds hot corners: bottom-left = Scale (all windows), bottom-right = Expo (all workspaces)

set -e

echo "=== Detecting distribution ==="
if command -v apt >/dev/null 2>&1; then
    DISTRO="debian"
elif command -v dnf >/dev/null 2>&1; then
    DISTRO="fedora"
else
    echo "Unsupported distribution. Only Debian/Ubuntu or Fedora/RHEL are supported."
    exit 1
fi
echo "Detected: $DISTRO"

echo "=== Installing Compiz & tools ==="
if [ "$DISTRO" = "debian" ]; then
    sudo apt update
    sudo apt install -y compiz compiz-plugins compiz-plugins-extra compizconfig-settings-manager mate-tweak dconf-cli
elif [ "$DISTRO" = "fedora" ]; then
    sudo dnf install -y --skip-unavailable compiz compiz-plugins-main compiz-plugins-extra ccsm mate-tweak dconf
fi

echo "=== Switching MATE to use Compiz ==="
dconf write /org/mate/desktop/session/required-components/windowmanager "'compiz'"

echo "=== Resetting Compiz profile to defaults ==="
dconf reset -f /org/compiz/

echo "=== Enabling core plugins ==="
plugins=(
  core
  move
  resize
  place
  decoration
  commands
  grid
  scale
  expo
  application-switcher
  shift
  showdesktop
)

for p in "${plugins[@]}"; do
  dconf write /org/compiz/profiles/unity/plugins/$p/active true || true
done

echo "=== Setting Windows-like keybindings ==="
# Show Desktop: Win+D
dconf write /org/compiz/profiles/unity/plugins/showdesktop/initiate "'<Super>d'"

# Alt+Tab: Application Switcher
dconf write /org/compiz/profiles/unity/plugins/application-switcher/next_window "'<Alt>Tab'"

# Win+Tab: Shift Switcher
dconf write /org/compiz/profiles/unity/plugins/shift/initiate_all "'<Super>Tab'"

# Snap Left/Right/Maximize: Win+Arrows
dconf write /org/compiz/profiles/unity/plugins/grid/put_left_key "'<Super>Left'"
dconf write /org/compiz/profiles/unity/plugins/grid/put_right_key "'<Super>Right'"
dconf write /org/compiz/profiles/unity/plugins/grid/maximize_key "'<Super>Up'"

# Close Window: Alt+F4
dconf write /org/compiz/profiles/unity/plugins/core/close_window_key "'<Alt>F4'"

# Win+E: File Manager
dconf write /org/compiz/profiles/unity/plugins/commands/command0 "'caja'"
dconf write /org/compiz/profiles/unity/plugins/commands/run_command0_key "'<Super>e'"

# Win+R: Run Dialog
dconf write /org/compiz/profiles/unity/plugins/commands/command1 "'mate-panel --run-dialog'"
dconf write /org/compiz/profiles/unity/plugins/commands/run_command1_key "'<Super>r'"

# Win+L: Lock Screen
dconf write /org/compiz/profiles/unity/plugins/commands/command2 "'mate-screensaver-command -l'"
dconf write /org/compiz/profiles/unity/plugins/commands/run_command2_key "'<Super>l'"

# Alt+Space: Window Menu
dconf write /org/compiz/profiles/unity/plugins/core/show_window_menu_key "'<Alt>space'"

echo "=== Setting Expo & Scale keybindings ==="
# Expo: Ctrl+Win+Up
dconf write /org/compiz/profiles/unity/plugins/expo/expo_key "'<Control><Super>Up'"
# Scale: Win+W
dconf write /org/compiz/profiles/unity/plugins/scale/initiate_all_key "'<Super>w'"

echo "=== Configuring hot corners ==="
# Bottom-left corner → Scale (all windows)
dconf write /org/compiz/profiles/unity/plugins/scale/initiate_all_edge "'BottomLeft'"

# Bottom-right corner → Expo (all workspaces)
dconf write /org/compiz/profiles/unity/plugins/expo/expo_edge "'BottomRight'"

echo "=== Disabling flashy effects for clean Windows feel ==="
dconf write /org/compiz/profiles/unity/plugins/wobbly/active false || true
dconf write /org/compiz/profiles/unity/plugins/cube/active false || true
dconf write /org/compiz/profiles/unity/plugins/animations/active false || true

echo "=== Done! ==="
echo "Log out and log back in to apply all changes."

