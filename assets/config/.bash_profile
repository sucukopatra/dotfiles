#
# ~/.bash_profile
#
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec Hyprland
fi
[[ -f ~/.bashrc ]] && . ~/.bashrc

# Created by `pipx` on 2025-08-02 19:52:30
export PATH="$PATH:/home/ender/.local/bin"
