#!/bin/bash

# --- Configuration ---
# Set the desired installation path for Homebrew.
# By default, Homebrew installs to /home/linuxbrew/.linuxbrew
# You can change this if you have specific reasons, but be aware of permissions.
# HOMEBREW_PREFIX="/usr/local" # Example: installing to /usr/local, requires sudo for setup
HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew" # Recommended default

# --- Pre-installation Checks ---

echo "Checking for existing Homebrew installation..."
if command -v brew &> /dev/null; then
    echo "Homebrew is already installed. Exiting."
    exit 0
fi

# --- Install Dependencies ---

echo "Installing essential dependencies..."
# These dependencies are generally required for Homebrew and many packages.
# The exact package names might vary slightly between distributions (e.g., apt vs. yum vs. dnf).

# Check for apt (Debian/Ubuntu)
if command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y build-essential procps curl file git
elif command -v yum &> /dev/null; then # Check for yum (CentOS/RHEL older)
    sudo yum check-update
    sudo yum install -y build-essential procps curl file git
elif command -v dnf &> /dev/null; then # Check for dnf (Fedora/RHEL newer)
    sudo dnf check-update
    sudo dnf install -y @development-tools procps curl file git
elif command -v pacman &> /dev/null; then # Check for pacman (Arch Linux)
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm base-devel procps curl file git
else
    echo "Unsupported package manager. Please manually install: build-essential, procps, curl, file, git."
    echo "Exiting."
    exit 1
fi

# --- Install Homebrew ---

echo "Downloading and installing Homebrew..."
# The official Homebrew installation script.
# This script automatically handles setting up the environment variables.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# --- Post-installation Setup ---

echo "Setting up Homebrew environment variables..."
# Homebrew requires its bin directory to be in your PATH.
# The installer typically adds this to your shell's profile file (.bashrc, .zshrc, etc.).
# We'll explicitly add it here for the current session and also suggest adding it to the profile.

# Determine the correct profile file based on the current shell
SHELL_RC_FILE=""
if [ -n "$BASH_VERSION" ]; then
    SHELL_RC_FILE="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_RC_FILE="$HOME/.zshrc"
else
    echo "Could not determine shell type. Please manually add Homebrew to your PATH."
    echo 'export PATH="$HOMEBREW_PREFIX/bin:$PATH"'
    echo 'export PATH="$HOMEBREW_PREFIX/sbin:$PATH"'
fi

if [ -n "$SHELL_RC_FILE" ]; then
    echo "Adding Homebrew to PATH in $SHELL_RC_FILE (if not already present)..."
    # Ensure the lines are added only if they don't exist
    grep -qxF 'eval "$('$HOMEBREW_PREFIX'/bin/brew shellenv)"' "$SHELL_RC_FILE" || \
    echo 'eval "$('$HOMEBREW_PREFIX'/bin/brew shellenv)"' >> "$SHELL_RC_FILE"

    echo "Source your shell configuration file or open a new terminal for changes to take effect:"
    echo "  source $SHELL_RC_FILE"
fi

# For the current session
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

# --- Verification ---

echo "Verifying Homebrew installation..."
brew doctor

echo "Homebrew installation script finished."
echo "Remember to open a new terminal or run 'source $SHELL_RC_FILE' to use brew commands."
