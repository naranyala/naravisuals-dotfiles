#!/usr/bin/env bash
set -e

echo "🔑 Importing GPG key (dearmored)..."
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/sublimehq-archive-keyring.gpg > /dev/null

echo "📦 Adding Sublime Text repository..."
echo "deb [signed-by=/usr/share/keyrings/sublimehq-archive-keyring.gpg] https://download.sublimetext.com/ apt/stable/" | \
  sudo tee /etc/apt/sources.list.d/sublime-text.list

echo "🔄 Updating package list..."
sudo apt-get update

echo "🚀 Installing Sublime Text..."
sudo apt-get install -y sublime-text

echo "✅ Done! You can launch Sublime with 'subl'"

