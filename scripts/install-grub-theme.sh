#!/bin/bash
set -e
current_dir="$(dirname "$(realpath "$0")")"
script_dir="$current_dir/../assets/minegrub-theme"
THEME_DIR="/boot/grub/themes/minegrub"

if [ ! -d "$THEME_DIR" ]; then
  echo "Theme not found, running installer..."
  sudo bash "$script_dir/install_theme.sh"
fi

