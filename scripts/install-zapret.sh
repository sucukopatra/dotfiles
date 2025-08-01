#!/bin/bash
set -e
echo "Installing zapret and dependencies.."
yay -S --noconfirm --needed zapret bind
sudo cp ~/dotfiles/assets/.conf/zapretconfig /opt/zapret/config

USERNAME=$(whoami)
SUDOERS_LINE="$USERNAME ALL=(ALL) NOPASSWD: /bin/systemctl start zapret"

if sudo grep -qF "$SUDOERS_LINE" /etc/sudoers; then
    echo "Sudoers rule already exists."
else
    echo "Adding sudoers rule..."
    echo "$SUDOERS_LINE" | sudo tee -a /etc/sudoers > /dev/null
    echo "Sudoers rule added."
fi
