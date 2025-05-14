#!/bin/bash
yay -S --noconfirm --needed auto-cpufreq
sudo systemctl enable --now auto-cpufreq
