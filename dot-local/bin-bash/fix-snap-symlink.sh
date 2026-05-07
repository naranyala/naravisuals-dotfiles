#!/usr/bin/env bash 

sudo pacman -Sy snapd # or apt or dnf or others

sudo ln -s /var/lib/snapd/snap /snap
