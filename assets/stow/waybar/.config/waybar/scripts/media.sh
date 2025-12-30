#!/bin/bash

# Get artist and title from the currently playing player
artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)

# If both are present, print them
if [[ -n "$artist" && -n "$title" ]]; then
    echo "$artist - $title"
else
    echo "No media playing"
fi

