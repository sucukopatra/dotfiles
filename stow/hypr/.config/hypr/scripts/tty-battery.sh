#!/bin/bash
set -u
tput civis                      # hide cursor
trap 'tput cnorm; exit' INT TERM
trap : WINCH                    # redraw immediately on resize

while true; do
  mapfile -t art < <(toilet -w 999 -f bigmono12 "$(</sys/class/power_supply/BAT0/capacity)%" | sed 's/./&&/g')
  left=$(( ($(tput cols) - ${#art[0]}) / 2 )); top=$(( ($(tput lines) - ${#art[@]}) / 2 ))
  printf -v pad '%*s' $(( left < 0 ? 0 : left )) ''

  clear
  printf '\e[%d;1H\e[1;32m' $(( top + 1 ))
  printf '%s\n' "${art[@]/#/$pad}"
  printf '\e[0m'

  sleep 30 & wait $!
done
