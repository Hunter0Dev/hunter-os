#!/bin/bash
# Build script for Non-Arch Systems (Debian, Ubuntu, Fedora)

set -e # Exit immediately if a command exits with a non-zero status.

echo ">>> Building HUNTER OS Container..."
docker build -t hunter-builder .

echo ">>> Starting Build Process..."
# We mount the current directory to /hunter-os inside the container
# We also need privileged mode to mount loop devices for the ISO
# We use 'bash -c' to copy missing configs (grub/syslinux) from the default profile if they don't exist
docker run --privileged --rm -v "$(pwd):/hunter-os" hunter-builder /bin/bash -c "
    if [ ! -d /hunter-os/grub ]; then
        echo '>>> Copying default GRUB config...'
        cp -r /usr/share/archiso/configs/releng/grub /hunter-os/
    fi
    if [ ! -d /hunter-os/syslinux ]; then
        echo '>>> Copying default Syslinux config...'
        cp -r /usr/share/archiso/configs/releng/syslinux /hunter-os/
    fi
    if [ ! -d /hunter-os/efiboot ]; then
        echo '>>> Copying default Efiboot config...'
        cp -r /usr/share/archiso/configs/releng/efiboot /hunter-os/
    fi

    echo '>>> Enabling System Services...'
    # Create systemd symlinks
    SYSTEMD_DIR="/hunter-os/airootfs/etc/systemd/system"
    WANTS_DIR="$SYSTEMD_DIR/multi-user.target.wants"
    mkdir -p "$WANTS_DIR"

    # Display Manager (LightDM)
    ln -sf /usr/lib/systemd/system/lightdm.service "$SYSTEMD_DIR/display-manager.service"

    # Network Manager
    ln -sf /usr/lib/systemd/system/NetworkManager.service "$WANTS_DIR/NetworkManager.service"
    
    # Security Services
    ln -sf /usr/lib/systemd/system/ufw.service "$WANTS_DIR/ufw.service"
    ln -sf /usr/lib/systemd/system/fail2ban.service "$WANTS_DIR/fail2ban.service"
    ln -sf /usr/lib/systemd/system/apparmor.service "$WANTS_DIR/apparmor.service"
    ln -sf /usr/lib/systemd/system/sshd.service "$WANTS_DIR/sshd.service"

    # Virtualization Services (Auto-detects and runs if in VM)
    ln -sf /usr/lib/systemd/system/vboxservice.service "$WANTS_DIR/vboxservice.service"
    ln -sf /usr/lib/systemd/system/vmtoolsd.service "$WANTS_DIR/vmtoolsd.service"
    ln -sf /usr/lib/systemd/system/qemu-guest-agent.service "$WANTS_DIR/qemu-guest-agent.service"

    # Setup Service
    ln -sf "/etc/systemd/system/setup-hunter.service" "$WANTS_DIR/setup-hunter.service"

    echo '>>> Building ISO...'
    mkarchiso -v -w /tmp/archiso-work -o /hunter-os/out .
"

echo ">>> Build Complete!"
echo ">>> ISO should be in the 'out' directory."
