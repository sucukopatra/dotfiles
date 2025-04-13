#!/bin/bash

sudo chmod -R 777 $HOME
yay -S --noconfirm reflector rsync python-pywal16 swww waybar swaync starship myfetch vim nvim hyprland xdg-desktop-portal-hyprland hypridle hyprshot hyprlock pyprland fd cava brightnessctl clock-rs-git noto-fonts-emoji otf-ipaexfont ttf-firacode-nerd otf-codenewroman-nerd nwg-look materia-gtk-theme illogical-impulse-bibata-modern-classic-bin thunar tumbler ffmpegthumbnailer gvfs gvfs-mtp thunar-volman bottom ncspot blueman bluez bluez-utils pipewire pipewire-pulse pipewire-alsa pipewire-jack pavucontrol pulsemixer celluloid feh asciiquarium eza man sptlrx wofi kitty zen-browser-bin man timeshift xorg-xhost steam fastanime-git fzf auto-cpufreq pokemon-colorscripts-git dkms linux-lts-headers ripgrep fastfetch python-pillow
systemctl enable bluetooth
systemctl --user enable --now pipewire.service
systemctl --user enable --now pipewire-pulse.service
ystemctl enable --now auto-cpufreq

# Set wallpaper
wal -i ~/dotfiles/assets/wallpapers/pywallpaper.jpg -n

# Copy files
sudo cp -a ~/dotfiles/assets/wallpapers ~/
sudo cp -a ~/dotfiles/assets/.config/* ~/.config/
sudo cp -a ~/dotfiles/assets/.bashrc ~/
sudo cp -a ~/dotfiles/assets/.bash_profile ~/
sudo cp -a ~/dotfiles/assets/vim.desktop /usr/share/applications/
sudo cp -a ~/dotfiles/assets/nvim.desktop /usr/share/applications/
sudo cp -a ~/dotfiles/assets/steam.desktop /usr/share/applications/
chmod 444 /usr/share/applications/steam.desktop
sudo cp -a ~/dotfiles/assets/timeshift-gtk.desktop /usr/share/applications/
sudo cp -a ~/dotfiles/assets/.git-credentials
sudo cp -a ~/dotfiles/assets/.gitconfig
