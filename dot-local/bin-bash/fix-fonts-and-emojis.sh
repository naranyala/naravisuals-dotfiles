#!/usr/bin/env bash
set -euo pipefail

# 🗃️ Ensure required directories exist
mkdir -p ~/.local/share/fonts ~/.config/fontconfig/conf.d

# 🎨 Install emoji font
echo "📥 Installing Noto Color Emoji font..."
sudo apt update
sudo apt install -y fonts-noto-color-emoji

# 🛠️ Set up font fallback for emoji
EMOJI_CONF=~/.config/fontconfig/conf.d/01-emoji.conf
echo "📝 Configuring font fallback..."
cat > "$EMOJI_CONF" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="pattern">
    <test name="family"><string>Emoji</string></test>
    <edit name="family" mode="assign"><string>Noto Color Emoji</string></edit>
  </match>
</fontconfig>
EOF

# 🔠 Coding fonts (install to ~/.local/share/fonts)
FONT_URLS=(
  "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"
  "https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip"
  "https://github.com/microsoft/cascadia-code/releases/download/v2404.23/CascadiaCode-2404.23.zip"
)

echo "📥 Downloading and extracting coding fonts..."
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

for URL in "${FONT_URLS[@]}"; do
  ZIP=$(basename "$URL")
  wget -q "$URL" -O "$ZIP"
  unzip -q "$ZIP"
done

# 🎯 Move font files to ~/.local/share/fonts
find . -type f \( -iname "*.ttf" -o -iname "*.otf" \) -exec mv {} ~/.local/share/fonts/ \;

# 🧹 Clean up
cd ~
rm -rf "$TMPDIR"

# 🔄 Refresh font cache
echo "🔄 Rebuilding font cache..."
fc-cache -fv

echo "✅ Emoji and coding fonts installed successfully!"
echo "🧪 Try: echo -e \"😀 🚀 🎯\" in your terminal to test emoji support."

