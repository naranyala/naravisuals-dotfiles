#!/bin/bash

# --- Color Definitions ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Arch-Cosmic Post-Install Automator${NC}"
echo -e "Based on: https://pedrotchang.dev/posts/arch-cosmic/\n"

# 1. Update System
echo -e "${GREEN}[1/4] Updating system repositories...${NC}"
sudo pacman -Syyu --noconfirm

# 2. Install Core Cosmic Packages & Missing Essentials
# The article mentions archinstall often misses xdg-user-dirs and power-profiles
echo -e "${GREEN}[2/4] Installing COSMIC session and essential utilities...${NC}"
sudo pacman -S --needed --noconfirm \
    cosmic-session \
    cosmic-applets \
    cosmic-bg \
    cosmic-comp \
    cosmic-control-center \
    cosmic-files \
    cosmic-greeter \
    cosmic-icons \
    cosmic-launcher \
    cosmic-notifications \
    cosmic-osd \
    cosmic-panel \
    cosmic-screenshots \
    cosmic-settings \
    cosmic-term \
    cosmic-wallpapers \
    xdg-user-dirs \
    power-profiles-daemon

# 3. Enable Services
echo -e "${GREEN}[3/4] Enabling system services...${NC}"
sudo systemctl enable power-profiles-daemon.service
xdg-user-dirs-update

# 4. Display Manager (Greeter) Setup
# Per the article, the Cosmic Greeter (greetd) often needs a specific config
# if not handled by archinstall.
echo -e "${GREEN}[4/4] Configuring the Login Manager (Cosmic Greeter)...${NC}"

if pacman -Qs greetd > /dev/null; then
    echo "Configuring greetd to use cosmic-greeter..."
    # Ensure the config directory exists
    sudo mkdir -p /etc/greetd

    # Create the standard greetd configuration for Cosmic
    sudo bash -c 'cat > /etc/greetd/config.toml <<EOF
[default_session]
command = "cosmic-greeter"
user = "_greetd"
EOF'

    sudo systemctl enable greetd.service
    echo "Greetd enabled with Cosmic Greeter."
else
    echo -e "${RED}Warning: greetd not found. If you use GDM/SDDM, select COSMIC at login.${NC}"
fi

echo -e "\n${BLUE}Installation complete!${NC}"
echo -e "Note: If you are on NVIDIA, ensure you have 'nvidia-drm.modeset=1' in your boot parameters."
echo -e "Reboot now to enter your new COSMIC environment."
