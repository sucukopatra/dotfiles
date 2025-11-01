#!/bin/bash

# Function to check if a package is installed
is_installed() {
  pacman -Qi "$1" &>/dev/null
}

# Function to check if a package is installed
is_group_installed() {
  pacman -Qg "$1" &>/dev/null
}

# Function to install packages if not already installed
install_packages() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg" && ! is_group_installed "$pkg"; then
      to_install+=("$pkg")
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then
    echo "Installing: ${to_install[*]}"
    yay -S --needed --noconfirm "${to_install[@]}"
  fi
}

ask() {
  # http://djm.me/ask
  while true; do

    if [ "${2:-}" = "Y" ]; then
      prompt="Y/n"
      default=Y
    elif [ "${2:-}" = "N" ]; then
      prompt="y/N"
      default=N
    else
      prompt="y/n"
      default=
    fi

    # Ask the question - use /dev/tty in case stdin is redirected from somewhere else
    read -p "$1 [$prompt] " REPLY </dev/tty

    # Default?
    if [ -z "$REPLY" ]; then
      REPLY=$default
    fi

    # Check if the reply is valid
    case "$REPLY" in
      Y* | y*) return 0 ;;
      N* | n*) return 1 ;;
    esac

  done
}

install_kernel_headers() {
  installed_kernels=$(pacman -Q | grep -E '^linux(| |-rt|-rt-lts|-hardened|-zen|-lts)[^-headers]' | cut -d ' ' -f 1)
  for kernel in $installed_kernels; do
    header="${kernel}-headers"
    printf "%b\n" "Installing headers for $kernel..."

    if ! sudo pacman -S --needed --noconfirm "$header"; then
      exit 1
    fi
    printf "%b\n" "Continuing..."
  done
}

setup_yay() {
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
}

# EXAMPLE USAGE:

# if ask "Do you want to do such-and-such?"; then
#     echo "Yes"
# else
#     echo "No"
# fi
#
# # Default to Yes if the user presses enter without giving an answer:
# if ask "Do you want to do such-and-such?" Y; then
#     echo "Yes"
# else
#     echo "No"
# fi
#
# # Default to No if the user presses enter without giving an answer:
# if ask "Do you want to do such-and-such?" N; then
#     echo "Yes"
# else
#     echo "No"
# fi
#
# # Only do something if you say Yes
# if ask "Do you want to do such-and-such?"; then
#     said_yes
# fi
#
# # Only do something if you say No
# if ! ask "Do you want to do such-and-such?"; then
#     said_no
# fi
#
# # Or if you prefer the shorter version:
# ask "Do you want to do such-and-such?" && said_yes
#
# ask "Do you want to do such-and-such?" || said_no
