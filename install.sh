#!/bin/bash

ask() { read -p "$1 (y/n): " a; [[ ${a,,} == y* ]]; }

ask "Do you want to use your dedicated gpu?" && gpu="yes" || gpu="no"
ask "Do you want to remap caps to a?" && cta="yes" || cta="no"
ask "Do you want to install minecraft grub theme?" && gt="yes" || gt="no"
ask "Do you want to auto login?" && al="yes" || al="no"
ask "Do you want to install zapret?" && z="yes" || z="no"
ask "Do you want to install discord?" && dc="yes" || dc="no"

sudo -v

bash scripts/yay-install.sh
bash scripts/install-apps.sh

[[ $gpu == yes ]] && ./scripts/dedicated-gpu.sh
[[ $cta == yes ]] && ./scripts/caps-to-a.sh
[[ $gt == yes ]] && ./scripts/install-grub-theme.sh
[[ $al == yes ]] && ./scripts/autologin.sh
[[ $z == yes ]] && ./scripts/install-zapret.sh
[[ $dc == yes ]] && ./scripts/install-discord.sh

git config --global user.email "endercortuk@proton.me"
git config --global user.name "sucukopatra"
git config --global credential.helper store

clear

ask "Do you want to set up nextdns?" && dns="yes" || dns"no"
[[ $dns == yes ]] && curl -sSL https://nextdns.io/install | sh
