#
# ~/.bash_profile
#
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec Hyprland
[[ -f ~/.bashrc ]] && . ~/.bashrc
