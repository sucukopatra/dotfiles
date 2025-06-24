#!/bin/bash
set -e
sudo chmod -R 777 $HOME
yay -S --noconfirm --needed reflector rsync python-pywal16 swww waybar swaync starship myfetch vim nvim hyprland xdg-desktop-portal-hyprland hypridle hyprshot hyprlock pyprland fd cava brightnessctl clock-rs-git noto-fonts-emoji otf-ipaexfont ttf-firacode-nerd otf-codenewroman-nerd nwg-look materia-gtk-theme illogical-impulse-bibata-modern-classic-bin thunar tumbler ffmpegthumbnailer gvfs gvfs-mtp thunar-volman bottom btop ncspot blueman bluez bluez-utils pipewire pipewire-pulse pipewire-alsa pipewire-jack pavucontrol pulsemixer celluloid feh asciiquarium eza man sptlrx wofi kitty zen-browser-bin man timeshift xorg-xhost steam fastanime fzf pokemon-colorscripts-git dkms linux-lts-headers ripgrep fastfetch python-pillow kvantum bleachbit obs-studio qbittorrent

sudo systemctl enable --now bluetooth
sudo systemctl --user enable --now pipewire.service
sudo systemctl --user enable --now pipewire-pulse.service
