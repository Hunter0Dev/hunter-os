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

# Enable Display Manager (SDDM for KDE Plasma)
systemctl enable sddm

# Enable Network and Bluetooth
systemctl enable NetworkManager
systemctl enable bluetooth

# Enable Security Services
systemctl enable apparmor
systemctl enable ufw
systemctl enable fail2ban
# Note: SSH is NOT auto-enabled for security. Users can start it with:
# sudo systemctl start sshd

# ============================================
# AppArmor Configuration
# ============================================
echo ">>> Configuring AppArmor..."
if [ -d /etc/apparmor.d ]; then
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
    mkdir -p /etc/ufw

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

    cat > /usr/local/bin/hunter-ufw-setup.sh << 'EOF'
#!/bin/bash
set -e
echo ">>> Configuring UFW on first boot..."
ufw --force reset 2>/dev/null || true
ufw default deny incoming
ufw default allow outgoing
ufw limit ssh comment 'SSH rate limited'
ufw allow out 67/udp comment 'DHCP client'
ufw allow out 68/udp comment 'DHCP client'
ufw allow out 53 comment 'DNS'
ufw allow out 123/udp comment 'NTP'
ufw --force enable
touch /var/lib/hunter-ufw-configured
echo ">>> UFW configured successfully"
EOF

    chmod +x /usr/local/bin/hunter-ufw-setup.sh
    systemctl enable hunter-ufw-setup.service
    echo "UFW will be configured on first boot"
fi

# ============================================
# SSH Configuration
# ============================================
echo ">>> Configuring SSH..."
mkdir -p /etc/ssh/sshd_config.d
chmod 755 /etc/ssh/sshd_config.d

# ============================================
# Multi-User Isolation (Windows/macOS model)
# ============================================
echo ">>> Configuring multi-user isolation..."

# --- /home permissions: users can traverse but not list others ---
chmod 711 /home

# --- Restrict su to wheel group only ---
# Uncomment pam_wheel.so in /etc/pam.d/su to require wheel group for su
if [ -f /etc/pam.d/su ]; then
    sed -i 's/^#\s*\(auth\s\+required\s\+pam_wheel.so\)/\1/' /etc/pam.d/su
fi

# --- Process isolation: hide other users' processes (like Windows) ---
# Users can only see their own processes; wheel group (admins) can see all
if ! grep -q 'hidepid=' /etc/fstab; then
    echo "proc /proc proc nosuid,nodev,noexec,hidepid=2,gid=wheel 0 0" >> /etc/fstab
fi

# --- Restrict kernel.dmesg to root only (already in sysctl, reinforce here) ---
# --- Restrict access to cron ---
echo "root" > /etc/cron.allow 2>/dev/null || true

# --- Default login.defs for new user creation ---
if [ -f /etc/login.defs ]; then
    # Set default umask for useradd (owner-only)
    sed -i 's/^UMASK\s\+.*/UMASK 077/' /etc/login.defs
    # Set default home permission
    sed -i 's/^HOME_MODE\s\+.*/HOME_MODE 0700/' /etc/login.defs
    # Enforce password aging
    sed -i 's/^PASS_MIN_LEN\s\+.*/PASS_MIN_LEN 8/' /etc/login.defs
    sed -i 's/^PASS_MAX_DAYS\s\+.*/PASS_MAX_DAYS 365/' /etc/login.defs
    sed -i 's/^PASS_MIN_DAYS\s\+.*/PASS_MIN_DAYS 1/' /etc/login.defs
    sed -i 's/^PASS_WARN_AGE\s\+.*/PASS_WARN_AGE 14/' /etc/login.defs
fi

# --- Create shared directory for cross-user file sharing ---
mkdir -p /home/Shared
chmod 1770 /home/Shared
chown root:users /home/Shared

echo "✓ Multi-user isolation configured"

# ============================================
# Security Hardening
# ============================================
echo ">>> Applying security hardening..."

# Set secure file permissions
chmod 700 /root
chmod 755 /usr/local/bin/hunter
chmod 755 /usr/local/bin/hunter-get

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
    # NOPASSWD sudo for live environment only
    # After installation, Calamares creates a proper user with password-based sudo
    echo "hunter ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/hunter
    chmod 440 /etc/sudoers.d/hunter
fi

# Set live user home to private (even in live env, enforce the model)
chmod 700 /home/hunter

# Lock root account (can still use sudo)
passwd -l root 2>/dev/null || true

# ============================================
# System Optimization
# ============================================
echo ">>> Optimizing system..."

if command -v pacman &> /dev/null; then
    pacman-key --init
    pacman-key --populate archlinux
fi

# ============================================
# Display Manager Configuration (SDDM for KDE)
# ============================================
echo ">>> Configuring SDDM display manager..."
if command -v sddm &> /dev/null; then
    mkdir -p /etc/sddm.conf.d
    cat > /etc/sddm.conf.d/hunter.conf << 'EOF'
[Autologin]
User=hunter
Session=plasma

[Theme]
Current=hunter

[General]
InputMethod=
EOF
fi

# ============================================
# Install Pre-built AUR Packages
# ============================================
echo ">>> Installing pre-built AUR packages..."
if [ -f /opt/hunter-packages/install-hunter-packages.sh ]; then
    /opt/hunter-packages/install-hunter-packages.sh
else
    echo "No pre-built packages found, skipping..."
fi

# ============================================
# Apply KDE Theme on First Login
# ============================================
echo ">>> Configuring KDE Plasma theme..."
if [ -f /usr/local/bin/hunter-apply-theme ]; then
    chmod +x /usr/local/bin/hunter-apply-theme
fi

# ============================================
# Plymouth Boot Splash Configuration
# ============================================
echo ">>> Configuring Plymouth boot splash..."
if command -v plymouth-set-default-theme &> /dev/null; then
    if [ -f /usr/share/plymouth/themes/hunter/hunter.plymouth ]; then
        plymouth-set-default-theme -R hunter
        echo "✓ Plymouth configured with Hunter OS theme"
    else
        plymouth-set-default-theme -R spinner
        echo "WARNING: Hunter OS theme not found, falling back to spinner"
    fi
else
    echo "INFO: Plymouth not installed, skipping boot splash configuration"
fi

# ============================================
# Cleanup
# ============================================
echo ">>> Cleaning up..."
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/cache/pacman/pkg/*
find /var/log -type f -exec truncate -s 0 {} \;

echo ">>> HUNTER OS: System Configuration Complete!"
echo ">>> Security Features Enabled:"
echo "    - Multi-User Isolation: Private home directories (700)"
echo "    - Process Isolation: hidepid=2 on /proc"
echo "    - AppArmor: Mandatory Access Control"
echo "    - UFW: Firewall (will configure on first boot)"
echo "    - Fail2Ban: Intrusion Prevention"
echo "    - SSH: Hardened Configuration (manually startable)"
echo "    - Kernel: Security Parameters Applied"
echo "    - Default umask: 077 (private-by-default)"
