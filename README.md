# HUNTER OS Build Guide

Welcome to the **HUNTER OS** source tree. This directory contains the configuration files required to build your custom, secure, and lightweight Linux distribution using the `archiso` toolchain.

## Prerequisites

To build this ISO, you need a running Arch Linux environment. You can use:
1.  **WSL2 (Windows Subsystem for Linux)** with Arch Linux installed.
2.  **A Virtual Machine** (VirtualBox/VMware).
3.  **A Docker Container** (privileged).

### Option 1: On Arch Linux (Native)
Install the required tools:
```bash
sudo pacman -S archiso
```

### Option 2: On Debian/Ubuntu/Windows (Docker)
If you are not running Arch Linux (e.g. you are on Debian 13), you must use **Docker** because `archiso` requires `pacman` to fetch packages.

1.  **Install Docker** on your Debian machine:
    ```bash
    sudo apt update
    sudo apt install docker.io
    sudo usermod -aG docker $USER
    # Log out and log back in
    ```

2.  **Run the Build Script**:
    ```bash
    chmod +x build_with_docker.sh
    ./build_with_docker.sh
    ```

## Build Instructions

1.  **Clone/Copy** this directory `hunter-os` to your Linux environment.

2.  **Run the Build Command**:
    ```bash
    sudo mkarchiso -v -w /tmp/archiso-work -o out/ .
    ```

    *   `-v`: Verbose output (so you can see what's happening).
    *   `-w`: Work directory (temporary files).
    *   `-o`: Output directory (where the .iso will be saved).
    *   `.`: The current directory (containing `profiledef.sh`).

3.  **Wait**: The script will download all packages defined in `packages.x86_64` and assemble the ISO. This can take 10-30 minutes depending on your internet speed.

4.  **Retrieve the ISO**:
    The finished ISO file will be in the `out/` directory.

## Testing

You can verify the ISO works using QEMU:
```bash
run_archiso -i out/hunter-os-*.iso
```

## Customization

-   **Packages**: Edit `packages.x86_64` to add/remove software.
-   **UI**: Edit `airootfs/etc/skel/.config/hypr/hyprland.conf` to change shortcuts and animations.
-   **Branding**: Edit `profiledef.sh` and `airootfs/etc/os-release`.
