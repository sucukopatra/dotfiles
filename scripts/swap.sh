#!/bin/bash

# Install zram-generator
sudo pacman -Syu --needed --noconfirm zram-generator

sudo mkdir -p /etc/systemd/zram-generator.d
sudo tee /etc/systemd/zram-generator.d/zram.conf > /dev/null <<EOF
[zram0]
zram-size = ram / 4
compression-algorithm = zstd
EOF

# Create 16G swapfile
sudo fallocate -l 16G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile

# Add swapfile to fstab if not already there
grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw,pri=10 0 0' | sudo tee -a /etc/fstab

# Enable both
sudo systemctl daemon-reexec
sudo systemctl restart systemd-zram-setup@zram0.service
sudo swapon /swapfile
