#!/bin/bash

# =============================================================================
# Minimal C++ Dev Setup (Debian/Ubuntu)
# Installs: g++, clang, cmake, make, git, gdb, valgrind, clang-tools
# Usage: chmod +x setup_cpp.sh && sudo ./setup_cpp.sh
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log()   { echo -e "${GREEN}[✔] $1${NC}"; }
warn()  { echo -e "${YELLOW}[!] $1${NC}"; }
error() { echo -e "${RED}[✗] $1${NC}" >&2; exit 1; }
step()  { echo ""; log "$1"; }

# -----------------------------------------------------------------------------
step "Updating package list"
apt update || error "Failed to update package list"

# -----------------------------------------------------------------------------
step "Installing essential C++ tools"
PACKAGES=(
    build-essential  # g++, make, etc.
    clang
    cmake
    git
    gdb
    valgrind
    lcov
    cppcheck
    clang-format
    clang-tidy
    clangd
    doxygen
    graphviz
)


if ! apt install -y "${PACKAGES[@]}" 2>/dev/null; then
    error "Failed to install required packages. Check your internet connection or package sources."
fi

# -----------------------------------------------------------------------------
step "Verifying key tools are installed"
for cmd in g++ clang++ cmake make gdb git; do
    if ! command -v "$cmd" &> /dev/null; then
        error "Expected command '$cmd' is missing after installation."
    fi
done

# -----------------------------------------------------------------------------
step "Setup complete"
cat << EOF

🎉 C++ development environment is ready!

🛠️  Tools installed:
   • Compiler: g++, clang
   • Build: make, cmake
   • Debug: gdb, valgrind
   • Lint/Format: clang-format, clang-tidy, cppcheck
   • Docs: doxygen
   • Version Control: git

💡 Try: g++ --version
💡 Tip: Use 'clang-format -i file.cpp' to format code.

Happy coding! 🚀
EOF
