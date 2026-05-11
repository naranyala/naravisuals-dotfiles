#!/usr/bin/env bash
set -euo pipefail

trap 'echo "❌ Error occurred at line $LINENO"; exit 1' ERR

# Prevent running as root
if [[ $EUID -eq 0 ]]; then
    echo "⚠️ Do not run this script as root."
    echo "👉 Please run it as a normal user (the script will use sudo when needed)."
    exit 1
fi

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
else
    echo "❌ No supported package manager found (apt or dnf)."
    exit 1
fi

echo "✅ Using $PKG_MANAGER package manager..."

# Package lists
PACKAGES_APT=(wget curl unzip libgl1 libglu1-mesa libxi6 libxrender1 libxtst6)
PACKAGES_DNF=(wget curl unzip mesa-libGL mesa-libGLU libXi libXrender libXtst)

install_packages() {
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt update
        sudo apt install -y "${PACKAGES_APT[@]}" || true
        if ! sudo apt install -y openjdk-17-jdk openjdk-17-jre; then
            echo "⚠️ openjdk-17 not found in apt, downloading tarball..."
            download_java_tarball
        fi
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        sudo dnf install -y "${PACKAGES_DNF[@]}" || true
        if ! sudo dnf install -y java-17-openjdk java-17-openjdk-devel; then
            echo "⚠️ java-17-openjdk not found in dnf, downloading tarball..."
            download_java_tarball
        fi
    fi
}

download_java_tarball() {
    JDK_URL="https://download.oracle.com/java/17/archive/jdk-17.0.12_linux-x64_bin.tar.gz"
    DEST_DIR="$HOME/Downloads"
    DEST_FILE="$DEST_DIR/java17.tar.gz"

    mkdir -p "$DEST_DIR"

    if [[ -f "$DEST_FILE" ]]; then
        echo "📂 Found existing Java tarball at $DEST_FILE, skipping download."
    else
        echo "⬇️ Downloading Java 17 from Oracle..."
        echo "👉 URL: $JDK_URL"
        wget --show-progress -O "$DEST_FILE" "$JDK_URL"
    fi

    echo "📂 Extracting Java 17..."
    tar -xvzf "$DEST_FILE" -C "$DEST_DIR"

    echo "📦 Installing Java 17 to /usr/local/java17..."
    sudo rm -rf /usr/local/java17
    sudo mv "$DEST_DIR"/jdk-17.* /usr/local/java17

    echo "🔧 Configuring environment variables..."
    if ! grep -q "JAVA_HOME=/usr/local/java17" ~/.bashrc; then
        echo 'export JAVA_HOME=/usr/local/java17' >> ~/.bashrc
        echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
    fi

    # Safe sourcing of user bashrc only
    set +u
    source ~/.bashrc
    set -u

    echo "✅ Java installation complete!"
    java -version
}

check_existing_java() {
    if [[ -x "/usr/local/java17/bin/java" ]]; then
        echo "✅ Java already installed at /usr/local/java17, skipping reinstallation."
        /usr/local/java17/bin/java -version
        return 0
    fi
    return 1
}

echo "📦 Installing Java + Minecraft dependencies..."
if ! check_existing_java; then
    install_packages
fi
echo "🎉 Setup complete! You’re ready to run Minecraft."

