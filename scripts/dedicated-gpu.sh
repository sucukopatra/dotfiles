#!/bin/bash
sudo pacman -S --noconfirm --needed xf86-video-amdgpu mesa vulkan-radeon lib32-mesa lib32-vulkan-radeon

if ! grep -q "DRI_PRIME=1" /etc/environment; then
    echo "Adding DRI_PRIME=1 to /etc/environment"
    echo "DRI_PRIME=1" | sudo tee -a /etc/environment
else
    echo "DRI_PRIME=1 is already present in /etc/environment"
fi
