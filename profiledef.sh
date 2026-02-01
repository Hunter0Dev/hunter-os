#!/usr/bin/env bash
# ISO Name Configuration for HUNTER OS

iso_name="hunter-os"
iso_label="HUNTER_OS"
iso_publisher="Hunter Systems <https://hunter-os.org>"
iso_application="Hunter OS Live/Rescue CD"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')

bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-x64.grub.esp' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '3' '-b' '1M')
file_permissions=(

  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/usr/local/bin/hunter"]="0:0:755"
  ["/usr/local/bin/hunter-get"]="0:0:755"
  ["/usr/local/bin/hunter-welcome"]="0:0:755"
  ["/usr/local/bin/hunter-welcome-screen"]="0:0:755"
  ["/usr/local/bin/hunter-register-user"]="0:0:755"
  ["/usr/local/bin/hunter-install"]="0:0:755"
  ["/usr/local/bin/hunter-monitor"]="0:0:755"
  ["/usr/local/bin/hunter-set-wallpaper"]="0:0:755"
  ["/usr/local/bin/hunter-app-checker"]="0:0:755"
  ["/usr/local/bin/hunter-create-app-wrappers"]="0:0:755"
  ["/usr/local/bin/hunter-ai-setup"]="0:0:755"
  ["/usr/local/bin/hunter-ai-gui"]="0:0:755"
  ["/usr/local/bin/hunter-dashboard"]="0:0:755"
  ["/usr/local/bin/lightdm-register-user"]="0:0:755"
  ["/etc/skel/.xinitrc"]="0:0:755"
  ["/etc/skel/Desktop/install-hunter-os.desktop"]="0:0:755"
  ["/etc/skel/Desktop/hunter-monitor.desktop"]="0:0:755"
  ["/etc/skel/Desktop/hunter-ai.desktop"]="0:0:755"
  ["/etc/sysctl.d/99-hunter-security.conf"]="0:0:644"
  ["/etc/lightdm/lightdm-gtk-greeter.conf"]="0:0:644"
  ["/etc/ufw"]="0:0:755"
  ["/etc/apparmor.d"]="0:0:755"
  ["/etc/ssh/sshd_config.d"]="0:0:755"
)
