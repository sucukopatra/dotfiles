#!/bin/bash

set -e

# requires to be run as root, unless the user has access to the theme folder
if [[ $(id -u) -ne 0 ]]; then
  echo "Must be run as root!"
  exit 1
fi

# this should be the directory of the clones repo
SCRIPT_DIR="$HOME/dotfiles/assets/minegrub-theme"
# I accidentally deleted the above line once and it copied / into the theme folder, so lets prevent this
if [[ -z $SCRIPT_DIR ]]; then
  echo "Something didn't work, exiting"
  exit 1
fi

# check if the grub folder is called grub/ or grub2/
if [ -d /boot/grub ]; then
  grub_path="/boot/grub"
elif [ -d /boot/grub2 ]; then
  grub_path="/boot/grub2"
else
  echo "Can't find a /boot/grub or /boot/grub2 folder. Exiting."
  exit 1
fi
theme_path="$grub_path/themes/minegrub"

## Prompts
echo "[INFO] => Copying the theme files to boot partition:"
# copy recursive, update, verbose
cd "$SCRIPT_DIR" && cp -ruv ./minegrub "$grub_path/themes/" | awk '$0 !~ /skipped/ { print "\t"$0 }'

echo -ne "[INFO] Installing systemd service to update splash and package labels on boot\n\t"
cp -uv "$SCRIPT_DIR/minegrub-update.service" /etc/systemd/system/
systemctl enable minegrub-update.service

# Check if the GRUB_THEME line exists
if grep -q "^GRUB_THEME=" /etc/default/grub; then
  # If it exists, update the line
  sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$theme_path/theme.txt\"|" /etc/default/grub
else
  # If it doesn't exist, add the line at the end of the file
  echo "GRUB_THEME=\"$theme_path/theme.txt\"" | sudo tee -a /etc/default/grub >/dev/null
fi

grub-mkconfig -o "$grub_path/grub.cfg"
