#!/bin/bash

mv ~/.config/hypr/modules/active-gpu.conf ~/.config/hypr/modules/tmp
mv ~/.config/hypr/modules/disabled-gpu.conf ~/.config/hypr/modules/active-gpu.conf
mv ~/.config/hypr/modules/tmp ~/.config/hypr/modules/disabled-gpu.conf
