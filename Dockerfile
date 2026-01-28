# Build Environment for HUNTER OS
FROM archlinux:base-devel

# Install Archiso
RUN pacman -Sy --noconfirm archiso

# Create a build directory
WORKDIR /hunter-os

# The command to run when the container starts
# We don't run the build immediately here to allow binding volumes
CMD ["/bin/bash"]
