# Fetch
clear && paste <(pokemon-colorscripts -r --no-title) <(printf '\n\n\n'; myfetch) | column -t -s $'\t' | head -n 20

# Init Starship
eval "$(starship init zsh)"

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
alias vim='nvim'
alias zshrc='nvim ~/.zshrc'
alias home='cd ~'
alias ls='eza --icons --group-directories-first -a --color=always'
alias grep='grep --color=auto'
alias pool='clear && asciiquarium'
alias bye='sudo shutdown -h now'
alias fonts='fc-list -f "%{family}\n"'
alias spot='ncspot'
alias lyrics='sptlrx'
alias config='cd ~/.config/'
alias hconfig='nvim ~/.config/hypr/hyprland.conf'
alias dots='cd ~/dotfiles/'
alias ..='cd ..'
alias fa='viu anilist'
alias z='sudo systemctl start zapret'
alias zs='sudo systemctl stop zapret'
alias zstatus='sudo systemctl status zapret'
alias dotpush='(cd ~/dotfiles && git add -A && git commit -m "Update dotfiles: $(date +%Y-%m-%d\ %H:%M)" && git push && echo "🚀 Dotfiles pushed!")'
alias updateconf='(cd ~/dotfiles/assets && stow -D -t ~ config && stow --adopt -t ~ config)'
alias pacup='yay -Yc'
alias pacman='sudo pacman'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
