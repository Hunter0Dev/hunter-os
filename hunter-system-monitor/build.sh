#!/bin/bash
# Build script for Hunter System Monitor

set -e

echo ">>> Building Hunter System Monitor..."

cd "$(dirname "$0")/hunter-system-monitor"

# Install Rust if not present
if ! command -v cargo &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Build release binary
echo ">>> Compiling (this may take a few minutes)..."
cargo build --release

# Copy binary to system
echo ">>> Installing to /usr/local/bin..."
sudo cp target/release/hunter-monitor /usr/local/bin/
sudo chmod +x /usr/local/bin/hunter-monitor

echo ">>> Creating desktop entry..."
sudo tee /usr/share/applications/hunter-monitor.desktop > /dev/null << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Hunter System Monitor
Comment=Monitor system resources and processes
Exec=hunter-monitor
Icon=utilities-system-monitor
Terminal=false
Categories=System;Monitor;GTK;
Keywords=system;process;task;manager;
EOF

echo "✅ Hunter System Monitor installed successfully!"
echo "Run with: hunter-monitor"
