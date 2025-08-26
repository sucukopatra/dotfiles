#!/bin/bash
set -e
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
USER_NAME=$(whoami)
GETTY_DIR="/etc/systemd/system/getty@tty1.service.d"
sudo tee "$GETTY_DIR/autologin.conf" >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -a $USER_NAME - \$TERM
EOF
echo "Autologin enabled for user: $USER_NAME on tty1"
