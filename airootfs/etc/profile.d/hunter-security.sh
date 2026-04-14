#!/bin/bash
# Hunter OS - Security defaults for all users
# /etc/profile.d/hunter-security.sh

# Private-by-default: new files are owner-only (like macOS/Windows)
# Owner: rwx, Group: ---, Others: ---
umask 077

# Prevent core dumps (security: core dumps can leak secrets)
ulimit -c 0
