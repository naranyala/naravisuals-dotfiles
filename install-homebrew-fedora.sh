#!/usr/bin/env bash

set -e

echo "Updating system packages..."
sudo dnf5 -y upgrade

echo "Installing required dependencies..."
sudo dnf5 -y install curl file git ruby bzip2 gcc gcc-c++ make

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Adding Homebrew to PATH..."
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "Verifying installation..."
brew --version

echo "✅ Homebrew installation completed successfully!"

