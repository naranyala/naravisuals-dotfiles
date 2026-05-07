#!/bin/bash

# Step 1: Check if Nushell is installed via Homebrew
if ! command -v nu &> /dev/null; then
    echo "❌ Nushell is not installed. Installing via Homebrew..."
    brew install nushell
else
    echo "✅ Nushell is already installed."
fi

# Step 2: Add redirection to .bashrc
BASHRC="$HOME/.bashrc"
REDIRECT_LINE='exec nu'

# Avoid adding the line if it's already present
if ! grep -Fxq "$REDIRECT_LINE" "$BASHRC"; then
    echo "🔧 Adding Nushell redirection to .bashrc..."
    echo "" >> "$BASHRC"
    echo "# Redirect to Nushell on Bash startup" >> "$BASHRC"
    echo "$REDIRECT_LINE" >> "$BASHRC"
else
    echo "ℹ️ Nushell redirection already present in .bashrc."
fi

echo "✅ Done. Open a new terminal and Bash will launch Nushell!"

