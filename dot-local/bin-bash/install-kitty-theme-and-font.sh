#!/bin/bash

# 🖋️ Font setup
FONT_NAME="FiraCode"
VERSION="v3.2.1"
ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${VERSION}/${FONT_NAME}.zip"
FONT_DIR="${HOME}/.local/share/fonts/${FONT_NAME}"

# 🎨 Theme setup
THEME_NAME="OneDark"
THEME_REPO="https://github.com/dexpota/kitty-themes"
KITTY_CONFIG="${HOME}/.config/kitty"
KITTY_CONF="${KITTY_CONFIG}/kitty.conf"
THEME_CONF="${KITTY_CONFIG}/theme.conf"

# 📦 Check dependencies
for cmd in wget unzip fc-cache git; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Missing dependency: $cmd"
    exit 1
  fi
done

# 📁 Font install (skip if already present)
if [ -d "$FONT_DIR" ] && [ "$(ls -A "$FONT_DIR")" ]; then
  echo "✅ Font already installed at $FONT_DIR, skipping download."
else
  mkdir -p "$FONT_DIR"
  wget -O /tmp/${FONT_NAME}.zip "$ZIP_URL"
  unzip -o /tmp/${FONT_NAME}.zip -d "$FONT_DIR"
  rm /tmp/${FONT_NAME}.zip
  fc-cache -fv "$FONT_DIR"
fi

# 🐱 Kitty config directory
mkdir -p "$KITTY_CONFIG"

# 🎨 Clone theme repo and link theme
if [ ! -d "${KITTY_CONFIG}/kitty-themes" ]; then
  git clone --depth 1 "$THEME_REPO" "${KITTY_CONFIG}/kitty-themes"
fi
ln -sf "${KITTY_CONFIG}/kitty-themes/themes/${THEME_NAME}.conf" "$THEME_CONF"

# 🧾 Generate kitty.conf
cat > "$KITTY_CONF" <<EOF
# ~/.config/kitty/kitty.conf

font_family      FiraCode Nerd Font Mono
font_size        12.0

include ./theme.conf

window_margin_width     0
window_border_width     0
active_border_color     #44ffff
background_tint         0.97

cursor_shape            block
cursor_blink_interval   0

copy_on_select          yes
url_color               #0087BD
url_style               curly

enable_audio_bell       no
visual_bell_duration    0.0
window_alert_on_bell    yes

repaint_delay           10
sync_to_monitor         no
EOF

echo "🎉 Kitty config and theme setup complete!"

