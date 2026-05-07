#!/usr/bin/env bash
# Fix Neovim "clipboard: no provider" error
# Auto-detects environment and installs/configures the right clipboard tool

set -euo pipefail

rollback() {
  echo "❌ Something went wrong. Rolling back..."
  # Add rollback logic if needed (e.g., uninstall packages)
}

trap rollback ERR

detect_env() {
  if command -v pbcopy &>/dev/null; then
    echo "macos"
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    echo "wsl"
  elif [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    echo "wayland"
  elif [ "${XDG_SESSION_TYPE:-}" = "x11" ] || command -v xclip &>/dev/null || command -v xsel &>/dev/null; then
    echo "x11"
  else
    echo "unknown"
  fi
}

install_clipboard_tool() {
  local env="$1"
  case "$env" in
    macos)
      echo "✅ macOS detected. Clipboard provider (pbcopy/pbpaste) already available."
      ;;
    x11)
      echo "🖼 X11 detected. Installing xclip..."
      if command -v apt &>/dev/null; then
        sudo apt install -y xclip
      elif command -v dnf &>/dev/null; then
        sudo dnf install -y xclip
      elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm xclip
      fi
      ;;
    wayland)
      echo "🌊 Wayland detected. Installing wl-clipboard..."
      if command -v apt &>/dev/null; then
        sudo apt install -y wl-clipboard
      elif command -v dnf &>/dev/null; then
        sudo dnf install -y wl-clipboard
      elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm wl-clipboard
      fi
      ;;
    wsl)
      echo "🪟 WSL detected. Configuring Neovim clipboard provider..."
      mkdir -p ~/.config/nvim
      cat > ~/.config/nvim/lua/wsl_clipboard.lua <<'EOF'
vim.g.clipboard = {
  name = 'WslClipboard',
  copy = {
    ['+'] = 'clip.exe',
    ['*'] = 'clip.exe',
  },
  paste = {
    ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
  },
  cache_enabled = 0,
}
EOF
      echo "✅ WSL clipboard config written to ~/.config/nvim/lua/wsl_clipboard.lua"
      ;;
    *)
      echo "⚠️ Unknown environment. Please install a clipboard tool manually."
      ;;
  esac
}

main() {
  env=$(detect_env)
  echo "Detected environment: $env"
  install_clipboard_tool "$env"
  echo "🎉 Done! Run ':checkhealth provider' in Neovim to verify."
}

main "$@"

