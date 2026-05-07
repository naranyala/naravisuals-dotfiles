#!/usr/bin/env bash
# composer_installer.sh
# Fedora Linux script to install PHP Composer and core PHP tools (with intl)

set -euo pipefail

echo "=== PHP Composer & Tools Installer for Fedora ==="

# Step 1: Update system
echo "[1/4] Updating system packages..."
sudo dnf -y update

# Step 2: Install PHP and common extensions (including intl)
echo "[2/4] Installing PHP and useful extensions..."
sudo dnf install -y \
    php-cli \
    php-common \
    php-mbstring \
    php-xml \
    php-zip \
    php-json \
    php-curl \
    php-gd \
    php-intl \
    unzip wget curl git

# Step 3: Download and verify Composer installer
echo "[3/4] Downloading Composer installer..."
EXPECTED_SIGNATURE="$(curl -s https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    >&2 echo "ERROR: Invalid installer signature"
    rm composer-setup.php
    exit 1
fi
echo "Installer verified."

# Step 4: Install Composer globally
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php
echo "[4/4] Composer installed successfully!"
composer --version

echo "=== All done! PHP + Composer + intl extension are ready. ==="

