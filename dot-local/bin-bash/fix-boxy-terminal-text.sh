#!/usr/bin/env bash
# fix-terminal-emoji.sh
# Purpose: Ensure UTF-8 locale, install emoji fonts, configure fallback, refresh cache

set -euo pipefail

### CONFIG ###
LOCALE="en_US.UTF-8"
FONTS_DIR="$HOME/.local/share/fonts"
FONTCONFIG_DIR="$HOME/.config/fontconfig"
FONTCONFIG_FILE="$FONTCONFIG_DIR/fonts.conf"

### FUNCTIONS ###

check_locale() {
    echo "[*] Checking locale..."
    if ! locale | grep -q "$LOCALE"; then
        echo "[-] Locale $LOCALE not set. Attempting to configure..."
        if command -v localectl >/dev/null 2>&1; then
            sudo localectl set-locale LANG=$LOCALE
        else
            echo "LANG=$LOCALE" | sudo tee -a /etc/environment
        fi
        echo "[+] Locale set to $LOCALE. Please re-login after script finishes."
    else
        echo "[+] Locale already set to $LOCALE"
    fi
}

install_fonts() {
    echo "[*] Installing emoji fonts..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y fonts-noto-color-emoji fonts-noto fonts-firacode
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y google-noto-emoji-color-fonts fira-code-fonts
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm noto-fonts-emoji ttf-fira-code
    else
        echo "[-] Package manager not detected. Installing Nerd Fonts manually..."
        mkdir -p "$FONTS_DIR"
        cd "$FONTS_DIR"
        curl -fLo "FiraCode.zip" \
          https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
        unzip -o FiraCode.zip
        rm FiraCode.zip
    fi
}

configure_fontconfig() {
    echo "[*] Configuring font fallback..."
    mkdir -p "$FONTCONFIG_DIR"
    cat > "$FONTCONFIG_FILE" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
EOF
    echo "[+] Fontconfig fallback set to Noto Color Emoji"
}

refresh_cache() {
    echo "[*] Refreshing font cache..."
    fc-cache -f -v
    echo "[+] Font cache refreshed"
}

test_output() {
    echo "[*] Testing emoji rendering..."
    echo "🚀 ✅ 🔥 🍀 ☠️ 🐧"
}

### MAIN ###
check_locale
install_fonts
configure_fontconfig
refresh_cache
test_output

echo "[✓] All done. Restart your terminal to apply changes."

