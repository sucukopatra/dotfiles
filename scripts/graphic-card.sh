#!/bin/bash
set -e

# Try to detect discrete GPU first
gpu=$(lspci | grep -i vga | grep -E -i 'nvidia|amd|ati' | head -n1)

if echo "$gpu" | grep -iq 'nvidia'; then
  echo "NVIDIA GPU detected."
  LIBVA_DIR="$HOME/.local/share/linutil/libva"
  MPV_CONF="$HOME/.config/mpv/mpv.conf"

  checkNvidiaHardware() {
    # Refer https://nouveau.freedesktop.org/CodeNames.html for model code names
    model=$(lspci -k | grep -A 2 -E "(VGA|3D)" | grep NVIDIA | sed 's/.*Corporation //;s/ .*//' | cut -c 1-2)
    case "$model" in
      GM | GP | GV) return 1 ;;
      TU | GA | AD) return 0 ;;
      *) printf "%b\n" "Unsupported hardware." && exit 1 ;;
    esac
  }

  checkIntelHardware() {
    model=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ':' -f 2 | cut -c 2-3)
    [ "$model" -ge 11 ]
  }

  setKernelParam() {
    PARAMETER="$1"

    if grep -q "$PARAMETER" /etc/default/grub; then
      printf "%b\n" "NVIDIA modesetting is already enabled in GRUB."
    else
      sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\"$/ $PARAMETER\"/" /etc/default/grub
      printf "%b\n" "Added $PARAMETER to /etc/default/grub."
      sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
  }

  setupHardwareAcceleration() {

    sudo pacman -S --needed --noconfirm libva-nvidia-driver

    mkdir -p "$HOME/.local/share/linutil"
    if [ -d "$LIBVA_DIR" ]; then
      rm -rf "$LIBVA_DIR"
    fi

    printf "%b\n" "Cloning libva from https://github.com/intel/libva in ${LIBVA_DIR}"
    git clone --branch=v2.22-branch --depth=1 https://github.com/intel/libva "$LIBVA_DIR"

    mkdir -p "$LIBVA_DIR/build"
    cd "$LIBVA_DIR/build" && arch-meson .. -Dwith_legacy=nvctrl && ninja
    sudo ninja install

    sudo sed -i '/^MOZ_DISABLE_RDD_SANDBOX/d' "/etc/environment"
    sudo sed -i '/^LIBVA_DRIVER_NAME/d' "/etc/environment"

    printf "LIBVA_DRIVER_NAME=nvidia\nMOZ_DISABLE_RDD_SANDBOX=1" | sudo tee -a /etc/environment >/dev/null

    printf "%b\n" "Hardware Acceleration setup completed successfully."

    mkdir -p "$HOME/.config/mpv"
    if [ -f "$MPV_CONF" ]; then
      sed -i '/^hwdec/d' "$MPV_CONF"
    fi
    printf "hwdec=auto" | tee -a "$MPV_CONF" >/dev/null
    printf "%b\n" "MPV Hardware Acceleration enabled successfully."
  }

  installDriver() {
    if checkIntelHardware; then
      setKernelParam "ibt=off"
    fi

    # Refer https://wiki.archlinux.org/title/NVIDIA/Tips_and_tricks#Preserve_video_memory_after_suspend
    setKernelParam "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service

    printf "%b\n" "Driver installed successfully."
    setupHardwareAcceleration

    printf "%b\n" "Please reboot your system for the changes to take effect."
  }

  sudo pacman -S --needed --noconfirm nvidia nvidia-utils nvidia-dkms nvidia-settings libva-nvidia-driver base-devel dkms ninja meson git
elif echo "$gpu" | grep -iq 'amd\|ati'; then
  echo "AMD GPU detected."
  sudo pacman -S --noconfirm xf86-video-amdgpu mesa
else
  # fallback to iGPU
  igpu=$(lspci | grep -i vga | grep -E -i 'intel|amd|ati' | head -n1)
  echo "No discrete GPU found. Using integrated GPU: $igpu"
  # Intel iGPU usually works with mesa by default
  sudo pacman -S --needed --noconfirm mesa
fi
