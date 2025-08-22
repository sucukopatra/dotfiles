#!/bin/bash
set -e
sudo pacman -S --needed --noconfirm uv
uv tool install "viu-media[standard]"
uv tool update-shell
