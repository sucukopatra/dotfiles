#!/bin/bash

cd ~/dotfiles/

# Stopping zapret if its running
pgrep -x nfqws >/dev/null && sudo systemctl stop zapret

# Parse command line arguments
LAPTOP=false
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --laptop)
      LAPTOP=true
      shift
      ;;
    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
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
if ! command -v yay &>/dev/null; then
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

# Adding the easter egg
echo "Adding the secret sauce"
grep -q "^[[:space:]]*ILoveCandy" /etc/pacman.conf ||
  sudo sed -i "/^[[:space:]]*Color/a ILoveCandy" /etc/pacman.conf ||
  echo ILoveCandy | sudo tee -a /etc/pacman.conf >/dev/null

#Install Headers
installed_kernels=$(pacman -Q | grep -E '^linux(| |-rt|-rt-lts|-hardened|-zen|-lts)[^-headers]' | cut -d ' ' -f 1)
for kernel in $installed_kernels; do
  header="${kernel}-headers"
  printf "%b\n" "Installing headers for $kernel..."

  if ! sudo pacman -S --needed --noconfirm "$header"; then
    exit 1
  fi
  printf "%b\n" "Continuing..."
done

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

yay -S --noconfirm --needed stow

echo "Setting config files"
. scripts/configs-wallpapers.sh

echo "Installing grub theme"
sudo bash assets/minegrub-theme/install_theme.sh

echo "Setting up Autologin"
. scripts/autologin.sh

echo "Installing zapret"
. scripts/install-zapret.sh

# Some programs just run better as flatpaks. Like discord/spotify
echo "Installing flatpaks"
. scripts/install-flatpaks.sh

# Fixing controller issues
bash scripts/fix-controller.sh

if [[ "$LAPTOP" == true ]]; then
  echo "Installing auto cpu freq"
  bash scripts/auto-cpufreq.sh
fi

echo "Changing to ZSH"
sudo chsh -s /bin/zsh $USER

#Enable services
echo "Configuring services..."
for service in "${SERVICES[@]}"; do
  if ! systemctl is-enabled "$service" &>/dev/null; then
    echo "Enabling $service..."
    sudo systemctl enable "$service"
  else
    echo "$service is already enabled"
  fi
done

#Disable this meaningless service
sudo systemctl disable NetworkManager-wait-online

echo "Setup complete! You may want to reboot your system."
