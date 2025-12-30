#!/bin/bash

if pgrep -x ydotoold >/dev/null; then
  pkill ydotoold
else
  ydotoold &
  ydotool click 40
fi
