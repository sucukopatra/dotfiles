#!/bin/bash

if pgrep -x pulsemixer>/dev/null; then
  pkill pulsemixer
else
    kitty -T pulsemixer pulsemixer
fi
