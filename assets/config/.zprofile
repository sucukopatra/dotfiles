if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec Hyprland
fi

export PATH="$PATH:/home/ender/.local/bin"

