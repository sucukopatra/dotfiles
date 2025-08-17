# ~/.bashrc
clear && paste <(pokemon-colorscripts -r --no-title) <(printf '\n\n\n'; myfetch) | column -t -s $'\t' | head -n 20
eval "$(starship init bash)"
[[ $- != *i* ]] && return

set -o vi

# Aliases
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
alias cd..='cd ..'
alias ..='cd ..'
alias fa='fastanime anilist'
alias z='sudo zapret start'
alias zs='sudo zapret stop'
alias todo='nvim ~/todo.md'
alias pushdots='(cd ~/dotfiles && git add -A && git commit -m "Update dotfiles: $(date +%Y-%m-%d\ %H:%M)" && git push && echo "🚀 Dotfiles pushed!")'
alias pushserver='(cd ~/media-server && git add -A && git commit -m "Update dotfiles: $(date +%Y-%m-%d\ %H:%M)" && git push && echo "🚀 Dotfiles pushed!")'
alias updateconf='(cd ~/dotfiles/assets && stow -D -t ~ config && stow -t ~ config)'
alias at='cd ~/Videos/Shows/Adventure-Time/Season 01/'
alias avatar='cd ~/Videos/Shows/Avatar-The-Last-Airbender/Avatar The Last Airbender S01/'
scrcpy-auto() {
    timeout 2s adb connect 192.168.0.29 >/dev/null
    if adb devices | grep -q '192.168.0.29'; then
        scrcpy -s 192.168.0.29
        return
    fi

    timeout 2s adb connect phonox >/dev/null
    if adb devices | grep -q 'phonox'; then
        scrcpy -s phonox
    fi
}



wrap_zapret() {
  pgrep -x nfqws >/dev/null && sudo zapret stop && stopped=1
  "$@"
  [[ $stopped ]] && sudo zapret start
}

pacman() { wrap_zapret sudo pacman "$@"; }
yay() { wrap_zapret command yay "$@"; }


# Created by `pipx` on 2025-08-02 19:52:30
export PATH="$PATH:/home/ender/.local/bin"
