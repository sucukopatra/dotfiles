#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$REPO_DIR/utils.sh"
source "$REPO_DIR/packages.conf"

echo "Requesting sudo once..."
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &

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

echo "Installing stow configs..."
stow_packages "${STOW[@]}"

echo "Changing to zsh..."
sudo chsh -s /bin/zsh $USER

hyprctl reload
