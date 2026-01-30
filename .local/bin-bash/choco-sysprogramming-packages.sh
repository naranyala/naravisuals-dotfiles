#!/usr/bin/env bash
set -euo pipefail

function install_pkg() {
    local pkg="$1"
    echo "------------------------------------------------------------"
    echo " Installing: $pkg"
    echo "------------------------------------------------------------"
    choco install "$pkg" -y --no-progress
}

if ! command -v choco >/dev/null 2>&1; then
    echo "Chocolatey is not installed."
    exit 1
fi

echo "Chocolatey detected. Starting mega installation..."

COMPILERS=(
    mingw llvm visualstudio2022buildtools windows-sdk-10-version-2104-all
    rustup.install zig go python nodejs openjdk dotnet-sdk
)

BUILD_SYSTEMS=(
    cmake ninja make meson bazel scons
)

DEBUG_TOOLS=(
    windbg sysinternals processhacker perfview procmon procexp
    latencymon debugview dependencywalker dependencies
)

REVERSE_ENGINEERING=(
    ghidra radare2 cutter ilspy dnspy apktool jd-gui
)

NETWORKING=(
    wireshark nmap tcpview fiddler mitmproxy openssl curl wget
)

VIRTUALIZATION=(
    docker-desktop qemu virtualbox vagrant
)

VERSION_CONTROL=(
    git git-lfs svn mercurial
)

CLI_UTILS=(
    jq fzf ripgrep fd 7zip psutils gawk sed grep coreutils
)

EDITORS=(
    vscode neovim notepadplusplus jetbrains-toolbox
)

WINDOWS_INTERNALS=(
    powershell-core wsl-ubuntu devtoys everything autoruns handle rammap disk2vhd
)

ALL_GROUPS=(
    "${COMPILERS[@]}"
    "${BUILD_SYSTEMS[@]}"
    "${DEBUG_TOOLS[@]}"
    "${REVERSE_ENGINEERING[@]}"
    "${NETWORKING[@]}"
    "${VIRTUALIZATION[@]}"
    "${VERSION_CONTROL[@]}"
    "${CLI_UTILS[@]}"
    "${EDITORS[@]}"
    "${WINDOWS_INTERNALS[@]}"
)

for pkg in "${ALL_GROUPS[@]}"; do
    install_pkg "$pkg"
done

echo "============================================================"
echo " Mega system programming environment installed successfully."
echo "============================================================"

