#!/bin/bash

if pgrep -x wofi > /dev/null; then
    pkill wofi
else
    wofi -n &
fi

