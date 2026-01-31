#!/usr/bin/env bash
# airootfs/root/.automated_script.sh
# Modern replacement for customize_airootfs.sh
# This script runs inside the chroot during ISO creation

set -e -u

echo ">>> HUNTER OS: Starting System Configuration..."

# ============================================
# Locale and Timezone Configuration
# ============================================
echo ">>> Configuring locale and timezone..."
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# ============================================
# Generate Initramfs
# ============================================
echo ">>> Generating initramfs with mkinitcpio..."
if [ -f /etc/mkinitcpio.conf ]; then
    mkinitcpio -P
else
    echo "WARNING: /etc/mkinitcpio.conf not found, skipping initramfs generation"
fi

# ============================================
# Enable Critical Services
# ============================================
echo ">>> Enabling system services..."

# Set graphical target as default (CRITICAL for GUI boot)
systemctl set-default graphical.target

# Enable Display Manager
systemctl enable lightdm

# Enable Network and Bluetooth
systemctl enable NetworkManager
systemctl enable bluetooth

# Enable Security Services
systemctl enable apparmor
systemctl enable ufw
systemctl enable fail2ban
systemctl enable sshd

# ============================================
# AppArmor Configuration
# ============================================
echo ">>> Configuring AppArmor..."
if [ -d /etc/apparmor.d ]; then
    # Enable AppArmor profiles
    if command -v aa-enforce &> /dev/null; then
        aa-enforce /etc/apparmor.d/usr.local.bin.hunter 2>/dev/null || true
        aa-enforce /etc/apparmor.d/usr.local.bin.hunter-get 2>/dev/null || true
    fi
fi

# ============================================
# UFW Firewall Configuration
# ============================================
echo ">>> Configuring UFW firewall..."
if command -v ufw &> /dev/null; then
    # In Docker/chroot environment, kernel modules may not be available
    # Configure UFW but don't try to enable it (will enable on first boot)
    
    # Create UFW configuration directory if it doesn't exist
    mkdir -p /etc/ufw
    
    # Set default policies in config file
    if [ -f /etc/default/ufw ]; then
        sed -i 's/DEFAULT_INPUT_POLICY=".*/DEFAULT_INPUT_POLICY="DROP"/' /etc/default/ufw
        sed -i 's/DEFAULT_OUTPUT_POLICY=".*/DEFAULT_OUTPUT_POLICY="ACCEPT"/' /etc/default/ufw
        sed -i 's/DEFAULT_FORWARD_POLICY=".*/DEFAULT_FORWARD_POLICY="DROP"/' /etc/default/ufw
    fi
    
    # Create a first-boot service to configure UFW
    cat > /etc/systemd/system/hunter-ufw-setup.service << 'EOF'
[Unit]
Description=Hunter OS UFW First Boot Setup
After=network.target
Before=ufw.service
ConditionPathExists=!/var/lib/hunter-ufw-configured

[Service]
Type=oneshot
ExecStart=/usr/local/bin/hunter-ufw-setup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    # Create the setup script
    cat > /usr/local/bin/hunter-ufw-setup.sh << 'EOF'
#!/bin/bash
# Hunter OS UFW Setup Script - Runs on first boot

set -e

echo ">>> Configuring UFW on first boot..."

# Reset UFW to defaults
ufw --force reset 2>/dev/null || true

# Set default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (rate limited)
ufw limit ssh comment 'SSH rate limited'

# Allow DHCP client
ufw allow out 67/udp comment 'DHCP client'
ufw allow out 68/udp comment 'DHCP client'

# Allow DNS
ufw allow out 53 comment 'DNS'

# Allow NTP
ufw allow out 123/udp comment 'NTP'

# Enable firewall
ufw --force enable

# Mark as configured
touch /var/lib/hunter-ufw-configured

echo ">>> UFW configured successfully"
EOF

    chmod +x /usr/local/bin/hunter-ufw-setup.sh
    
    # Enable the first-boot service
    systemctl enable hunter-ufw-setup.service
    
    echo "UFW will be configured on first boot"
fi

# ============================================
# Fail2Ban Configuration
# ============================================
echo ">>> Configuring fail2ban..."
# Configuration files are already in place, service will start on boot

# ============================================
# SSH Configuration
# ============================================
echo ">>> Configuring SSH..."
# Create SSH directory structure
mkdir -p /etc/ssh/sshd_config.d
chmod 755 /etc/ssh/sshd_config.d

# ============================================
# Security Hardening
# ============================================
echo ">>> Applying security hardening..."

# Set secure file permissions
chmod 700 /root
chmod 755 /usr/local/bin/hunter
chmod 755 /usr/local/bin/hunter-get

# Restrict /proc and /sys access
chmod 550 /proc 2>/dev/null || true
chmod 550 /sys 2>/dev/null || true

# Create security directories
mkdir -p /var/log/audit
chmod 700 /var/log/audit

# ============================================
# User Configuration
# ============================================
echo ">>> Configuring users..."

# Create hunter user for live environment
if ! id -u hunter &>/dev/null; then
    useradd -m -G wheel,audio,video,storage,optical,network -s /bin/bash hunter
    echo "hunter:hunter" | chpasswd
    echo "hunter ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/hunter
    chmod 440 /etc/sudoers.d/hunter
fi

# Lock root account (can still use sudo)
passwd -l root 2>/dev/null || true

# ============================================
# System Optimization
# ============================================
echo ">>> Optimizing system..."

# Update package database
if command -v pacman &> /dev/null; then
    pacman-key --init
    pacman-key --populate archlinux
fi

# ============================================
# Display Manager Configuration
# ============================================
echo ">>> Configuring display manager..."
if command -v lightdm &> /dev/null; then
    systemctl enable lightdm
    
    # Configure LightDM for Live Environment (Ubuntu-style)
    # Auto-login for testing, account creation only during installation
    mkdir -p /etc/lightdm
    cat > /etc/lightdm/lightdm.conf << 'EOF'
[Seat:*]
# Auto-login for live environment (testing mode)
autologin-user=hunter
autologin-user-timeout=0
autologin-session=xfce

# Session configuration
user-session=xfce
greeter-session=lightdm-gtk-greeter
greeter-hide-users=false
allow-guest=false

# Show manual login option (for after installation)
greeter-show-manual-login=true
greeter-show-remote-login=false
EOF

    # Configure LightDM greeter
    cat > /etc/lightdm/lightdm-gtk-greeter.conf << 'EOF'
[greeter]
theme-name=Adwaita-dark
icon-theme-name=Adwaita
font-name=Sans 10
background=#1a1a1a

# Show indicators
indicators=~host;~spacer;~clock;~spacer;~session;~a11y;~power
EOF
    
    # Don't hide hunter user in live environment
    # (It will be hidden after installation when real users are created)

    # Configure LightDM greeter theme
    cat > /etc/lightdm/lightdm-gtk-greeter.conf << 'EOF'
[greeter]
theme-name=Adwaita-dark
icon-theme-name=Adwaita
font-name=Sans 10
background=#1a1a1a
EOF
fi

# ============================================
# Set Hunter OS Wallpaper
# ============================================
echo ">>> Setting Hunter OS wallpaper..."
if [ -f /usr/local/bin/hunter-set-wallpaper ]; then
    chmod +x /usr/local/bin/hunter-set-wallpaper
    /usr/local/bin/hunter-set-wallpaper
fi

# ============================================
# Build Hunter System Monitor (Rust)
# ============================================
echo ">>> Building Hunter System Monitor..."
if [ -d /hunter-system-monitor ]; then
    cd /hunter-system-monitor
    
    # Install Rust if not present
    if ! command -v cargo &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
        source "$HOME/.cargo/env"
    fi
    
    # Build release binary
    cargo build --release
    
    # Install binary
    cp target/release/hunter-monitor /usr/local/bin/
    chmod +x /usr/local/bin/hunter-monitor
    
    # Clean up build artifacts
    cargo clean
    
    cd /
fi

# ============================================
# Cleanup
# ============================================
echo ">>> Cleaning up..."

# Remove unnecessary files
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/cache/pacman/pkg/*

# Clear logs
find /var/log -type f -exec truncate -s 0 {} \;

echo ">>> HUNTER OS: System Configuration Complete!"
echo ">>> Security Features Enabled:"
echo "    - AppArmor: Mandatory Access Control"
echo "    - UFW: Firewall (will configure on first boot)"
echo "    - Fail2Ban: Intrusion Prevention"
echo "    - SSH: Hardened Configuration"
echo "    - Kernel: Security Parameters Applied"
echo "    - Services: Systemd Hardening Active"
