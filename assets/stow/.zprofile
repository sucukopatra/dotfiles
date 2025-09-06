# Start Hyprland
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec Hyprland > /dev/null
fi

export PATH="$PATH:/home/ender/.local/bin"

