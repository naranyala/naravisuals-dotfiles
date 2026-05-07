#!/usr/bin/env bash
set -e

# 🧩 Step 1: Install system dependencies
echo "Installing OpenJDK, Git, Gradle..."
sudo apt update
sudo apt install -y openjdk-21-jdk git gradle curl unzip

# 🧩 Step 2: Install Kotlin via SDKMAN
echo "Installing SDKMAN and Kotlin..."
if [ ! -d "$HOME/.sdkman" ]; then
  curl -s "https://get.sdkman.io" | bash
fi
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install kotlin

# 🧩 Step 3: Clone and build Kotlin Language Server
echo "Cloning kotlin-language-server..."
git clone https://github.com/fwcd/kotlin-language-server.git
cd kotlin-language-server
./gradlew :server:installDist

# 🧩 Step 4: Optional – Add to PATH
echo "To run the language server, add to PATH:"
echo "export PATH=\"$(pwd)/server/build/install/server/bin:\$PATH\""

echo -e "\n✅ Kotlin Language Server is set up!"

