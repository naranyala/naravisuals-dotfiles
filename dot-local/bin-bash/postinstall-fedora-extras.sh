#!/bin/bash

# Fedora Multimedia + Low-Level Programming Setup Script

set -e

echo "🔧 Starting Fedora post-install setup..."

# 1. Enable RPM Fusion repositories
echo "📦 Enabling RPM Fusion..."
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 2. Update system
echo "🔄 Updating system..."
sudo dnf upgrade -y

# 3. Multimedia setup
echo "🎬 Installing multimedia packages..."
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate -y sound-and-video
sudo dnf install -y vlc mpv gstreamer1-plugins-{base,good,bad-free,bad-freeworld,ugly} \
  gstreamer1-libav lame ffmpeg youtube-dl

# 4. Fonts and browser support
echo "🔤 Installing fonts and browser codecs..."
sudo dnf install -y curl cabextract xorg-x11-font-utils fontconfig
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
sudo dnf install -y chromium ffmpeg-libs

# 5. Low-level programming tools
echo "🧪 Installing low-level programming tools..."
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y \
  gcc gcc-c++ clang llvm lldb \
  make cmake ninja-build \
  gdb valgrind strace ltrace \
  binutils elfutils \
  nasm yasm \
  autoconf automake libtool \
  flex bison \
  rpm-build rpmdevtools \
  patch diffutils \
  git gitk tig \
  ctags cscope \
  glibc-devel glibc-static \
  kernel-devel kernel-headers

# 6. Optional: Embedded and cross-compilation tools
echo "🔌 Installing embedded dev tools..."
sudo dnf install -y \
  avr-gcc avr-binutils avrdude \
  arm-none-eabi-gcc arm-none-eabi-binutils \
  openocd

echo "✅ Setup complete! Your Fedora system is now ready for multimedia and low-level development."

