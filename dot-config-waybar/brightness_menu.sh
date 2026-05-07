#!/usr/bin/env bash

# Check if brightnessctl is installed
if ! command -v brightnessctl &> /dev/null; then
    echo "brightnessctl is not installed. Please add it to your system configuration (e.g., NixOS configuration.nix)." | fuzzel --dmenu -p "Error: "
    exit 1
fi

# Define common options, but fuzzel allows the user to type a specific value
options="5%\n10%\n15%\n20%\n25%\n30%\n35%\n40%\n45%\n50%\n55%\n60%\n65%\n70%\n75%\n80%\n85%\n90%\n95%\n100%"

# Use fuzzel to pick a value
chosen=$(echo -e "$options" | fuzzel --dmenu -p "Brightness: ")

if [ -n "$chosen" ]; then
    # Append % if the user just typed a number
    if [[ ! "$chosen" =~ %$ ]]; then
        chosen="${chosen}%"
    fi
    
    # Validate that the input is a number between 0 and 100
    if [[ "$chosen" =~ ^[0-9]+%$ ]]; then
        # Remove % for numeric comparison
        val=${chosen%\%}
        if [ "$val" -ge 0 ] && [ "$val" -le 100 ]; then
            brightnessctl set "$chosen"
        fi
    fi
fi
