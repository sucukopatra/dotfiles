#!/bin/bash

set -e

# Change the "USER" placeholders in some config files
find ~/dotfiles/assets/stow/wofi/.config/wofi/ -type f -name "*.css" -exec sed -i "s|/home/ender|/home/$(whoami)|g" {} +

# Changing closing lid behaviour
sudo mkdir -p /etc/systemd/logind.conf.d && \
echo -e "[Login]\nHandleLidSwitchExternalPower=ignore\nHandleLidSwitch=ignore" | \
sudo tee /etc/systemd/logind.conf.d/10-lid-ignore.conf > /dev/null

# Creating directories
mkdir -p ~/media/{games,music,photos/screenshots,videos/{tv,movies,anime}} ~/dev ~/docs ~/downloads ~/tmp

# Linking Wallpapers
ln -s ~/dotfiles/assets/wallpapers ~/media/photos/wallpapers

# Copy files
sudo cp ~/dotfiles/assets/.conf/user-dirs.dirs ~/.config/user-dirs.dirs
sudo cp -r ~/dotfiles/assets/desktopfiles/. /usr/share/applications/
sudo cp ~/dotfiles/assets/.conf/hosts /etc/hosts
sudo cp -rn ~/dotfiles/assets/settings/ ~/

# Update the user directories
xdg-user-dirs-update

# Set default file explorer
xdg-mime default thunar.desktop inode/directory
