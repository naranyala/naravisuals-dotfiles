#!/usr/bin/env bash
#
# install-packages.sh
# Install a global collection of Fedora development packages for C programming.
# Usage: ./install-packages.sh

set -euo pipefail

# Global package collection
PACKAGES="
  # Core compilers and toolchain
  gcc gcc-c++ clang llvm make cmake ninja-build

  # Autotools and build helpers
  autoconf automake libtool pkg-config meson

  # Debugging and profiling
  gdb valgrind strace ltrace perf systemtap
  elfutils elfutils-libelf-devel

  # Libraries and headers
  glibc-devel glibc-static libstdc++-devel
  zlib-devel openssl-devel libffi-devel
  bzip2-devel xz-devel

  # Code analysis and linting
  cppcheck clang-tools-extra
  ctags cscope

  # Productivity / utilities
  git wget curl unzip tar htop tree ripgrep silversearcher-ag
"

echo "Installing global development packages:"
echo "$PACKAGES"

# Use --skip-unavailable to avoid errors if some packages are missing
sudo dnf install -y --skip-unavailable $PACKAGES

