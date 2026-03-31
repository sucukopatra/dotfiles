#!/bin/bash

mv ~/.config/hypr/modules/pgpu.conf ~/.config/hypr/modules/tmp
mv ~/.config/hypr/modules/sgpu.conf ~/.config/hypr/modules/pgpu.conf
mv ~/.config/hypr/modules/tmp ~/.config/hypr/modules/sgpu.conf
