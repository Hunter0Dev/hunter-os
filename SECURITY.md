# HUNTER OS Security Documentation

## Overview

HUNTER OS is a security-focused, lightweight Linux distribution built on Arch Linux. It implements enterprise-grade security features while maintaining a minimal footprint for optimal performance.

## Security Features

### 1. Mandatory Access Control (AppArmor)

AppArmor provides mandatory access control to confine programs to a limited set of resources.

**Status Check:**
```bash
sudo aa-status
```

**Enabled Profiles:**
- `/usr/local/bin/hunter` - Package manager wrapper
- `/usr/local/bin/hunter-get` - Package helper utility

**Managing Profiles:**
```bash
# Enforce a profile
sudo aa-enforce /etc/apparmor.d/usr.local.bin.hunter

# Set to complain mode (logging only)
sudo aa-complain /etc/apparmor.d/usr.local.bin.hunter

# Disable a profile
sudo aa-disable /etc/apparmor.d/usr.local.bin.hunter
```

### 2. Firewall (UFW)

UFW (Uncomplicated Firewall) provides a user-friendly interface to iptables with a default-deny policy.

**Default Configuration:**
- Incoming: DENY
- Outgoing: ALLOW
- SSH: Rate-limited (max 6 connections per 30 seconds)

**Management Commands:**
```bash
# Check status
hunter firewall status
sudo ufw status verbose

# Enable/disable
hunter firewall enable
hunter firewall disable

# Add custom rules
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow from 192.168.1.0/24 to any port 22

# Delete rules
sudo ufw delete allow 80/tcp
```

### 3. Intrusion Prevention (Fail2Ban)

Fail2Ban monitors log files and bans IPs that show malicious behavior.

**Configuration:**
- SSH: 3 failed attempts = 2 hour ban
- SSH-DDOS: 2 attempts = 2 hour ban

**Management:**
```bash
# Check status
sudo fail2ban-client status

# Check SSH jail
sudo fail2ban-client status sshd

# Unban an IP
sudo fail2ban-client set sshd unbanip 192.168.1.100
```

### 4. Kernel Hardening

Kernel security parameters are configured in `/etc/sysctl.d/99-hunter-security.conf`

**Key Features:**
- ASLR (Address Space Layout Randomization)
- Kernel pointer restriction
- SYN cookie protection
- IP forwarding disabled
- Reverse path filtering
- Restricted ptrace scope

**Apply Changes:**
```bash
hunter harden
# or
sudo sysctl --system
```

### 5. SSH Hardening

SSH is configured with security-first defaults in `/etc/ssh/sshd_config.d/99-hunter-hardening.conf`

**Security Features:**
- Root login disabled
- Password authentication disabled (key-based only)
- Strong ciphers and key exchange algorithms
- X11 forwarding disabled
- TCP/Agent forwarding disabled
- Maximum 3 authentication attempts
- 30-second login grace time
- Idle session timeout (5 minutes)

**Setup SSH Keys:**
```bash
# Generate key pair (on client)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to server
ssh-copy-id hunter@server-ip

# Test connection
ssh hunter@server-ip
```

### 6. Systemd Service Hardening

All critical services have hardening configurations in `/etc/systemd/system/[service].service.d/hardening.conf`

**Hardened Services:**
- NetworkManager
- Bluetooth
- SSH

**Features:**
- Filesystem protections (ProtectSystem, ProtectHome)
- Kernel protections (ProtectKernelModules, ProtectKernelLogs)
- Namespace restrictions
- System call filtering
- Capability restrictions

## Security Audit

### Quick Audit
```bash
hunter audit
```

This command shows:
- AppArmor status
- Firewall status
- Fail2Ban status
- Lynis security audit (if installed)

### Comprehensive Audit
```bash
# Install Lynis
hunter install lynis

# Run full audit
sudo lynis audit system

# View report
sudo cat /var/log/lynis.log
```

### Security Scanning Tools

**Install Security Audit Tools:**
```bash
hunter-get install security-audit
```

This installs:
- `lynis` - Security auditing tool
- `rkhunter` - Rootkit detection
- `aide` - File integrity monitoring
- `chkrootkit` - Rootkit checker

**Rootkit Detection:**
```bash
# Update rkhunter database
sudo rkhunter --update

# Run scan
sudo rkhunter --check --skip-keypress
```

**File Integrity Monitoring:**
```bash
# Initialize AIDE database
sudo aide --init
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Check for changes
sudo aide --check
```

## Incident Response

### System Compromised?

1. **Disconnect from network:**
   ```bash
   sudo systemctl stop NetworkManager
   ```

2. **Check for unauthorized users:**
   ```bash
   who
   last
   sudo lastb  # Failed login attempts
   ```

3. **Check for suspicious processes:**
   ```bash
   ps aux | grep -v "^\[" | sort -k3 -rn | head -20
   htop
   ```

4. **Check network connections:**
   ```bash
   sudo ss -tulpn
   sudo netstat -tulpn
   ```

5. **Check for rootkits:**
   ```bash
   sudo rkhunter --check
   sudo chkrootkit
   ```

6. **Review logs:**
   ```bash
   sudo journalctl -xe
   sudo tail -f /var/log/auth.log
   sudo fail2ban-client status sshd
   ```

### Emergency Recovery

If the system fails to boot, use the emergency boot option from GRUB:
1. Select "HUNTER OS - Emergency Shell" from boot menu
2. System will drop to emergency shell
3. Mount filesystems and investigate

## Best Practices

### 1. Regular Updates
```bash
# Update system weekly
hunter update
```

### 2. Monitor Security Status
```bash
# Check security status daily
hunter status
```

### 3. Review Logs
```bash
# Check authentication logs
sudo journalctl -u sshd -f

# Check firewall logs
sudo journalctl -u ufw -f

# Check fail2ban logs
sudo journalctl -u fail2ban -f
```

### 4. Backup Important Data
```bash
# Backup configuration
sudo tar -czf /backup/etc-backup-$(date +%Y%m%d).tar.gz /etc

# Backup home directory
tar -czf /backup/home-backup-$(date +%Y%m%d).tar.gz ~
```

### 5. Use Strong Passwords
```bash
# Generate strong password
openssl rand -base64 32

# Change user password
passwd
```

## Security Checklist

- [ ] SSH keys configured (password auth disabled)
- [ ] Firewall enabled and configured
- [ ] Fail2Ban monitoring SSH
- [ ] AppArmor profiles in enforce mode
- [ ] Regular security audits scheduled
- [ ] System updates automated
- [ ] Logs monitored regularly
- [ ] Backups configured
- [ ] Root account locked
- [ ] Unnecessary services disabled

## Reporting Security Issues

If you discover a security vulnerability in HUNTER OS, please report it to:
- Email: security@hunter-os.org
- GPG Key: Available at https://hunter-os.org/security.asc

## Additional Resources

- [Arch Linux Security Wiki](https://wiki.archlinux.org/title/Security)
- [AppArmor Documentation](https://gitlab.com/apparmor/apparmor/-/wikis/home)
- [UFW Documentation](https://help.ubuntu.com/community/UFW)
- [Fail2Ban Documentation](https://www.fail2ban.org/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
