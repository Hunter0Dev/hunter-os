#!/bin/bash
# Build script for Non-Arch Systems (Debian, Ubuntu, Fedora)

set -e # Exit immediately if a command exits with a non-zero status.

echo ">>> Building HUNTER OS Container..."
docker build -t hunter-builder .

echo ">>> Starting Build Process..."
# We mount the current directory to /hunter-os inside the container
# We also need privileged mode to mount loop devices for the ISO
docker run --privileged --rm -v "$(pwd):/hunter-os" hunter-builder \
    mkarchiso -v -w /tmp/archiso-work -o /hunter-os/out .

echo ">>> Build Complete!"
echo ">>> ISO should be in the 'out' directory."
