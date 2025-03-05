#!/bin/bash

sudo chmod -R 777 $HOME
yay -S reflector rsync python-pywal16 swww waybar swaync starship myfetch vim hyprland hypridle hyprpicker hyprshot hyprlock pyprland fd cava brightnessctl clock-rs-git noto-fonts-emoji ttf-firacode-nerd otf-codenewroman-nerd nwg-look qogir-icon-theme materia-gtk-theme illogical-impulse-bibata-modern-classic-bin thunar gvfs tumbler bottom ncspot blueman bluez pipewire pipewire-pulse pipewire-alsa pipewire-jack pavucontrol pulsemixer gst-plugins-bad linutil-bin celluloid feh asciiquarium eza man sptlrx wofi kitty
systemctl enable bluetooth
systemctl --user enable pipewire.service
systemctl --user enable pipewire-pulse.service
systemctl --user start pipewire.service
systemctl --user start pipewire-pulse.service
sudo systemctl enable avahi-daemon

# Set wallpaper
wal -i ~/dotfiles/wallpapers/pywallpaper.jpg -n

# Dynamic-Cursors setup
hyprpm add https://github.com/virtcode/hypr-dynamic-cursors
hyprpm enable dynamic-cursors

# Copy files
sudo cp -a ~/dotfiles/wallpapers ~/
sudo cp -a ~/dotfiles/.config/* ~/.config/
sudo cp -a ~/dotfiles/.bashrc ~/
sudo cp -a ~/dotfiles/.bash_profile ~/
