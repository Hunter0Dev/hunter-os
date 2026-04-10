#!/bin/bash
# Hunter OS First Boot Script
# Lightweight — only tasks that need to run on actual first boot
# NOT the full build-time configuration (that's .automated_script.sh)

set -e

echo ">>> HUNTER OS: Running first-boot setup..."

# Note: UFW firewall is configured by hunter-ufw-setup.service (see .automated_script.sh)
# No need to duplicate UFW setup here.

# Apply KDE Plasma wallpaper
if command -v plasma-apply-wallpaperimage &> /dev/null; then
    if [ -f /usr/share/backgrounds/hunter-os-dark.png ]; then
        sudo -u hunter plasma-apply-wallpaperimage /usr/share/backgrounds/hunter-os-dark.png 2>/dev/null || true
    elif [ -f /usr/share/backgrounds/hunter-os.png ]; then
        sudo -u hunter plasma-apply-wallpaperimage /usr/share/backgrounds/hunter-os.png 2>/dev/null || true
    fi
    echo "✓ Wallpaper applied"
fi

# Apply theme if script exists
if [ -f /usr/local/bin/hunter-apply-theme ]; then
    sudo -u hunter /usr/local/bin/hunter-apply-theme 2>/dev/null || true
    echo "✓ Theme applied"
fi

# Show notification
if command -v notify-send &> /dev/null; then
    sudo -u hunter DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u hunter)/bus" \
        notify-send "Hunter OS" "Welcome! Your system is configured and ready." \
        --icon=dialog-information 2>/dev/null || true
fi

echo ">>> HUNTER OS: First-boot setup complete!"
