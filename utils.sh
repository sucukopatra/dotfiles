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

install_yay() {
  if ! is_installed "yay"; then
    local tmpdir
    tmpdir="$(mktemp -d)"

    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (
      cd "$tmpdir/yay"
      makepkg -si --noconfirm
    )
    rm -rf "$tmpdir"
  fi
}

stow_packages() {
  local repo_dir pkg
  repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  for pkg in "$@"; do
    stow --dotfiles -v -R --override='.*' -d "$repo_dir/stow" -t "$HOME" "$pkg"
  done
}
