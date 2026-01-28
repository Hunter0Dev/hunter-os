#!/bin/bash
# setup.sh - HUNTER OS Build Environment Prep
# Automatically installs Docker and fixes permissions.

set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}>>> HUNTER OS Environment Setup${NC}"

# 1. Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
else
    echo "Unknown OS. Please install Docker manually."
    exit 1
fi

echo "Detected OS: $OS"

# 2. Check for Docker
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✔ Docker is already installed.${NC}"
else
    echo ">>> Docker not found. Installing..."
    if [[ "$ID" == "debian" || "$ID" == "ubuntu" || "$ID_LIKE" == "debian" ]]; then
        sudo apt update
        sudo apt install -y docker.io git
        sudo systemctl enable --now docker
        echo -e "${GREEN}✔ Docker installed!${NC}"
    elif [[ "$ID" == "arch" || "$ID_LIKE" == "arch" ]]; then
        sudo pacman -S --noconfirm docker git
        sudo systemctl enable --now docker
        echo -e "${GREEN}✔ Docker installed!${NC}"
    else
        echo "Unsupported OS for auto-install. Please install Docker manually."
    fi
fi

# 3. Permission Fixes
echo ">>> Fixing script permissions..."
chmod +x build_with_docker.sh
sed -i 's/\r$//' build_with_docker.sh
echo -e "${GREEN}✔ Permissions fixed.${NC}"

# 4. User Group (Optional hint)
if ! groups $USER | grep &>/dev/null 'docker'; then
    echo "----------------------------------------------------------------"
    echo "NOTE: You are not in the 'docker' group yet."
    echo "You can either:"
    echo "  1. Run the build with sudo: sudo ./build_with_docker.sh"
    echo "  2. Add yourself: sudo usermod -aG docker \$USER (then logout)"
    echo "----------------------------------------------------------------"
fi

echo -e "${GREEN}>>> Setup Complete! You can now run ./build_with_docker.sh${NC}"
