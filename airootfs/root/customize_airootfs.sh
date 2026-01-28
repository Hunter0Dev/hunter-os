#!/bin/bash
# customize_airootfs.sh
# Runs insides the chroot during ISO creation to enable services.

set -e -u

# Set the timezone (optional, default UTC)
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Generate locales
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Enable Critical Services
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable sddm

# Setup User (if not using autologin, but live media usually autologins)
# We ensure the 'hunter' user exists if we were creating a persistent install script
# For Live ISO, archiso handles the 'arch' user, but we can tweak groups.

echo ">>> HUNTER OS: Services Enabled."
