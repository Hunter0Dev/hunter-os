# Build Environment for HUNTER OS
FROM archlinux:base-devel

# Install Archiso and Build Tools (Required for generating bootloaders)
RUN pacman -Sy --noconfirm archiso grub syslinux mtools dosfstools efibootmgr

# Create a build directory
WORKDIR /hunter-os

# The command to run when the container starts
# We don't run the build immediately here to allow binding volumes
CMD ["/bin/bash"]
