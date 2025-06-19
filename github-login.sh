#!/bin/bash
set -e

EMAIL="endercortuk@proton.me"
USERNAME="sucukopatra"
REPO="git@github.com:${USERNAME}/dotfiles.git"
KEY=~/.ssh/id_ed25519
DOTFILES_DIR=~/dotfiles

git config --global user.email "$EMAIL"
git config --global user.name "$USERNAME"

if [ ! -f "$KEY" ]; then
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY" -N ""
fi

eval "$(ssh-agent -s)" >/dev/null
ssh-add "$KEY"

cat "${KEY}.pub"
xdg-open "https://github.com/settings/ssh/new" >/dev/null 2>&1 &

read -p "[!] Press Enter after adding the SSH key to GitHub..."

ssh -T git@github.com || true

if [ -d "$DOTFILES_DIR/.git" ]; then
  cd "$DOTFILES_DIR"
  git remote set-url origin "$REPO"
fi
