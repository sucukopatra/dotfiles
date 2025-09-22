#!/bin/bash
set -euo pipefail

# --- Check udev rules for Steam ---
RULES_DIR="/usr/lib/udev/rules.d"
STEAM_RULES=("60-steam-input.rules" "60-steam-vr.rules")

MISSING=0
for rule in "${STEAM_RULES[@]}"; do
  if [[ ! -f "$RULES_DIR/$rule" ]]; then
    echo "Missing $rule — installing steam rules..."
    sudo pacman -S --needed --noconfirm steam
    MISSING=1
  fi
done

if [[ $MISSING -eq 1 ]]; then
  echo "Reloading udev rules..."
  sudo udevadm control --reload-rules
  sudo udevadm trigger
else
  echo "Steam udev rules already present."
fi

# --- Check and load uinput ---
if ! lsmod | grep uinput; then
  echo "uinput not loaded — loading now..."
  sudo modprobe uinput
else
  echo "uinput is already loaded."
fi

# --- Make uinput permanent ---
MODULES_FILE="/etc/modules-load.d/uinput.conf"
if [[ ! -f "$MODULES_FILE" ]]; then
  echo "Making uinput permanent..."
  echo "uinput" | sudo tee "$MODULES_FILE" >/dev/null
else
  echo "uinput already set to load at boot."
fi

# --- Ensure user is in input group ---
if ! groups $USER | grep -qw input; then
  sudo gpasswd -a "$USER" input
  echo "Added $USER to 'input' group. Log out and back in for it to apply."
fi

echo "Controller is fixed."
