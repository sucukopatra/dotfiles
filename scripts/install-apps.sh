#!/bin/bash

sudo chmod -R 777 $HOME
yay -S --noconfirm --needed reflector rsync python-pywal16 swww waybar swaync starship myfetch vim nvim hyprland xdg-desktop-portal-hyprland hypridle hyprshot hyprlock pyprland fd cava brightnessctl clock-rs-git noto-fonts-emoji otf-ipaexfont ttf-firacode-nerd otf-codenewroman-nerd nwg-look materia-gtk-theme illogical-impulse-bibata-modern-classic-bin thunar tumbler ffmpegthumbnailer gvfs gvfs-mtp thunar-volman bottom ncspot blueman bluez bluez-utils pipewire pipewire-pulse pipewire-alsa pipewire-jack pavucontrol pulsemixer celluloid feh asciiquarium eza man sptlrx wofi kitty zen-browser-bin man timeshift xorg-xhost steam fastanime fzf auto-cpufreq pokemon-colorscripts-git dkms linux-lts-headers ripgrep fastfetch python-pillow kvantum bleachbit
sudo systemctl enable --now bluetooth
sudo systemctl --user enable --now pipewire.service
sudo systemctl --user enable --now pipewire-pulse.service
sudo systemctl enable --now auto-cpufreq

# Set wallpaper
wal -i ~/dotfiles/assets/wallpapers/pywallpaper.jpg -n

# Copy files
sudo cp -av ~/dotfiles/assets/wallpapers ~/
sudo cp -a ~/dotfiles/assets/.config/. ~/.config/
sudo cp -rv ~/dotfiles/assets/userdir/. ~/
sudo cp -rv ~/dotfiles/assets/desktopfiles/. /usr/share/applications/
sudo cp ~/dotfiles/assets/hosts /etc/hosts
