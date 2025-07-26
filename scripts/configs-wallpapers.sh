#!/bin/bash

set -e

# Set wallpaper
wal -i ~/dotfiles/assets/wallpapers/pywallpaper.jpg -n

# Change the "USER" placeholders in some config files
find ~/dotfiles/assets/.config/wofi/ -type f -name "*.css" -exec sed -i "s|/home/USER|/home/$(whoami)|g" {} +; sed -i "s|USER|$(whoami)|g" ~/dotfiles/assets/autologin.conf; sed -i "s|/home/USER|/home/$(whoami)|g" ~/dotfiles/assets/.config/fastanime/config.ini

# Copy files
sudo cp -av ~/dotfiles/assets/wallpapers ~/
sudo cp -a ~/dotfiles/assets/.config/. ~/.config/
sudo cp -rv ~/dotfiles/assets/userdir/. ~/
sudo cp -rv ~/dotfiles/assets/desktopfiles/. /usr/share/applications/
sudo cp ~/dotfiles/assets/hosts /etc/hosts

# Set default file explorer
xdg-mime default thunar.desktop inode/directory

