# Hunter OS

**Version**: 1.0  
**Type**: Live Cybersecurity Platform  
**Based on**: Arch Linux

## Overview

Hunter OS is a specialized Linux distribution designed for cybersecurity professionals, penetration testers, and security researchers. Built on Arch Linux, it provides a comprehensive suite of security tools in a live environment.

## Key Features

### 🔐 Security Tools
- **Network Analysis**: nmap, wireshark, tcpdump, netcat
- **Web Security**: burpsuite, sqlmap, nikto, dirb
- **Exploitation**: metasploit, beef, social-engineer-toolkit
- **Password Cracking**: john, hashcat, hydra
- **Wireless**: aircrack-ng, reaver, wifite
- **Forensics**: autopsy, volatility, sleuthkit

### 🤖 AI Assistant
- **Qwen2.5-Coder 1.5B** - Offline coding assistant
- Helps with code generation, debugging, and security analysis
- Access via: `ollama run qwen2.5-coder:1.5b`

### 🖥️ Desktop Environment
- **XFCE4** - Lightweight and customizable
- **Materia-dark** theme
- **Adwaita** icons
- **Roboto** font

### 🛡️ Security Features
- **AppArmor** - Mandatory access control
- **UFW** - Uncomplicated firewall
- **Fail2Ban** - Intrusion prevention
- **SSH Hardening** - Secure remote access
- **Kernel Security** - Hardened parameters

### 📦 Development Tools
- **Languages**: Python, Rust, Go, Node.js, C/C++
- **Compilers**: GCC, Clang
- **Version Control**: Git, GitHub CLI
- **Build Tools**: CMake, Make

## Quick Start

### Boot Options
- **Normal Boot**: Standard live environment
- **Copy to RAM**: Faster performance, requires more RAM
- **Safe Mode**: Disable graphics acceleration
- **Emergency Shell**: Recovery mode

### First Steps
1. Log in with default credentials (shown on screen)
2. Launch **Hunter Welcome Screen** from desktop
3. Configure network (WiFi/Ethernet)
4. Start exploring tools!

### Common Commands
```bash
# View available Hunter commands
hunter --help

# Launch system monitor
hunter-monitor

# Start AI assistant
ollama run qwen2.5-coder:1.5b

# Update tool database
hunter-get update

# Install Hunter OS to disk
hunter-install
```

## Network Configuration

### WiFi
- Click NetworkManager icon in system tray
- Select your network
- Enter password

### Ethernet
- Plug in cable
- Automatic DHCP configuration

## Tools Organization

Tools are organized by category in the application menu:
- **Information Gathering**
- **Vulnerability Analysis**
- **Web Application Analysis**
- **Password Attacks**
- **Wireless Attacks**
- **Exploitation Tools**
- **Forensics**
- **Reverse Engineering**

## System Requirements

### Minimum
- **CPU**: 64-bit processor
- **RAM**: 4 GB
- **Storage**: 8 GB USB drive or DVD
- **Graphics**: 1024x768 resolution

### Recommended
- **CPU**: Multi-core 64-bit processor
- **RAM**: 8 GB or more
- **Storage**: 16 GB+ USB drive
- **Graphics**: 1920x1080 resolution
- **Network**: WiFi adapter with monitor mode support

## Persistence (Optional)

To save changes between reboots:
1. Create a persistent partition on USB
2. Label it `persistence`
3. Create `persistence.conf` file
4. Reboot with persistence enabled

## Support

- **Documentation**: `/usr/share/doc/hunter-os/`
- **GitHub**: https://github.com/hunter-os/hunter-os
- **Issues**: https://github.com/hunter-os/hunter-os/issues
- **Community**: https://discord.gg/hunter-os

## License

Hunter OS is free and open-source software. Individual tools have their own licenses.

## Credits

Built with:
- **Arch Linux** - Base system
- **archiso** - ISO building framework
- **XFCE** - Desktop environment
- **ollama** - AI assistant platform
- **Qwen2.5-Coder** - AI model

## Disclaimer

Hunter OS is designed for legal security testing and educational purposes only. Users are responsible for complying with all applicable laws and regulations. Unauthorized access to computer systems is illegal.

---

**Hunter OS** - Empowering Security Professionals
