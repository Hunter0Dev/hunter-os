#!/bin/sh
# Hunter OS - Default X Session Configuration

# Load X resources
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

# Start XFCE Desktop Environment
exec startxfce4
