#!/usr/bin/env bash
# Emergency Display Manager Recovery Script
set -euo pipefail

### EMERGENCY RECOVERY ###
emergency_recovery() {
    echo "🚨 EMERGENCY RECOVERY MODE"
    echo "This will attempt to restore a working display manager"
    
    # Stop all display manager services
    echo "🛑 Stopping all display manager services..."
    sudo systemctl stop lightdm.service 2>/dev/null || true
    sudo systemctl stop sddm.service 2>/dev/null || true
    sudo systemctl stop gdm3.service 2>/dev/null || true
    sudo systemctl stop gdm.service 2>/dev/null || true
    
    # Disable all display manager services
    echo "🔄 Disabling all display manager services..."
    sudo systemctl disable lightdm.service 2>/dev/null || true
    sudo systemctl disable sddm.service 2>/dev/null || true
    sudo systemctl disable gdm3.service 2>/dev/null || true
    sudo systemctl disable gdm.service 2>/dev/null || true
    
    # Check which display managers are actually installed
    echo "🔍 Checking installed display managers..."
    
    local available_dms=()
    
    if command -v lightdm >/dev/null 2>&1; then
        available_dms+=("lightdm")
        echo "  ✅ LightDM found"
    fi
    
    if command -v sddm >/dev/null 2>&1; then
        available_dms+=("sddm")
        echo "  ✅ SDDM found"
    fi
    
    if command -v gdm3 >/dev/null 2>&1; then
        available_dms+=("gdm3")
        echo "  ✅ GDM3 found"
    elif command -v gdm >/dev/null 2>&1; then
        available_dms+=("gdm")
        echo "  ✅ GDM found"
    fi
    
    if [[ ${#available_dms[@]} -eq 0 ]]; then
        echo "❌ No display managers found installed!"
        install_fallback_dm
        return
    fi
    
    # Try each available DM until one works
    for dm in "${available_dms[@]}"; do
        echo "🔄 Attempting to enable $dm..."
        if sudo systemctl enable "$dm.service" 2>/dev/null; then
            echo "✅ Successfully enabled $dm"
            
            # Test if it can start
            if sudo systemctl start "$dm.service" 2>/dev/null; then
                echo "🎉 $dm started successfully!"
                echo "✅ Recovery complete. You should now have a working login screen."
                return 0
            else
                echo "⚠️ $dm failed to start, trying next..."
                sudo systemctl disable "$dm.service" 2>/dev/null || true
            fi
        else
            echo "⚠️ Failed to enable $dm, trying next..."
        fi
    done
    
    echo "❌ All display managers failed. Installing fallback..."
    install_fallback_dm
}

### INSTALL FALLBACK DISPLAY MANAGER ###
install_fallback_dm() {
    echo "📦 Installing LightDM as fallback..."
    
    # Detect package manager
    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y lightdm lightdm-gtk-greeter
        sudo systemctl enable lightdm.service
        sudo systemctl start lightdm.service
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y lightdm lightdm-gtk
        sudo systemctl enable lightdm.service
        sudo systemctl start lightdm.service
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter
        sudo systemctl enable lightdm.service
        sudo systemctl start lightdm.service
    else
        echo "❌ Cannot install fallback - no supported package manager"
        manual_recovery_instructions
        return 1
    fi
    
    echo "✅ Fallback LightDM installed and started"
}

### MANUAL RECOVERY INSTRUCTIONS ###
manual_recovery_instructions() {
    echo "🆘 MANUAL RECOVERY REQUIRED"
    echo "=============================================="
    echo "If automatic recovery failed, try these steps:"
    echo ""
    echo "1. Switch to TTY (Ctrl+Alt+F2)"
    echo "2. Login with your username/password"
    echo "3. Run one of these commands:"
    echo ""
    echo "   For Ubuntu/Debian:"
    echo "   sudo apt update && sudo apt install -y lightdm"
    echo "   sudo systemctl enable lightdm && sudo systemctl start lightdm"
    echo ""
    echo "   For Fedora:"
    echo "   sudo dnf install -y lightdm"
    echo "   sudo systemctl enable lightdm && sudo systemctl start lightdm"
    echo ""
    echo "   For Arch:"
    echo "   sudo pacman -S lightdm lightdm-gtk-greeter"
    echo "   sudo systemctl enable lightdm && sudo systemctl start lightdm"
    echo ""
    echo "4. Switch back to graphical mode (Ctrl+Alt+F7 or F1)"
    echo "=============================================="
}

### CHECK SYSTEM STATUS ###
check_system_status() {
    echo "🔍 System Status Check"
    echo "======================="
    
    # Check if we're in graphical mode
    if systemctl get-default | grep -q graphical; then
        echo "✅ System target: graphical"
    else
        echo "⚠️ System target: $(systemctl get-default)"
        echo "Setting to graphical target..."
        sudo systemctl set-default graphical.target
    fi
    
    # Check display manager services status
    echo ""
    echo "Display Manager Services:"
    for service in lightdm sddm gdm3 gdm; do
        if systemctl list-unit-files | grep -q "$service.service"; then
            status=$(systemctl is-enabled "$service.service" 2>/dev/null || echo "disabled")
            active=$(systemctl is-active "$service.service" 2>/dev/null || echo "inactive")
            echo "  $service: $status/$active"
        fi
    done
}

### MAIN ###
main() {
    echo "🚨 Display Manager Emergency Recovery"
    echo "====================================="
    
    # Check system status first
    check_system_status
    
    echo ""
    read -p "Proceed with emergency recovery? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        emergency_recovery
    else
        echo "Recovery cancelled. Run this script again when ready."
        manual_recovery_instructions
    fi
}

# Check if running as root (shouldn't be)
if [[ $EUID -eq 0 ]]; then
    echo "❌ Don't run this script as root. Run as regular user with sudo access."
    exit 1
fi

main
