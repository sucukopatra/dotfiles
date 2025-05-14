#!/bin/bash

# Set wallpaper
wal -i ~/dotfiles/assets/wallpapers/pywallpaper.jpg -n

# Copy files
sudo cp -av ~/dotfiles/assets/wallpapers ~/
sudo cp -a ~/dotfiles/assets/.config/. ~/.config/
sudo cp -rv ~/dotfiles/assets/userdir/. ~/
sudo cp -rv ~/dotfiles/assets/desktopfiles/. /usr/share/applications/
sudo cp ~/dotfiles/assets/hosts /etc/hosts
