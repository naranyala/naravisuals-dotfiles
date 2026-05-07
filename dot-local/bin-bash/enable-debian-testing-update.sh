#!/usr/bin/bash 

echo "deb http://deb.debian.org/debian testing main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list.d/testing.list
sudo apt update

