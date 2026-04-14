#!/bin/bash
# Hunter OS First Boot Script
# Lightweight — only tasks that need to run on actual first boot
# NOT the full build-time configuration (that's .automated_script.sh)

set -e

echo ">>> HUNTER OS: Running first-boot setup..."

# Detect the primary desktop user (first non-system user in /home)
DESKTOP_USER=""
for dir in /home/*/; do
    user=$(basename "$dir")
    # Skip Shared directory and system accounts
    [ "$user" = "Shared" ] && continue
    if id "$user" &>/dev/null; then
        DESKTOP_USER="$user"
        break
    fi
done

# Fall back to hunter if no other user found
[ -z "$DESKTOP_USER" ] && DESKTOP_USER="hunter"

echo ">>> Configuring for user: $DESKTOP_USER"

# Apply KDE Plasma wallpaper
if command -v plasma-apply-wallpaperimage &> /dev/null; then
    if [ -f /usr/share/backgrounds/hunter-os-dark.png ]; then
        sudo -u "$DESKTOP_USER" plasma-apply-wallpaperimage /usr/share/backgrounds/hunter-os-dark.png 2>/dev/null || true
    elif [ -f /usr/share/backgrounds/hunter-os.png ]; then
        sudo -u "$DESKTOP_USER" plasma-apply-wallpaperimage /usr/share/backgrounds/hunter-os.png 2>/dev/null || true
    fi
    echo "✓ Wallpaper applied"
fi

# Apply theme if script exists
if [ -f /usr/local/bin/hunter-apply-theme ]; then
    sudo -u "$DESKTOP_USER" /usr/local/bin/hunter-apply-theme 2>/dev/null || true
    echo "✓ Theme applied"
fi

# Ensure home directory is private
chmod 700 "/home/$DESKTOP_USER" 2>/dev/null || true

# Show notification
if command -v notify-send &> /dev/null; then
    sudo -u "$DESKTOP_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$DESKTOP_USER")/bus" \
        notify-send "Hunter OS" "Welcome! Your system is configured and ready." \
        --icon=dialog-information 2>/dev/null || true
fi

echo ">>> HUNTER OS: First-boot setup complete!"
