#!/bin/bash

# Install zram-generator
yay --needed --noconfirm zramswap
sudo systemctl enable --now zramswap.service

clear
