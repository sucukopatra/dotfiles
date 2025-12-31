#!/bin/bash

STATUS=$(playerctl status)

if [[ "$STATUS" == "Paused" ]]; then
    playerctl play
else
    playerctl pause
fi

