#!/bin/bash

yay -S --noconfirm keyd
sudo cp ~/dotfiles/assets/caps-to-a.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
