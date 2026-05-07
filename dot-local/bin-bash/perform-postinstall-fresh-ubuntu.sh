#!/bin/bash
# Ubuntu Post-Install Script with Credentials & Dev Tools
# Run: chmod +x postinstall.sh && ./postinstall.sh

set -e

echo "🔄 Updating system..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing essential packages..."
sudo apt install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    ufw \
    software-properties-common \
    unzip \
    gnupg \
    pkg-config \
    cmake \
    gdb \
    make \
    autoconf \
    automake \
    libtool \
    nasm \
    clang \
    valgrind

echo "📝 Enter your Git credentials..."
read -p "Git user name: " git_name
read -p "Git email: " git_email

git config --global user.name "$git_name"
git config --global user.email "$git_email"

echo "🔑 Do you want to generate a new SSH key? (y/n)"
read ssh_choice
if [[ "$ssh_choice" == "y" ]]; then
    read -p "Enter your email for SSH key: " ssh_email
    ssh-keygen -t ed25519 -C "$ssh_email"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    echo "📋 Your public key:"
    cat ~/.ssh/id_ed25519.pub
fi

echo "🛡️ Setting up firewall..."
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status

echo "📂 Creating workspace directory..."
mkdir -p ~/workspace

echo "📦 Installing Snap packages..."
sudo snap install code --classic
sudo snap install spotify

echo "📦 Installing Flatpak..."
sudo apt install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "✅ Post-install complete!"

