#!/bin/bash

set -e

# Set wallpaper
wal -i ~/dotfiles/assets/wallpapers/pywallpaper.jpg -n

# Change the "USER" placeholders in some config files
find ~/dotfiles/assets/config/.config/wofi/ -type f -name "*.css" -exec sed -i "s|/home/USER|/home/$(whoami)|g" {} +; sed -i "s|USER|$(whoami)|g" ~/dotfiles/assets/.conf/autologin.conf; sed -i "s|/home/USER|/home/$(whoami)|g" ~/dotfiles/assets/config/.config/fastanime/config.ini

# Copy files
sudo cp -av ~/dotfiles/assets/wallpapers ~/
sudo cp -rv ~/dotfiles/assets/desktopfiles/. /usr/share/applications/
sudo cp ~/dotfiles/assets/.conf/hosts /etc/hosts
sudo cp -r ~/dotfiles/assets/settings/ ~/
# Set default file explorer
xdg-mime default thunar.desktop inode/directory

cd ~/dotfiles/assets && stow -D -t ~ config; stow -t ~ --adopt config && cd ~/dotfiles/
