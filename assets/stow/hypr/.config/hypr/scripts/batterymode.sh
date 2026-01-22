#!/bin/bash
HYPRCONF="$HOME/.config/hypr/hyprland.conf"

if grep -q '2560x1600@180' "$HYPRCONF"; then
    # Performance mode

    sed -i \
        -e 's/2560x1600@180/2560x1600@60/' \
        -e 's/\$terminal = kitty/\$terminal = alacritty/' \
        -e '/animations {/,/}/ s/enabled = 1/enabled = 0/' \
        -e '/^decoration {/,/^}/ {
              /rounding = 10/d
              /active_opacity = 0.9/d
              /inactive_opacity = 0.8/d
          }' \
        -e '/blur {/,/^}/ s/enabled = true/enabled = false/' \
        -e '/shadow {/,/^}/ s/enabled = true/enabled = false/' \
        -e 's/^exec-once = waybar/# exec-once = waybar/' \
        -e 's|env = AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1|env = AQ_DRM_DEVICES,/dev/dri/card1:/dev/dri/card0|' \
        "$HYPRCONF"

else
    # Fancy mode

    sed -i \
        -e 's/2560x1600@60/2560x1600@180/' \
        -e 's/\$terminal = alacritty/\$terminal = kitty/' \
        -e '/animations {/,/}/ s/enabled = 0/enabled = 1/' \
        -e '/^decoration {$/a\
  rounding = 10\
  active_opacity = 0.9\
  inactive_opacity = 0.8' \
        -e '/blur {/,/^}/ s/enabled = false/enabled = true/' \
        -e '/shadow {/,/^}/ s/enabled = false/enabled = true/' \
        -e 's|env = AQ_DRM_DEVICES,/dev/dri/card1:/dev/dri/card0|env = AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1|' \
        -e 's/^# exec-once = waybar/exec-once = waybar/' \
        "$HYPRCONF"
fi
        

ZSHRC="$HOME/.zshrc"

if grep -q '^# >>> fancy start$' "$ZSHRC"; then
    # Fancy is ON → turn it OFF
    sed -i '/^# >>> fancy start$/,/^# <<< fancy end$/d' "$ZSHRC"
else
    # Fancy is OFF → turn it ON
    cat >> "$ZSHRC" <<'EOF'
# >>> fancy start
# Fetch
clear && paste <(pokemon-colorscripts -r --no-title) <(printf '\n\n\n'; myfetch) | column -t -s $'\t' | head -n 20

# Init Starship
eval "$(starship init zsh)"
# <<< fancy end
EOF
fi

hyprctl dispatch exit
