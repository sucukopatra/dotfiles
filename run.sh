#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$REPO_DIR/utils.sh"
source "$REPO_DIR/packages.conf"

YES_ALL=0
for arg in "$@"; do
  [[ "$arg" == "--yes" || "$arg" == "-y" ]] && YES_ALL=1
done

echo "Requesting sudo once..."
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

mkdir -p ~/media/{photos,video,music} ~/notes ~/docs ~/dev ~/downloads ~/media/photos/{screenshots,wallpapers} ~/media/video/{shows,movies}

if [[ ! -d ~/media/photos/wallpapers/.git ]]; then
  if prompt_yn "Clone wallpaper repository to ~/media/photos/wallpapers/?"; then
    git clone https://github.com/sucukopatra/wallpapers.git ~/media/photos/wallpapers
  fi
fi

install_yay
install_group "System utilities" SYSTEM_UTILS
install_group "Development tools" DEV_TOOLS enable_services syncthing tailscaled
install_group "Maintenance tools" MAINTENANCE
install_group "Desktop environment" DESKTOP
install_group "Media packages" MEDIA
install_group "Fonts" FONTS

if prompt_yn "Set up Intel/NVIDIA GPU udev symlinks?"; then
  echo "Setting up GPU udev symlinks..."
  setup_gpu_udev
fi

if prompt_yn "Enable TLP power management?"; then
  if command -v tlp >/dev/null 2>&1; then
    echo "Enabling TLP..."
    sudo systemctl enable --now tlp.service
  fi
fi

if prompt_yn "Set up ly display manager?"; then
  echo "Setting up ly display manager..."
  for dm in gdm sddm lightdm lxdm greetd; do
    systemctl is-enabled "${dm}.service" >/dev/null 2>&1 \
      && sudo systemctl disable "${dm}.service"
  done
  systemctl is-enabled ly@tty2.service >/dev/null 2>&1 \
    || sudo systemctl enable ly@tty2.service
fi

echo "Installing stow configs..."
stow_packages "${STOW[@]}"

if prompt_yn "Install Claude Code?"; then
  command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash
fi

if [[ "$SHELL" != */zsh ]]; then
  if prompt_yn "Change default shell to zsh?"; then
    echo "changing to zsh..."
    sudo chsh -s /bin/zsh "$USER"
  fi
fi

if command -v hyprctl &>/dev/null && pgrep -x hyprland &>/dev/null; then
  hyprctl reload
fi
