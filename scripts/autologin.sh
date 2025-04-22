#!/bin/bash
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
sudo cp -a ~/dotfiles/assets/autologin.conf /etc/systemd/system/getty@tty1.service.d/autologin.conf
