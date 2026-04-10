#!/bin/bash
# Build AUR packages and include them in the ISO
# This runs during ISO build to pre-compile AUR packages

set -e

AUR_BUILD_DIR="/tmp/aur-packages"
PACKAGE_DIR="/hunter-os/airootfs/opt/hunter-packages"

echo ">>> Building AUR packages for Hunter OS..."

# Create directories
mkdir -p "$AUR_BUILD_DIR"
mkdir -p "$PACKAGE_DIR"

# Function to build AUR package
build_aur_package() {
    local package_name="$1"
    echo "Building $package_name..."
    
    cd "$AUR_BUILD_DIR"
    
    # Clone AUR package
    if [ -d "$package_name" ]; then
        rm -rf "$package_name"
    fi
    
    git clone "https://aur.archlinux.org/${package_name}.git"
    cd "$package_name"
    
    # Build as nobody user (can't build as root)
    chown -R nobody:nobody .
    
    # Build package
    sudo -u nobody makepkg -s --noconfirm || {
        echo "Failed to build $package_name, skipping..."
        return 1
    }
    
    # Copy built package to ISO
    cp *.pkg.tar.zst "$PACKAGE_DIR/" || true
    
    echo "$package_name built successfully!"
}

# Build yay (AUR helper) - needed first
echo ">>> Building yay (AUR helper)..."
build_aur_package "yay-bin"

# Build Calamares installer
echo ">>> Building Calamares installer..."
build_aur_package "calamares"



# Create installation script
cat > "$PACKAGE_DIR/install-hunter-packages.sh" << 'EOF'
#!/bin/bash
# Install pre-built AUR packages

PACKAGE_DIR="/opt/hunter-packages"

echo "Installing Hunter OS AUR packages..."

# Install all packages
for pkg in "$PACKAGE_DIR"/*.pkg.tar.zst; do
    if [ -f "$pkg" ]; then
        echo "Installing $(basename $pkg)..."
        pacman -U --noconfirm "$pkg" || echo "Failed to install $(basename $pkg)"
    fi
done

echo "AUR packages installed!"
EOF

chmod +x "$PACKAGE_DIR/install-hunter-packages.sh"

echo ">>> AUR packages built and ready!"
ls -lh "$PACKAGE_DIR"
