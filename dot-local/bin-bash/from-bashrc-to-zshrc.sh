#!/bin/bash

# Exit on error
set -e

echo "🔧 Installing Zsh..."
if ! command -v zsh &> /dev/null; then
  sudo apt update && sudo apt install -y zsh
else
  echo "✅ Zsh already installed."
fi

echo "🌟 Installing Starship..."
if ! command -v starship &> /dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
else
  echo "✅ Starship already installed."
fi

ZSH_PATH="$(which zsh)"

echo "📁 Ensuring Zsh is listed in /etc/shells..."
if ! grep -q "$ZSH_PATH" /etc/shells; then
  echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

echo "🔄 Setting Zsh as default shell for user: $USER"
if [ "$SHELL" != "$ZSH_PATH" ]; then
  chsh -s "$ZSH_PATH"
  echo "✅ Default shell changed to Zsh. Please log out and back in for changes to take effect."
else
  echo "✅ Zsh is already your default shell."
fi

echo "📄 Creating ~/.zshrc..."
cat << 'EOF' > ~/.zshrc
# Load bashrc content
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

# Initialize Starship prompt
eval "$(starship init zsh)"
EOF

echo "✅ Setup complete! Run 'zsh' or restart your terminal to start using Zsh with Starship."

