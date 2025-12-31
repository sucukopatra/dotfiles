#!/bin/bash

set -e

# Change the "USER" placeholders in some config files
find ~/dotfiles/assets/stow/wofi/.config/wofi/ -type f -name "*.css" -exec sed -i "s|/home/ender|/home/$(whoami)|g" {} +

# Changing closing lid behaviour
sudo mkdir -p /etc/systemd/logind.conf.d && \
echo -e "[Login]\nHandleLidSwitchExternalPower=ignore\nHandleLidSwitch=ignore" | \
sudo tee /etc/systemd/logind.conf.d/10-lid-ignore.conf > /dev/null

# Creating directories
mkdir -p ~/Downloads ~/Videos
# Copy files
sudo cp -an ~/dotfiles/assets/wallpapers ~/
sudo cp -r ~/dotfiles/assets/desktopfiles/. /usr/share/applications/
sudo cp ~/dotfiles/assets/.conf/hosts /etc/hosts
sudo cp -rn ~/dotfiles/assets/settings/ ~/

# Set default file explorer
xdg-mime default thunar.desktop inode/directory
