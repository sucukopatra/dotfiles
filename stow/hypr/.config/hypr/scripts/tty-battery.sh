#!/bin/bash
tput civis                      # hide cursor
trap 'tput cnorm; exit' INT TERM
trap : WINCH                    # redraw immediately on resize

while true; do
  art=$(toilet -w 999 -f bigmono12 "$(cat /sys/class/power_supply/BAT0/capacity)%" | sed 's/./&&/g')
  cols=$(tput cols); rows=$(tput lines)
  h=$(wc -l <<<"$art")
  w=$(awk '{ if (length($0) > m) m = length($0) } END { print m }' <<<"$art")
  left=$(( (cols - w) / 2 )); top=$(( (rows - h) / 2 ))
  (( left < 0 )) && left=0

  clear
  printf '\e[1;32m'
  for ((i = 0; i < top; i++)); do echo; done
  sed "s/^/$(printf '%*s' "$left" '')/" <<<"$art"
  printf '\e[0m'

  sleep 30 & wait $!
done
