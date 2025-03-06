#!/bin/bash

yay -S keyd
cp ~/dotfiles/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
