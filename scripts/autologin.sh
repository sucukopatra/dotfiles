#!/bin/bash
set -e
TARGET_DIR="/etc/systemd/system/getty@tty1.service.d"
SOURCE_FILE="$HOME/dotfiles/assets/.conf/autologin.conf"
sudo install -d "$TARGET_DIR"
if [ ! -f "$TARGET_DIR/autologin.conf" ]; then
  sudo install -m 644 "$SOURCE_FILE" "$TARGET_DIR/"
fi
