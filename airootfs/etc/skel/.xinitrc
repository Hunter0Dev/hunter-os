#!/bin/sh
# Hunter OS - Default X Session Configuration
# This is a fallback for startx. SDDM handles normal boot.

# Load X resources
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

# Start KDE Plasma Desktop
# Try X11 session (xinitrc is only used by startx, which is X11-only)
exec startplasma-x11
