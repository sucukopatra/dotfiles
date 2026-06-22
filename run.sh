#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$REPO_DIR/utils.sh"
source "$REPO_DIR/packages.conf"

echo "Requesting sudo once..."
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

mkdir -p ~/media/{photos,video,music} ~/docs ~/dev ~/downloads ~/media/photos/{screenshots,wallpapers} ~/media/video/{shows,movies}

install_yay

echo "Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"
echo "Installing development tools..."
install_packages "${DEV_TOOLS[@]}"
echo "Installing system maintenance tools..."
install_packages "${MAINTENANCE[@]}"
echo "Installing desktop environment..."
install_packages "${DESKTOP[@]}"
echo "Installing media packages..."
install_packages "${MEDIA[@]}"
echo "Installing fonts..."
install_packages "${FONTS[@]}"
echo "Installing gamedev specific things..."
install_packages "${GAME_DEV[@]}"

echo "Setting up GPU udev symlinks..."
setup_gpu_udev

echo "Enabling TLP..."
if command -v tlp >/dev/null 2>&1; then
  sudo systemctl enable --now tlp.service
fi

echo "Setting up ly display manager..."
# Disable other display managers if present
for dm in gdm sddm lightdm lxdm; do
  systemctl is-enabled "${dm}.service" >/dev/null 2>&1 \
    && sudo systemctl disable "${dm}.service"
done
# Enable Ly service if not already enabled
systemctl is-enabled ly@tty2.service >/dev/null 2>&1 \
  || sudo systemctl enable ly@tty2.service

echo "Installing stow configs..."
stow_packages "${STOW[@]}"

echo "Installing claude code..."
command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash

if [[ "$SHELL" != */zsh ]]; then
  echo "Changing to zsh..."
  sudo chsh -s /bin/zsh "$USER"
fi

if command -v hyprctl &>/dev/null && pgrep -x Hyprland &>/dev/null; then
  hyprctl reload
fi
