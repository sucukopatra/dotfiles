#!/bin/bash
set -e
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo cp -nv ~/dotfiles/assets/.conf/autologin.conf /etc/systemd/system/getty@tty1.service.d/ 
