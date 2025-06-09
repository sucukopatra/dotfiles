git config --global user.email "endercortuk@proton.me"
git config --global user.name "sucukopatra"
ssh-keygen -t ed25519 -C "endercortuk@proton.me"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
copy to -> https://github.com/settings/ssh/new
git remote set-url origin git@github.com:sucukopatra/dotfiles.git
