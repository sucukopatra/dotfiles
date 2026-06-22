#!/bin/bash
set -euo pipefail

# power.sh — opt-in laptop power tweaks. NOT called by run.sh; run it yourself:
#   ./power.sh
#
# These live here (and not under stow/) because they target /etc, which stow
# doesn't manage.
#
# What it does
# ------------
# Lets the discrete RTX 5060 drop into RTD3 (D3cold, ~0W) when idle, by forcing
# Hyprland to render on the Intel iGPU and never load the NVIDIA EGL stack. Two
# vars do this, and they MUST be in /etc/environment (read by pam_env at login),
# not the Hyprland config:
#
#   AQ_DRM_DEVICES                 -> Aquamarine uses only the iGPU as a DRM
#                                     device, so it never opens the nvidia KMS
#                                     node. Read at backend init, before Hyprland
#                                     parses its own config -> config env = is too
#                                     late, which is why it goes here.
#   __EGL_VENDOR_LIBRARY_FILENAMES -> libglvnd loads only the mesa EGL vendor, so
#                                     libnvidia-egl is never pulled into Hyprland
#                                     and /dev/nvidia0 is never opened.
#
# Without both, Hyprland holds the dGPU open and it never sleeps.
#
# The other half (suspending the dGPU's HDMI-audio function so the whole PCI
# device can reach D3cold) is handled automatically by TLP on battery. Make sure
# `tlp` is installed and enabled, otherwise the dGPU may stay awake on battery.
#
# Dependency: AQ_DRM_DEVICES uses the /dev/dri/intel-igpu symlink, which is
# created by /etc/udev/rules.d/intel-igpu-dev-path.rules on this machine. If that
# rule is missing (e.g. fresh install), swap the value below for the stable
# by-path form, e.g. /dev/dri/by-path/pci-0000:00:02.0-card.

ENV_FILE="/etc/environment"

ENV_VARS=(
  "AQ_DRM_DEVICES=/dev/dri/intel-igpu"
  "__EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json"
)

echo "Writing dGPU power-saving vars to $ENV_FILE (needs sudo)..."
for line in "${ENV_VARS[@]}"; do
  if grep -qxF "$line" "$ENV_FILE" 2>/dev/null; then
    echo "  already set: $line"
  else
    echo "$line" | sudo tee -a "$ENV_FILE" >/dev/null
    echo "  added:       $line"
  fi
done

if ! command -v tlp >/dev/null 2>&1; then
  echo
  echo "WARNING: tlp not found. Install and enable it, or the dGPU may stay awake"
  echo "         on battery (it suspends the GPU's HDMI-audio function for you)."
fi

echo
echo "Done. Log out and back in (or reboot) for these to take effect."
echo "Verify on battery:"
echo "  cat /sys/bus/pci/devices/0000:02:00.0/power/runtime_status   # want: suspended"
