# ~/.bashrc
clear && paste <(pokemon-colorscripts -r --no-title) <(echo "" && echo "" && echo "" && myfetch) | column | head -n 20
eval "$(starship init bash)"
[[ $- != *i* ]] && return

set -o vi

# Aliases
alias ..='cd ..'
alias vim='nvim'
alias bashrc='nvim ~/.bashrc'
alias home='cd ~'
alias ls='eza -F -a --color=always'
alias pacup='sudo pacman -Rns $(pacman -Qdtq)'
alias grep='grep --color=auto'
alias pool='clear && asciiquarium'
alias f='clear && myfetch -i e -f -c 16 -C "  "'
alias bye='sudo shutdown -h now'
alias fonts='fc-list -f "%{family}\n"'
alias tasks='btm'
alias spot='ncspot'
alias lyrics='sptlrx'
alias config='cd ~/.config/'
alias hconfig='nvim ~/.config/hypr/hyprland.conf'
alias nconfig='nvim ~/.config/nvim/init.lua'
alias dots='cd ~/dotfiles/'
alias clock='clock-rs'
alias timer='clock-rs timer 5400'
alias cd..='cd ..'
alias fa='fastanime anilist'
alias z='sudo zapret start'
alias zs='sudo zapret stop'
alias todo='nvim ~/todo.md'


pacman() { sudo systemctl stop zapret; sudo /usr/bin/pacman "$@"; sudo systemctl start zapret; }
yay() { sudo systemctl stop zapret; command yay "$@"; sudo systemctl start zapret; }

