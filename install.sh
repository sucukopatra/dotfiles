#!/bin/bash
set -e
clear
ask() { read -p "$1 (y/n): " a; [[ ${a,,} == y* ]]; }

ask "Do you want to install the apps?" && app="yes" || app="no"
ask "Do you want the configs and wallpapers?" && con="yes" || con="no"
ask "Do you want to use your dedicated gpu?" && gpu="yes" || gpu="no"
ask "Do you want to remap caps to a?" && cta="yes" || cta="no"
ask "Do you want to install minecraft grub theme?" && gt="yes" || gt="no"
ask "Do you want to auto login?" && al="yes" || al="no"
ask "Do you want to install zapret?" && z="yes" || z="no"
ask "Do you want to install discord?" && dc="yes" || dc="no"
ask "Do you want to install wine and bottles?" && wb="yes" || wb="no"
ask "Do you want to use auto-cpufreq?" && cpu="yes" || cpu="no"
ask "Do you want swap?" && s="yes" || s="no"
ask "Do you want to set up nextdns?" && dns="yes" || dns="no"

sudo -v
if ! command -v yay &> /dev/null; then
    bash scripts/yay-install.sh
fi

[[ $app == yes ]] && ./scripts/install-apps.sh
[[ $con == yes ]] && ./scripts/configs-wallpapers.sh
[[ $gpu == yes ]] && ./scripts/dedicated-gpu.sh
[[ $cta == yes ]] && ./scripts/caps-to-a.sh
[[ $gt == yes ]] && ./scripts/install-grub-theme.sh
[[ $cpu == yes ]] && ./scripts/auto-cpufreq.sh
[[ $al == yes ]] && ./scripts/autologin.sh
[[ $z == yes ]] && ./scripts/install-zapret.sh
[[ $dc == yes ]] && ./scripts/install-discord.sh
[[ $wb == yes ]] && ./scripts/windows-thingy.sh
[[ $s == yes ]] && ./scripts/swap.sh
[[ $dns == yes ]] && echo "id is 898827"; sh -c 'sh -c "$(curl -sL https://nextdns.io/install)"'

clear

