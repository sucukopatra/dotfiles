#!/bin/bash
set -e
yay -S --noconfirm --needed auto-cpufreq

if ! systemctl is-enabled --quiet auto-cpufreq; then
    echo "Enabling auto-cpufreq"
    sudo systemctl enable --now auto-cpufreq
else
    echo "auto-cpufreq is already enabled."
fi


