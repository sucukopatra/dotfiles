#!/bin/bash

ACTIVE=~/.config/hypr/modules/active-gpu.conf
DISABLED=~/.config/hypr/modules/disabled-gpu.conf
TMP=~/.config/hypr/modules/tmp

mv "$ACTIVE" "$TMP"
mv "$DISABLED" "$ACTIVE"
mv "$TMP" "$DISABLED"

if grep -q "dgpu" "$ACTIVE"; then
    notify-send "GPU Mode" "NVIDIA (dGPU) active"
else
    notify-send "GPU Mode" "Intel (iGPU) active"
fi
