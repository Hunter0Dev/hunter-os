# Hunter OS

**Version**: 1.0 (Aegis)
**Type**: Security-Focused Linux Distribution
**Based on**: Arch Linux
**Desktop**: KDE Plasma 6

## Overview

Hunter OS is a security-focused Linux distribution built on Arch Linux with a polished macOS-like KDE Plasma 6 desktop. It provides a hardened, professional environment for developers, security researchers, and power users.

## Key Features

### 🖥️ Desktop Environment
- **KDE Plasma 6** — Modern, polished desktop with macOS-like layout
- **Global Menu Bar** — App menus in the top panel
- **Floating Dock** — Quick launch bar with pinned applications
- **Dark Theme** — Breeze Dark across all applications
- **4 Virtual Desktops** — Like macOS Spaces
- **Wayland** — Modern display protocol (X11 fallback available)

### 🔐 Security Features
- **AppArmor** — Mandatory access control
- **UFW** — Uncomplicated firewall (deny incoming, allow outgoing)
- **Fail2Ban** — Intrusion prevention (SSH brute-force protection)
- **SSH Hardening** — Key-only auth, no root login, strong ciphers
- **Kernel Hardening** — ASLR, ptrace restriction, SYN cookies

### 🛠️ Network & Security Tools
- **nmap** — Network scanner
- **traceroute** — Route tracing
- **whois** — Domain lookup
- **bind-tools** — DNS utilities
- **lynis** — Security auditing
- **rkhunter** — Rootkit detection

### 📦 Development Tools
- **Languages**: Python, Rust (rustup), Go, Node.js, C/C++
- **Compilers**: GCC, Clang
- **Editors**: VS Code, Kate
- **Version Control**: Git, GitHub CLI
- **Build Tools**: CMake, Make

### 🤖 AI Assistant (Optional)
- Install via: `hunter-ai-gui` or manually with Ollama
- **Qwen2.5-Coder 1.5B** — Offline coding assistant

## Quick Start

### Package Management
```bash
hunter install <package>    # Install software
hunter remove <package>     # Remove software
hunter update               # Update system
hunter search <term>        # Search packages
```

### Security Commands
```bash
hunter audit                # Run comprehensive security audit
hunter status               # Check security service status
hunter firewall status      # Firewall status
hunter firewall enable      # Enable firewall
hunter harden               # Reload kernel security parameters
```

### Development Environments
```bash
hunter install dev-c        # C/C++ (GCC, CMake, GDB)
hunter install dev-node     # Node.js & NPM
hunter install dev-rust     # Rust via rustup
```

### Advanced Tools
```bash
hunter-get install security-audit   # Lynis, rkhunter
hunter-get install pentest          # nmap, wireshark, tcpdump
hunter-get fix wifi                 # Reset network adapter
hunter-get fix bluetooth            # Reset bluetooth
```

## Default Credentials (Live Environment)
- **Username**: hunter
- **Password**: hunter

## Installing to Disk
Use the **Install Hunter OS** shortcut on the desktop, or search for "Install" in the application menu. This launches the Calamares installer.

## System Requirements

### Minimum
- **CPU**: 64-bit processor
- **RAM**: 3 GB
- **Storage**: 10 GB
- **Graphics**: 1024x768 resolution

### Recommended
- **CPU**: Multi-core 64-bit processor
- **RAM**: 8 GB or more
- **Storage**: 20 GB+
- **Graphics**: 1920x1080 resolution

## Support

- **GitHub**: https://github.com/hunter-os/hunter-os
- **Issues**: https://github.com/hunter-os/hunter-os/issues

## License

Hunter OS is free and open-source software. Individual tools have their own licenses.

## Credits

Built with:
- **Arch Linux** — Base system
- **archiso** — ISO building framework
- **KDE Plasma 6** — Desktop environment
- **Calamares** — System installer
- **Ollama** — AI assistant platform (optional)

---

**Hunter OS** — Security-Focused. Developer-Ready.
