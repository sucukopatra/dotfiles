#!/bin/bash
set -e
sudo pacman -Syu --noconfirm --needed
mkdir /tmp/yay
cd /tmp/yay
curl -OJ 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay'
makepkg --noconfirm -si
cd
rm -rf /tmp/yay
