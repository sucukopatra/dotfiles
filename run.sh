#!/bin/bash

cd ~/dotfiles/

# Parse command line arguments
LAPTOP=false
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --laptop) LAPTOP=true; shift ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
done

# Exit on any error
set -e

# Source utility functions
source scripts/utils.sh

# Source the package list
if [ ! -f "scripts/packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

source scripts/packages.conf

echo "Starting the system setup..."

# Update the system first
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install yay AUR helper if not present
if ! command -v yay &> /dev/null; then
  echo "Installing yay AUR helper..."
  sudo pacman -S --needed git base-devel --noconfirm
  if [[ ! -d "yay" ]]; then
    echo "Cloning yay repository..."
  else
    echo "yay directory already exists, removing it..."
    rm -rf yay
  fi

  git clone https://aur.archlinux.org/yay.git

  cd yay
  echo "building yay.... yaaaaayyyyy"
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo "yay is already installed"
fi


# Install all packages
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

# Enable services
echo "Configuring services..."
for service in "${SERVICES[@]}"; do
  if ! systemctl is-enabled "$service" &> /dev/null; then
    echo "Enabling $service..."
    sudo systemctl enable "$service"
  else
    echo "$service is already enabled"
  fi
done

echo "Setting config files"
bash scripts/configs-wallpapers.sh

echo "Installing grub theme"
bash scripts/install-grub-theme.sh

echo "Setting up Autologin"
bash scripts/autologin.sh

echo "Installing zapret"
bash scripts/install-zapret.sh

# Some programs just run better as flatpaks. Like discord/spotify
echo "Installing flatpaks"
. scripts/install-flatpaks.sh

if [[ "$LAPTOP" == true ]]; then
  echo "Activating dedicated gpu"
  bash scripts/dedicated-gpu.sh

  echo "Replacing capslock key with A key"
  bash scripts/caps-to-a.sh

  echo "Installing auto cpu freq"
  bash scripts/auto-cpufreq.sh
fi

echo "Setup complete! You may want to reboot your system."
