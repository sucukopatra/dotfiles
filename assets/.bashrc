# ~/.bashrc
paste <(pokemon-colorscripts -r | tail -n +2) <(myfetch) | column
eval "$(starship init bash)"
[[ $- != *i* ]] && return

set -o vi

# Aliases
alias bashrc='vim ~/.bashrc'
alias home='cd ~'
alias ls='eza -F -a --color=always'
alias pacman='sudo pacman'
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
alias hconfig='vim ~/.config/hypr/hyprland.conf'
alias dots='cd ~/dotfiles/'
alias clock='clock-rs'
alias cd..='cd ..'
alias fa='fastanime anilist'
