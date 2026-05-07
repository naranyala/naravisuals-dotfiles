#!/usr/bin/env bash
# Compact Swift installer for Arch Linux
set -euo pipefail

echo "Swift Installation Methods:"
echo "1. Swiftly (recommended)"
echo "2. Official tarball"
echo "3. Docker"
read -p "Choice (1-3): " c

case $c in
    1)
        curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz
        tar zxf swiftly-*.tar.gz && ./swiftly init
        echo 'source "$HOME/.local/share/swiftly/env.sh"' >> ~/.bashrc
        source ~/.local/share/swiftly/env.sh
        swiftly install latest
        rm swiftly-*.tar.gz
        ;;
    2)
        sudo pacman -S --needed --noconfirm git gnupg curl binutils
        V="6.1.2"; P="ubi9"
        T="swift-${V}-RELEASE-${P}.tar.gz"
        curl -O "https://download.swift.org/swift-${V}-release/${P}/swift-${V}-RELEASE/${T}"
        curl -O "https://download.swift.org/swift-${V}-release/${P}/swift-${V}-RELEASE/${T}.sig"
        gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys \
            'A62AE125BBBFBB96A6E042EC925CC1CCED3D1561' \
            '8A7495662C3CD4AE18D95637FAF6989E1BC16FEA'
        gpg --verify "${T}.sig" "$T"
        sudo tar -xzf "$T" -C /opt
        sudo ln -sf "/opt/swift-${V}-RELEASE-${P}" /opt/swift
        echo 'export PATH="/opt/swift/usr/bin:$PATH"' >> ~/.bashrc
        rm "$T" "${T}.sig"
        ;;
    3)
        sudo pacman -S --needed --noconfirm docker
        sudo systemctl enable --now docker
        sudo usermod -aG docker "$USER"
        docker pull swift:latest
        echo '#!/bin/bash' > ~/swift-docker
        echo 'docker run --rm -it -v "$PWD:/workspace" -w /workspace swift:latest swift "$@"' >> ~/swift-docker
        chmod +x ~/swift-docker
        echo "Use: docker run -it swift:latest bash"
        ;;
    *)
        echo "Invalid choice"; exit 1;;
esac

echo "✅ Done! Run: source ~/.bashrc"
command -v swift &>/dev/null && swift --version || echo "Restart terminal to use Swift"
