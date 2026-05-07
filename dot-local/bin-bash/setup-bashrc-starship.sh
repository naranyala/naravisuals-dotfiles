#!/bin/bash

# Step 1: Install Starship if not already installed
if ! command -v starship &> /dev/null; then
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "Starship is already installed."
fi

# Step 2: Add Starship init to .bashrc if not already present
BASHRC="$HOME/.bashrc"
INIT_LINE='eval "$(starship init bash)"'

if ! grep -Fxq "$INIT_LINE" "$BASHRC"; then
    echo "Adding Starship init to .bashrc..."
    echo "" >> "$BASHRC"
    echo "# Initialize Starship prompt" >> "$BASHRC"
    echo "$INIT_LINE" >> "$BASHRC"
else
    echo "Starship init already present in .bashrc."
fi

# Step 3: Reload .bashrc
echo "Reloading .bashrc..."
source "$BASHRC"

echo "✅ Starship setup complete. Open a new terminal to see the prompt!"

