# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "${ZINIT_HOME:h}"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

zinit wait lucid light-mode for \
  OMZP::sudo \
  OMZP::archlinux \
  OMZP::command-not-found \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions \
  atload'_zsh_autosuggest_start' \
    zsh-users/zsh-autosuggestions \
  atinit'zicompinit; zicdreplay' \
    zsh-users/zsh-syntax-highlighting

# Set nvim as default editor
export EDITOR=nvim
export VISUAL=nvim

# Keybindings
bindkey -v
KEYTIMEOUT=1
bindkey '^l' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=50000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Completion styling
eval "$(dircolors -b)"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# Aliases
alias open='xdg-open'
alias zshrc='nvim ~/.zshrc'
alias home='cd ~'
alias ls='eza --icons --group-directories-first -a --color=auto'
alias grep='grep --color=auto'
alias bye='systemctl poweroff'
alias fonts='fc-list -f "%{family}\n"'
alias spot='ncspot'
alias config='cd ~/.config/'
alias hconfig='nvim ~/.config/hypr/'
alias ..='cd ..'
alias pacclean='sudo paccache -rk2 && sudo paccache -ruk0'
alias tree='eza --tree'
alias lg='lazygit'
alias untar='tar xf'
#alias pacman='sudo pacman'
alias pullsrv="rsync -avz --exclude='config/' ender@bmo:/srv/docker/ ~/dev/server/docker/"
alias pushsrv="rsync -avz --delete --exclude='config/' ~/dev/server/docker/ ender@bmo:/srv/docker/"
alias make50='make CC=clang CFLAGS="-fsanitize=signed-integer-overflow -fsanitize=undefined -ggdb3 -O0 -std=c11 -Wall -Werror -Wextra -Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -Wshadow" LDLIBS="-lcrypt -lcs50 -lm"'

# Remove orphaned packages, if there are any
pacup() {
  local -a orphans=( ${(f)"$(yay -Qdtq)"} )
  if (( ${#orphans} )); then
    yay -Rncs "${orphans[@]}"
  else
    echo "No orphans to remove."
  fi
}

# Shell integrations
eval "$(fzf --zsh)"

# Init Starship
eval "$(starship init zsh)"

# zoxide must be initialized last, after anything that hooks precmd (e.g. starship)
eval "$(zoxide init --cmd cd zsh)"
