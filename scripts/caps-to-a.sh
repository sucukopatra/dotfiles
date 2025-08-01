#!/bin/bash
set -e
yay -S --noconfirm --needed keyd
sudo cp -nv ~/dotfiles/assets/.conf/caps-to-a.conf /etc/keyd/default.conf

if ! systemctl is-enabled --quiet keyd; then
    echo "Enabling keyd"
    sudo systemctl enable --now auto-cpufreq
else
    echo "keyd is already enabled"
fi


