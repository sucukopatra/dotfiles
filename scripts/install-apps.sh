#!/bin/bash

sudo chmod -R 777 $HOME
yay -S reflector rsync python-pywal16 swww waybar swaync starship myfetch vim hyprland hypridle hyprshot hyprlock pyprland fd cava brightnessctl clock-rs-git noto-fonts-emoji otf-ipaexfont ttf-firacode-nerd otf-codenewroman-nerd nwg-look materia-gtk-theme illogical-impulse-bibata-modern-classic-bin thunar tumbler ffmpegthumbnailer gvfs bottom ncspot blueman bluez bluez-utils pipewire pipewire-pulse pipewire-alsa pipewire-jack pavucontrol pulsemixer linutil-bin celluloid feh asciiquarium eza man sptlrx wofi kitty zen-browser-bin man timeshift xorg-xhost steam fastanime-git ani-skip-git fzf auto-cpufreq pokemon-colorscripts-git cmatrix
systemctl enable bluetooth
systemctl --user enable pipewire.service
systemctl --user enable pipewire-pulse.service
systemctl --user start pipewire.service
systemctl --user start pipewire-pulse.service
systemctl enable --now auto-cpufreq 

# Set wallpaper
wal -i ~/dotfiles/assets/wallpapers/pywallpaper.jpg -n

# Copy files
sudo cp -a ~/dotfiles/assets/wallpapers ~/
sudo cp -a ~/dotfiles/assets/.config/* ~/.config/
sudo cp -a ~/dotfiles/assets/.bashrc ~/
sudo cp -a ~/dotfiles/assets/.bash_profile ~/
sudo cp -a ~/dotfiles/assets/vim.desktop /usr/share/applications/
sudo cp -a ~/dotfiles/assets/steam.desktop /usr/share/applications/
sudo cp -a ~/dotfiles/assets/timeshift-gtk.desktop /usr/share/applications/

