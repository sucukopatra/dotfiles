#!/bin/bash
pgrep -x nfqws >/dev/null && sudo zapret stop && stopped=1
yay --noconfirm "$@"
ret=$?
[[ $stopped ]] && sudo zapret start
pkill -SIGRTMIN+8 waybar
exit $ret

