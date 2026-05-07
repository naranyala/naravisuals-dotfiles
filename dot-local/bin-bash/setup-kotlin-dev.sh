#!/usr/bin/env bash
# dev-setup-fedora.sh
# Modular Kotlin + JVM development environment setup for Fedora Linux
# Version: 1.1 (no logging)

set -euo pipefail

install_core() {
    echo "🔄 Updating system packages..."
    sudo dnf update -y

    echo "☕ Installing Java (OpenJDK 17)..."
    sudo dnf install -y java-17-openjdk java-17-openjdk-devel

    echo "📦 Installing Kotlin..."
    sudo dnf install -y kotlin

    echo "⚙ Installing Gradle..."
    sudo dnf install -y gradle

    echo "📂 Installing Git..."
    sudo dnf install -y git
}

install_optional_tools() {
    echo "🛠 Installing Detekt (Kotlin linter)..."
    sudo dnf install -y detekt || echo "⚠ Detekt not found in repo, consider manual install."

    echo "💡 Installing IntelliJ IDEA Community Edition..."
    sudo dnf install -y intellij-idea-community || echo "⚠ IntelliJ not found in repo, consider JetBrains Toolbox."
}

verify_install() {
    echo "✅ Verifying installations..."
    java -version
    kotlinc -version
    gradle -v
    git --version
}

main() {
    echo "🚀 Starting Fedora Kotlin Dev Environment Setup"
    install_core
    install_optional_tools
    verify_install
    echo "🎉 Setup complete!"
}

main "$@"

