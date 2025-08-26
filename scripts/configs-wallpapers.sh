#!/bin/bash

set -e

# Stow the configs
cd ~/dotfiles/assets && stow -D -t ~ stow
stow -t ~ --adopt stow && cd ~/dotfiles/

# Set wallpaper
wal -i ~/dotfiles/assets/wallpapers/pywallpaper.jpg -n

# Change the "USER" placeholders in some config files
find ~/dotfiles/assets/stow/.config/wofi/ -type f -name "*.css" -exec sed -i "s|/home/USER|/home/$(whoami)|g" {} +

# Copy files
sudo cp -av ~/dotfiles/assets/wallpapers ~/
sudo cp -rv ~/dotfiles/assets/desktopfiles/. /usr/share/applications/
sudo cp ~/dotfiles/assets/.conf/hosts /etc/hosts
sudo cp -r ~/dotfiles/assets/settings/ ~/

# Set default file explorer
xdg-mime default thunar.desktop inode/directory
