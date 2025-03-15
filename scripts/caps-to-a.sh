#!/bin/bash

yay -S keyd
sudo cp ~/dotfiles/assets/caps-to-a.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
