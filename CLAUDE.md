# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Hunter OS is a security-focused Arch Linux distribution built with `archiso`. It uses KDE Plasma 6 with SDDM, ships hardened security defaults (AppArmor, UFW, Fail2Ban, sysctl hardening), and enforces Windows/macOS-style multi-user isolation (private home directories, process hiding, umask 077).

## Build Commands

### Docker build (works on any Linux or WSL2):
```bash
./setup.sh                    # one-time: installs Docker, fixes permissions
sudo ./build_with_docker.sh   # builds ISO → out/hunter-os-*.iso
```

### Native Arch Linux build:
```bash
sudo pacman -S archiso
sudo mkarchiso -v -w /tmp/archiso-work -o out/ .
```

### Test the ISO:
```bash
run_archiso -i out/hunter-os-*.iso   # QEMU quick test
```

### Hunter System Monitor (Rust/GTK4):
```bash
cd hunter-system-monitor
cargo build --release
# or use: ./build.sh  (installs to /usr/local/bin)
```

## Architecture

### ISO Build Pipeline
- `profiledef.sh` — archiso profile: ISO metadata, boot modes (BIOS syslinux + UEFI GRUB), squashfs compression, file permissions for all custom scripts/themes
- `packages.x86_64` — complete package list included in the ISO
- `pacman.conf` — pacman configuration used during build
- `Dockerfile` — Arch container for building on non-Arch hosts
- `build_with_docker.sh` — orchestrates Docker build (copies missing bootloader configs, runs mkarchiso)
- `.github/workflows/build.yml` — CI: builds ISO on push/PR to main, uploads artifact (7-day retention), creates GitHub Release on tag push (`git tag vYYYY.MM.DD && git push --tags`)

### Boot-time Configuration
- `airootfs/root/.automated_script.sh` — runs in chroot during ISO creation. Handles: locale, initramfs, service enablement, AppArmor enforcement, UFW first-boot service, SSH hardening, **multi-user isolation setup**, user creation, SDDM config, Plymouth, cleanup. This is the single source of truth for service enablement (not `build_with_docker.sh`).

### Multi-User Isolation Model
Hunter OS enforces user isolation like Windows/macOS:
- Home directories are `chmod 700` (only the owner can access)
- `/home` is `chmod 711` (can traverse, cannot list other users)
- `/home/Shared` (mode 1770, group `users`) for cross-user file sharing
- Default `umask 077` via `/etc/profile.d/hunter-security.sh`
- `/proc` mounted with `hidepid=2,gid=wheel` (users can't see others' processes)
- `su` restricted to `wheel` group via PAM
- Password requirements: min 8 chars, upper+lower+number (enforced in `hunter-setup-user`, `hunter-register-user`, and Calamares `users.conf`)
- Polkit rules in `/etc/polkit-1/rules.d/` require wheel membership for admin actions
- After Calamares install: `shellprocess-hunter` module removes live user, enforces 700 on all homes

### Filesystem Overlay (`airootfs/`)
Everything under `airootfs/` is copied verbatim into the live ISO root filesystem.

- `airootfs/usr/local/bin/` — custom shell scripts:
  - `hunter` — main CLI package manager wrapper (delegates to pacman)
  - `hunter-get` — extended package helper with dev-tool bundles and system fixes
  - `hunter-setup-user` — GUI user creation with password validation and 700 home dirs
  - `hunter-register-user` — CLI user creation with same isolation enforcement
  - `hunter-welcome-screen` — first-run welcome (detects first boot)
  - `hunter-welcome` — zenity info dialog (runs once via marker file)
  - `hunter-dashboard` — Python/GTK3 dashboard (uses `pkexec` for Calamares)
  - `hunter-first-boot.sh` — auto-detects desktop user (not hardcoded)
  - `hunter-apply-theme` — runs once per user, marker-based skip on re-login
  - `hunter-ai-setup` / `hunter-ai-gui` — Ollama AI setup (binary verified, no pipe-to-shell)
- `airootfs/etc/` — system configuration:
  - `profile.d/hunter-security.sh` — umask 077, core dump prevention
  - `polkit-1/rules.d/50-hunter-admin.rules` — wheel-only admin auth
  - `sysctl.d/99-hunter-security.conf` — kernel hardening
  - `apparmor.d/` — AppArmor profiles for `hunter` and `hunter-get`
  - `fail2ban/` — Fail2Ban jail config (systemd backend)
  - `ssh/sshd_config.d/99-hunter-hardening.conf` — key-only auth, strong ciphers
  - `systemd/system/sshd.service.d/hardening.conf` — sandboxing (ProtectHome=read-only so authorized_keys works)
  - `calamares/` — installer config with `shellprocess-hunter` post-install hardening
  - `fstab` — /tmp (nodev,nosuid), /dev/shm (noexec), /proc (hidepid=2)

### Custom Themes
- `airootfs/usr/share/sddm/themes/hunter/` — QML-based SDDM login theme (fallback backgrounds)
- `airootfs/usr/share/plymouth/themes/hunter/` — Plymouth boot splash with animated spinner
- `grub/`, `syslinux/`, `efiboot/` — bootloader configs

### Hunter System Monitor (`hunter-system-monitor/`)
Standalone Rust application (GTK4 + sysinfo 0.29 + nvml-wrapper). Built separately from the ISO.

## Key Conventions

- All custom scripts in `airootfs/usr/local/bin/` are bash. File permissions are declared in `profiledef.sh` — any new script needs an entry there.
- Services are enabled in `.automated_script.sh` via `systemctl enable` (single source of truth).
- The ISO uses squashfs with zstd compression (level 3, 1M block size).
- Desktop is KDE Plasma 6 on Wayland (X11 fallback). SDDM is the display manager.
- Default live user: `hunter`/`hunter` (NOPASSWD sudo, removed after Calamares install).
- Every user-creation path (Calamares, `hunter-setup-user`, `hunter-register-user`) must enforce: `chmod 700 $HOME`, user private group (`-U`), password >= 8 chars.
- Calamares image paths must reference files that actually exist in `airootfs/usr/share/`.
