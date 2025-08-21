#!/bin/bash
set -euo pipefail # fail on errors, unset vars, pipeline errors

[ -d "/opt/zapret" ] && sudo /opt/zapret/uninstall_easy.sh </dev/null && sudo rm -rf /opt/zapret

curl -L -o /tmp/zapret.zip https://github.com/bol-van/zapret/releases/download/v71.3/zapret-v71.3.zip
sudo unzip /tmp/zapret.zip -d /opt/
sudo rm /tmp/zapret.zip
sudo mv /opt/zapret-v71.3 /opt/zapret
sudo chown -R $USER /opt/zapret
bash /opt/zapret/install_easy.sh </dev/null
sudo chown -R $USER /opt/zapret
echo "Copying config files"
cp -r ~/dotfiles/assets/.conf/zapretconfig/* /opt/zapret/

echo "Zapret latest release installed in /opt/zapret."
