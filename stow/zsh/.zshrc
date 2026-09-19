# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"
# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Add in snippets
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# Set nvim as default editor
export EDITOR=nvim
export VISUAL=nvim
export PATH="$HOME/.local/bin:$PATH"

# Keybindings
bindkey -v
bindkey '^l' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# Aliases
alias update='yay --noconfirm && flatpak update -y'
alias open='xdg-open'
alias zshrc='nvim ~/.zshrc'
alias home='cd ~'
alias ls='eza --icons --group-directories-first -a --color=always'
alias grep='grep --color=auto'
alias bye='sudo shutdown -h now'
alias fonts='fc-list -f "%{family}\n"'
alias spot='ncspot'
alias lyrics='sptlrx'
alias config='cd ~/.config/'
alias hconfig='nvim ~/.config/hypr/'
alias ..='cd ..'
alias pacup='yay -Rncs $(yay -Qdtq)'
alias tree='eza --tree'
alias lg='lazygit'
alias untar='tar xzf'
#alias pacman='sudo pacman'
alias pullsrv="rsync -avz --exclude='config/' ender@bmo:/srv/docker/ ~/dev/server/docker/"
alias pushsrv="rsync -avz --delete --exclude='config/' ~/dev/server/docker/ ender@bmo:/srv/docker/"
alias make50='make CC=clang CFLAGS="-fsanitize=signed-integer-overflow -fsanitize=undefined -ggdb3 -O0 -std=c11 -Wall -Werror -Wextra -Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -Wshadow" LDLIBS="-lcrypt -lcs50 -lm"'

# Functions
# Deploy the weekly timetable to bmo. Only app/ is deployed, so --delete can
# never reach the server's data/. The trailing slash on "$src/app/" matters:
# without it rsync creates app/app/.
schedule-deploy() {
  local src=~/dev/server/schedule
  local dest=bmo:/srv/docker/config/caddy/webpages/schedule/app/
  local out
  out=$(rsync -az --delete --itemize-changes "$src/app/" "$dest") || return 1
  [[ -z "$out" ]] && { echo "Nothing changed."; return 0; }
  echo "$out"
  if grep -q 'server\.py' <<<"$out"; then
    # Page changes need no restart; server.py does. --force-recreate is not
    # optional: compose compares the service definition, not the code, and
    # server.py arrives through a bind mount -- without it compose prints
    # "Container schedule Running", leaves the old process up, and the newer
    # files 404 while index.html asks for them.
    ssh bmo 'cd /srv/docker && docker compose up -d --force-recreate schedule' \
      && echo "Recreated schedule (server.py changed)."
  fi
}

# Shell integrations
eval "$(fzf --zsh)"

# Init Starship
eval "$(starship init zsh)"

# zoxide must be initialized last, after anything that hooks precmd (e.g. starship)
eval "$(zoxide init --cmd cd zsh)"
