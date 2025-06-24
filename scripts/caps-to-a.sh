#!/bin/bash
set -e
yay -S --noconfirm --needed keyd
sudo cp -nv ~/dotfiles/assets/caps-to-a.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
