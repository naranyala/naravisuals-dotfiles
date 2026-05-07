#!/usr/bin/env bash
set -euo pipefail

LOG_PREFIX="[minecraft-fedora]"
JAVA_VERSION="17"

log() { echo -e "$LOG_PREFIX $1"; }

install_java() {
  if java -version &>/dev/null; then
    log "Java already installed. Skipping."
  else
    log "Installing OpenJDK $JAVA_VERSION..."
    sudo dnf install -y java-${JAVA_VERSION}-openjdk java-${JAVA_VERSION}-openjdk-devel
  fi
}

verify_java() {
  log "Verifying Java installation..."
  java -version || { log "Java verification failed."; exit 1; }
}

install_prism_launcher() {
  if command -v prism-launcher &>/dev/null; then
    log "Prism Launcher already installed. Skipping."
  else
    log "Installing Prism Launcher..."
    sudo dnf install -y prism-launcher || {
      log "Prism Launcher not available in repo. Consider installing manually from: https://prismlauncher.org/download/"
    }
  fi
}

main() {
  log "Starting Minecraft setup for Fedora..."
  install_java
  verify_java
  install_prism_launcher
  log "✅ Setup complete. You can now launch Minecraft."
}

main

