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
    mkarchiso -v -w /tmp/archiso-work -o /hunter-os/out .
"

echo ">>> Build Complete!"
echo ">>> ISO should be in the 'out' directory."
