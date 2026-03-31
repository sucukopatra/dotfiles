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
  local repo_dir backup_dir rel target
  repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  backup_dir="$HOME/.config-backup/$(date +%Y%m%d_%H%M%S)"

  for pkg in "$@"; do
    echo "Stowing: $pkg"
    while IFS= read -r rel; do
      target="$HOME/$rel"
      if [[ -e "$target" && ! -L "$target" ]]; then
        mkdir -p "$backup_dir/$(dirname "$rel")"
        cp -a "$target" "$backup_dir/$rel"
      fi
      rm -rf "$target"
    done < <(
      find "$repo_dir/stow/$pkg" -not -type d \
        | sed "s|$repo_dir/stow/$pkg/||"
    )
    stow -d "$repo_dir/stow" -t "$HOME" --restow "$pkg"
  done

  [[ -d "$backup_dir" ]] && echo "Backups saved to: $backup_dir"
}
