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

    echo '>>> Configuring System Services...'
    # Create systemd directory structure
    SYSTEMD_DIR=\"/hunter-os/airootfs/etc/systemd/system\"
    mkdir -p \"\$SYSTEMD_DIR/multi-user.target.wants\"
    mkdir -p \"\$SYSTEMD_DIR/graphical.target.wants\"

    # CRITICAL: Set graphical.target as default (this is what makes GUI boot)
    ln -sf /usr/lib/systemd/system/graphical.target \"\$SYSTEMD_DIR/default.target\"

    # Enable Display Manager (SDDM for KDE Plasma)
    ln -sf /usr/lib/systemd/system/sddm.service \"\$SYSTEMD_DIR/graphical.target.wants/sddm.service\"
    ln -sf /usr/lib/systemd/system/sddm.service \"\$SYSTEMD_DIR/display-manager.service\"

    # Enable Network Manager
    ln -sf /usr/lib/systemd/system/NetworkManager.service \"\$SYSTEMD_DIR/multi-user.target.wants/NetworkManager.service\"
    
    # Enable Security Services
    ln -sf /usr/lib/systemd/system/ufw.service \"\$SYSTEMD_DIR/multi-user.target.wants/ufw.service\" 2>/dev/null || true
    ln -sf /usr/lib/systemd/system/fail2ban.service \"\$SYSTEMD_DIR/multi-user.target.wants/fail2ban.service\" 2>/dev/null || true
    ln -sf /usr/lib/systemd/system/apparmor.service \"\$SYSTEMD_DIR/multi-user.target.wants/apparmor.service\" 2>/dev/null || true

    # Enable Virtualization Services (will fail gracefully if not in VM)
    ln -sf /usr/lib/systemd/system/vboxservice.service \"\$SYSTEMD_DIR/multi-user.target.wants/vboxservice.service\" 2>/dev/null || true
    ln -sf /usr/lib/systemd/system/vmtoolsd.service \"\$SYSTEMD_DIR/multi-user.target.wants/vmtoolsd.service\" 2>/dev/null || true
    ln -sf /usr/lib/systemd/system/qemu-guest-agent.service \"\$SYSTEMD_DIR/multi-user.target.wants/qemu-guest-agent.service\" 2>/dev/null || true

    # Enable Setup Service
    ln -sf /etc/systemd/system/setup-hunter.service \"\$SYSTEMD_DIR/graphical.target.wants/setup-hunter.service\"

    echo '>>> Building ISO...'
    mkarchiso -v -w /tmp/archiso-work -o /hunter-os/out .
"

echo ">>> Build Complete!"
echo ">>> ISO should be in the 'out' directory."
