#!/bin/bash
yay -S zapret bind 
sudo cp ~/dotfiles/zapretconfig /opt/zapret/config
systemctl start zapret
systemctl enable zapret
