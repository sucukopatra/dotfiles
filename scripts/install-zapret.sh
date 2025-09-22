#!/bin/bash
set -euo pipefail # fail on errors, unset vars, pipeline errors

reinstall() {
  curl -L -o /tmp/zapret.zip https://github.com/bol-van/zapret/releases/download/v71.3/zapret-v71.3.zip
  sudo unzip /tmp/zapret.zip -d /opt/
  sudo rm /tmp/zapret.zip
  sudo mv /opt/zapret-v71.3 /opt/zapret
  sudo chown -R $USER /opt/zapret
  bash /opt/zapret/install_easy.sh </dev/null
  sudo systemctl stop zapret
  sudo chown -R $USER /opt/zapret
  echo "Copying config files"
  cp -r ~/dotfiles/assets/.conf/zapretconfig/* /opt/zapret/
  sudo systemctl disable --now zapret-list-update.timer
  sudo setcap cap_net_raw+ep /opt/zapret/binaries/linux-x86_64/nfqws
  echo "Zapret latest release installed in /opt/zapret."
}

cmp -s ~/dotfiles/assets/.conf/zapretconfig/config /etc/zapret/config || {
  sudo /opt/zapret/uninstall_easy.sh </dev/null
  sudo rm -rf /opt/zapret
  reinstall
}
