#!/bin/bash

cd ~/dotfiles/

# Exit on any error
set -e

# Source utility functions
source scripts/utils.sh

# Source the package list
source scripts/packages.conf

# Source stow list
source scripts/stow.conf

# Stopping zapret if its running
pgrep -x nfqws >/dev/null && sudo systemctl stop zapret

# Parse command line arguments
parse_arguments "$@"

echo "Starting the system setup..."

# Adding the easter egg
echo "Adding the secret sauce"

grep -q "^[[:space:]]*ILoveCandy" /etc/pacman.conf || sudo sed -i -e "s/^[[:space:]]*#\?Color/Color/" -e "/^[[:space:]]*Color/ a ILoveCandy" /etc/pacman.conf
# Update the system first
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install yay AUR helper if not present
setup_yay

#Install Headers
install_kernel_headers

# Install all packages
echo "Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"
stow_group "${STOW_SYSTEM[@]}"

echo "Installing development tools..."
install_packages "${DEV_TOOLS[@]}"
stow_group "${STOW_DEV[@]}"

echo "Installing system maintenance tools..."
install_packages "${MAINTENANCE[@]}"

echo "Installing desktop environment..."
install_packages "${DESKTOP[@]}"
stow_group "${STOW_DESKTOP[@]}"

echo "Installing media packages..."
install_packages "${MEDIA[@]}"
stow_group "${STOW_MEDIA[@]}"

echo "Installing fonts..."
install_packages "${FONTS[@]}"

echo "Setting config files"
. scripts/configs-wallpapers.sh

if ask "Do you want to use grub menu?" N; then
  echo "Enabling grub menu and theme."

  sudo bash assets/minegrub-theme/install_theme.sh

  sudo sed -i \
    -e 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' \
    -e 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' \
    -e 's|^#\?GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/minegrub/theme.txt"|' \
    -e 's/^#\?GRUB_GFXPAYLOAD_LINUX=.*/GRUB_GFXPAYLOAD_LINUX=keep/' \
    /etc/default/grub

else
  echo "Disabling grub menu for fast boot."

  sudo sed -i \
    -e 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' \
    -e 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' \
    -e 's|^GRUB_THEME=.*|#GRUB_THEME=|' \
    -e 's/^GRUB_GFXPAYLOAD_LINUX=.*/#GRUB_GFXPAYLOAD_LINUX=keep/' \
    /etc/default/grub
fi

sudo grub-mkconfig -o /boot/grub/grub.cfg

if ask "Do you want to setup auto login?" N; then
  echo "Setting up Autologin"
  . scripts/autologin.sh
else
  echo "Skipping autologin"
fi

if ask "Do you want zapret?" N; then
  . scripts/install-zapret.sh
else
  echo "Uninstalling zapret if its there."
  [ -f /opt/zapret/uninstall_easy.sh ] && sudo /opt/zapret/uninstall_easy.sh </dev/null && sudo rm -rf /opt/zapret
fi

# Some programs just run better as flatpaks. Like discord/spotify
echo "Installing flatpaks"
. scripts/install-flatpaks.sh

## Try to detect discrete GPU first
#gpu=$(lspci | grep -i vga | grep -E -i 'nvidia|amd|ati')
#
#if echo "$gpu" | grep -iq 'nvidia'; then
#  echo "NVIDIA GPU detected."
#  installNvidiaDriver
#fi

if [[ "$GAMEDEV" == true ]]; then
  echo "Installing gamedev specific things"
  install_packages "${GAME_DEV[@]}"
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
