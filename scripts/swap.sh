#!/bin/bash
set -e
# Create 16G swapfile

sudo fallocate -l 16G /swapfile

sudo chmod 600 /swapfile

sudo mkswap /swapfile

# Add swapfile to fstab if not already there
grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw,pri=10 0 0' | sudo tee -a /etc/fstab

# Enable swapfile
sudo swapon /swapfile

# Install zram-generator
yay --needed --noconfirm zramswap
sudo systemctl enable --now zramswap.service

clear
