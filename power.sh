#!/bin/bash
set -euo pipefail

# power.sh — opt-in laptop power tweaks. NOT called by run.sh; run it yourself:
#   ./power.sh
#
# These live here (and not under stow/) because they target /etc and systemd
# unit state, which stow doesn't manage.
#
# What it does
# ------------
# Lets the discrete NVIDIA GPU drop into RTD3 (D3cold, ~0W) when idle, by forcing
# Hyprland to render on the integrated GPU and never load the NVIDIA EGL stack:
#
#   1. udev symlinks  /dev/dri/intel-igpu and /dev/dri/nvidia-dgpu, pinned to PCI
#      addresses (detected below) so they survive card0/card1 renumbering between
#      boots. See the Hyprland Multi-GPU wiki for the technique.
#   2. /etc/environment vars (read by pam_env at login):
#        AQ_DRM_DEVICES                 -> Aquamarine uses only the iGPU as a DRM
#                                          device, never opening the nvidia KMS
#                                          node. It's read at backend init, before
#                                          Hyprland parses its own config, so the
#                                          config `env =`/hl.env is too late on a
#                                          ly/non-uwsm session -> it goes here.
#        __EGL_VENDOR_LIBRARY_FILENAMES -> libglvnd loads only the mesa EGL vendor,
#                                          so libnvidia-egl is never pulled into
#                                          Hyprland and /dev/nvidia0 is never opened.
#   3. TLP enabled. On battery it sets the dGPU's HDMI-audio function to runtime
#      'auto', the last thing needed for the whole PCI device to reach D3cold.
#
# Without all three, Hyprland holds the dGPU open and it never sleeps.

ENV_FILE="/etc/environment"

# Detect the two display controllers by vendor (lspci class 03xx = display).
# lspci prints the bus address without the domain, e.g. "00:02.0"; udev wants the
# domain-qualified form "0000:00:02.0".
intel_bdf="$(lspci -d ::03xx | grep -i 'intel' | head -1 | cut -f1 -d' ')"
nvidia_bdf="$(lspci -d ::03xx | grep -i 'nvidia' | head -1 | cut -f1 -d' ')"

if [[ -z "$intel_bdf" || -z "$nvidia_bdf" ]]; then
  echo "ERROR: could not detect both an Intel and an NVIDIA display controller." >&2
  echo "       lspci -d ::03xx shows:" >&2
  lspci -d ::03xx >&2
  exit 1
fi

INTEL_PCI="0000:$intel_bdf"
NVIDIA_PCI="0000:$nvidia_bdf"
echo "Detected iGPU $INTEL_PCI (intel-igpu), dGPU $NVIDIA_PCI (nvidia-dgpu)"

ENV_VARS=(
  "AQ_DRM_DEVICES=/dev/dri/intel-igpu"
  "__EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json"
)

# Write a file via sudo only if absent or different, to keep runs idempotent.
write_rule() {
  local path="$1" content="$2"
  if [[ -f "$path" ]] && [[ "$(cat "$path")" == "$content" ]]; then
    echo "  unchanged: $path"
  else
    printf '%s\n' "$content" | sudo tee "$path" >/dev/null
    echo "  written:   $path"
  fi
}

echo "Requesting sudo once..."
sudo -v

echo "Installing GPU dev-path udev symlink rules..."
write_rule /etc/udev/rules.d/intel-igpu-dev-path.rules \
  "KERNEL==\"card*\", KERNELS==\"$INTEL_PCI\", SUBSYSTEM==\"drm\", SUBSYSTEMS==\"pci\", SYMLINK+=\"dri/intel-igpu\""
write_rule /etc/udev/rules.d/nvidia-dgpu-dev-path.rules \
  "KERNEL==\"card*\", KERNELS==\"$NVIDIA_PCI\", SUBSYSTEM==\"drm\", SUBSYSTEMS==\"pci\", SYMLINK+=\"dri/nvidia-dgpu\""

echo "Reloading udev so the symlinks appear..."
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=drm

echo "Writing dGPU power-saving vars to $ENV_FILE..."
for line in "${ENV_VARS[@]}"; do
  if grep -qxF "$line" "$ENV_FILE" 2>/dev/null; then
    echo "  already set: $line"
  else
    echo "$line" | sudo tee -a "$ENV_FILE" >/dev/null
    echo "  added:       $line"
  fi
done

echo "Enabling TLP..."
if command -v tlp >/dev/null 2>&1; then
  sudo systemctl enable --now tlp.service
  echo "  tlp.service enabled"
else
  echo "  WARNING: tlp not installed. Install it (it's in packages.conf) or the"
  echo "           dGPU may stay awake on battery."
fi

echo
echo "Done. Log out and back in (or reboot) for the env vars to take effect."
echo "Verify on battery:"
echo "  cat /sys/bus/pci/devices/$NVIDIA_PCI/power/runtime_status   # want: suspended"
