#!/bin/bash

prompt_yn() {
  local msg="$1" default="${2:-y}"
  if [[ "${YES_ALL:-0}" == "1" ]]; then
    echo "$msg [auto: y]"
    return 0
  fi
  local indicator
  [[ "$default" == "y" ]] && indicator="[Y/n]" || indicator="[y/N]"
  read -r -p "$msg $indicator: " ans
  ans="${ans:-$default}"
  [[ "$ans" =~ ^[Yy] ]]
}

enable_services() {
    local service

    for service; do
        sudo systemctl enable --now "$service"
    done
}

enable_user_services() {
    local service

    for service; do
        systemctl --user enable --now "$service"
    done
}

is_installed() {
  pacman -Qi "$1" &>/dev/null
}

is_group_installed() {
  pacman -Qg "$1" &>/dev/null
}

install_packages() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg" && ! is_group_installed "$pkg"; then
      to_install+=("$pkg")
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then
    echo "installing: ${to_install[*]}"
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

write_rule() {
  local path="$1" content="$2"
  if [[ -f "$path" ]] && [[ "$(cat "$path")" == "$content" ]]; then
    echo "  unchanged: $path"
  else
    printf '%s\n' "$content" | sudo tee "$path" >/dev/null
    echo "  written:   $path"
  fi
}

# Detect Intel/NVIDIA display controllers by PCI vendor and write stable udev
# symlinks (/dev/dri/intel-igpu, /dev/dri/nvidia-dgpu) pinned to PCI addresses
# so they survive card0/card1 renumbering between boots.
setup_gpu_udev() {
  local intel_bdf nvidia_bdf intel_pci nvidia_pci
  intel_bdf="$(lspci -d ::03xx | grep -i 'intel' | head -1 | cut -f1 -d' ')"
  nvidia_bdf="$(lspci -d ::03xx | grep -i 'nvidia' | head -1 | cut -f1 -d' ')"

  if [[ -z "$intel_bdf" || -z "$nvidia_bdf" ]]; then
    echo "  WARNING: could not detect both Intel and NVIDIA display controllers; skipping." >&2
    return 0
  fi

  intel_pci="0000:$intel_bdf"
  nvidia_pci="0000:$nvidia_bdf"
  echo "  iGPU $intel_pci -> /dev/dri/intel-igpu"
  echo "  dGPU $nvidia_pci -> /dev/dri/nvidia-dgpu"

  write_rule /etc/udev/rules.d/intel-igpu-dev-path.rules \
    "KERNEL==\"card*\", KERNELS==\"$intel_pci\", SUBSYSTEM==\"drm\", SUBSYSTEMS==\"pci\", SYMLINK+=\"dri/intel-igpu\""
  write_rule /etc/udev/rules.d/nvidia-dgpu-dev-path.rules \
    "KERNEL==\"card*\", KERNELS==\"$nvidia_pci\", SUBSYSTEM==\"drm\", SUBSYSTEMS==\"pci\", SYMLINK+=\"dri/nvidia-dgpu\""

  sudo udevadm control --reload
  sudo udevadm trigger --subsystem-match=drm
}

stow_packages() {
  local repo_dir
  repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

  local -a sys_dirs=(etc usr lib lib64 var opt srv run)
  local pkg dir top sys src rel transformed target_path target

  for pkg in "$@"; do
    target="$HOME"

    for dir in "$repo_dir/stow/$pkg"/*/; do
      [[ -d "$dir" ]] || continue
      top="$(basename "$dir")"
      for sys in "${sys_dirs[@]}"; do
        [[ "$top" == "$sys" ]] && { target="/"; break 2; }
      done
    done

    while IFS= read -r -d '' src; do
      rel="${src#"$repo_dir/stow/$pkg/"}"
      transformed="$(printf '%s' "$rel" | sed 's|/dot-|/.|g; s|^dot-|.|')"
      target_path="${target%/}/$transformed"
      if [[ -f "$target_path" && ! -L "$target_path" ]]; then
        [[ "$target" == "/" ]] && sudo rm -f "$target_path" || rm -f "$target_path"
      fi
    done < <(find "$repo_dir/stow/$pkg" -type f -print0)

    if [[ "$target" == "/" ]]; then
      sudo stow --dotfiles --no-folding -R --override='.*' -d "$repo_dir/stow" -t "$target" "$pkg"
    else
      stow --dotfiles --no-folding -R --override='.*' -d "$repo_dir/stow" -t "$target" "$pkg"
    fi
  done
}
