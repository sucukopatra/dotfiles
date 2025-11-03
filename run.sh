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
source scripts/packages.conf

echo "Starting the system setup..."

# Update the system first
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install yay AUR helper if not present
setup_yay

# Adding the easter egg
echo "Adding the secret sauce"
grep -q "^[[:space:]]*ILoveCandy" /etc/pacman.conf ||
  sudo sed -i "/^[[:space:]]*Color/a ILoveCandy" /etc/pacman.conf ||
  echo ILoveCandy | sudo tee -a /etc/pacman.conf >/dev/null

#Install Headers
install_kernel_headers

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

install_packages stow

echo "Setting config files"
. scripts/configs-wallpapers.sh

echo "Installing graphic packages"
. scripts/graphic-card.sh

if ask "Do you want to use grub menu?" Y; then
  echo "Installing minecraft theme for grub."
  sudo bash assets/minegrub-theme/install_theme.sh
else
  echo "Changing wait time"
  sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub && sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

if ask "Do you want to setup auto login?" Y; then
  echo "Setting up Autologin"
  . scripts/autologin.sh
else
  echo "Skipping autologin"
fi

if ask "Do you want zapret?" Y; then
  . scripts/install-zapret.sh
else
  echo "Uninstalling zapret if its there."
  [ -f /opt/zapret/uninstall_easy.sh ] && sudo /opt/zapret/uninstall_easy.sh </dev/null && sudo rm -rf /opt/zapret
fi

# Some programs just run better as flatpaks. Like discord/spotify
echo "Installing flatpaks"
. scripts/install-flatpaks.sh

# Try to detect discrete GPU first
gpu=$(lspci | grep -i vga | grep -E -i 'nvidia|amd|ati' | head -n1)

if echo "$gpu" | grep -iq 'nvidia'; then
  echo "NVIDIA GPU detected."
  installNvidiaDriver
fi

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
