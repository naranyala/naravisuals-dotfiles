#!/bin/bash

set -e

# List of .NET SDK versions to try, newest first
VERSIONS=("10.0" "9.0" "8.0" "7.0" "6.0")

echo "Detecting package manager..."

if command -v apt >/dev/null 2>&1; then
    echo "APT detected."
    sudo apt update
    for ver in "${VERSIONS[@]}"; do
        echo "Trying to install dotnet-sdk-$ver..."
        if sudo apt install -y "dotnet-sdk-$ver"; then
            echo "Successfully installed dotnet-sdk-$ver"
            dotnet --version
            exit 0
        else
            echo "dotnet-sdk-$ver not available, downgrading..."
        fi
    done
elif command -v dnf >/dev/null 2>&1; then
    echo "DNF detected."
    for ver in "${VERSIONS[@]}"; do
        echo "Trying to install dotnet-sdk-$ver..."
        if sudo dnf install -y "dotnet-sdk-$ver"; then
            echo "Successfully installed dotnet-sdk-$ver"
            dotnet --version
            exit 0
        else
            echo "dotnet-sdk-$ver not available, downgrading..."
        fi
    done
else
    echo "No supported package manager detected (apt or dnf)."
    exit 1
fi

echo "No .NET SDK versions from ${VERSIONS[*]} could be installed."
exit 1

