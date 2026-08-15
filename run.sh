#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

TARGET_DIR="$HOME/dev/dotfiles"
if [[ "$REPO_DIR" != "$TARGET_DIR" ]]; then
  if [[ -e "$TARGET_DIR" ]]; then
    echo "Error: $TARGET_DIR already exists but this repo is at $REPO_DIR." >&2
    echo "Move or remove $TARGET_DIR, then re-run this script." >&2
    exit 1
  fi
  echo "Moving repo to $TARGET_DIR..."
  mkdir -p "$HOME/dev"
  mv "$REPO_DIR" "$TARGET_DIR"
  exec "$TARGET_DIR/run.sh" "$@"
fi

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

mkdir -p ~/media/{photos,video,music} ~/notes ~/docs ~/downloads ~/media/photos/{screenshots,wallpapers} ~/media/video/{shows,movies}

if [[ ! -d ~/media/photos/wallpapers/.git ]]; then
  if prompt_yn "Clone wallpaper repository to ~/media/photos/wallpapers/?"; then
    git clone https://github.com/sucukopatra/wallpapers.git ~/media/photos/wallpapers
  fi
fi

if prompt_yn "Upgrade the system first? (strongly recommended)"; then
  echo "Upgrading system..."
  system_upgrade
else
  echo "WARNING: skipping the upgrade. Everything installed below is built" >&2
  echo "         against current repo state, so mixing it into a stale system" >&2
  echo "         is a partial upgrade and can break it. Run 'pacman -Syu' soon." >&2
fi

install_yay
prompt_yn "Install system utilities?" && { echo "Installing system utilities..."; install_packages "${SYSTEM_UTILS[@]}"; }
prompt_yn "Install development tools?" && { echo "Installing development tools..."; install_packages "${DEV_TOOLS[@]}"; }
prompt_yn "Install system maintenance tools?" && { echo "Installing system maintenance tools..."; install_packages "${MAINTENANCE[@]}"; }
prompt_yn "Install desktop environment packages?" && { echo "Installing desktop environment..."; install_packages "${DESKTOP[@]}"; }
prompt_yn "Install media packages?" && { echo "Installing media packages..."; install_packages "${MEDIA[@]}"; }
prompt_yn "Install fonts?" && { echo "Installing fonts..."; install_packages "${FONTS[@]}"; }
prompt_yn "Install game development packages?" "n" && { echo "Installing gamedev specific things..."; install_packages "${GAME_DEV[@]}"; }

if prompt_yn "Set up Intel/NVIDIA GPU udev symlinks?"; then
  echo "Setting up GPU udev symlinks..."
  setup_gpu_udev
fi

if command -v tlp >/dev/null 2>&1 && prompt_yn "Enable TLP power management?"; then
  echo "Enabling TLP..."
  sudo systemctl enable --now tlp.service
fi

if prompt_yn "Set up ly display manager?"; then
  echo "Setting up ly display manager..."
  for dm in gdm sddm lightdm lxdm greetd; do
    is_installed "$dm" || continue
    systemctl is-enabled "${dm}.service" >/dev/null 2>&1 \
      && sudo systemctl disable "${dm}.service"
  done
  systemctl is-enabled ly@tty2.service >/dev/null 2>&1 \
    || sudo systemctl enable ly@tty2.service
fi

echo "Installing stow configs..."
stow_packages "${STOW[@]}"

if prompt_yn "Set up Unity + Neovim development environment?" "n"; then
  echo "Setting up Unity development environment..."
  setup_unity_dev "$REPO_DIR"
fi

if prompt_yn "Install Claude Code?"; then
  command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash
fi

if [[ "$SHELL" != */zsh ]]; then
  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    echo "WARNING: zsh is not installed; leaving default shell unchanged." >&2
  elif prompt_yn "Change default shell to zsh?"; then
    echo "changing to zsh..."
    sudo chsh -s "$zsh_path" "$USER"
  fi
fi

if command -v tailscale >/dev/null 2>&1; then
    enable_services tailscaled
    echo "If this is the first run, run 'tailscale login' to complete the setup."
fi
if command -v syncthing >/dev/null 2>&1; then
    enable_user_services syncthing
    echo "If this is the first run, open http://127.0.0.1:8384/ to complete the setup."
fi

if command -v hyprctl &>/dev/null && pgrep -x Hyprland &>/dev/null; then
  hyprctl reload
fi
