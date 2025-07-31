#!/bin/bash
WALLPAPER_DIR="$HOME/wallpapers/walls"
#I dont know what the fuck I am doing

main() {

    # Pick a random wallpaper
    selected_wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | shuf -n1)
    # Set the wallpaper
    swww img "$selected_wallpaper" --transition-type any --transition-fps 60 --transition-duration .5

    # Generate colors with wal
    wal -i "$selected_wallpaper" -n --cols16

    # Reload swaync CSS
    swaync-client --reload-css

    # Set Kitty theme
    cat ~/.cache/wal/colors-kitty.conf > ~/.config/kitty/current-theme.conf

    # Update Cava colors
    color1=$(awk -F\' '/color2=/ {print $2}' ~/.cache/wal/colors.sh)
    color2=$(awk -F\' '/color3=/ {print $2}' ~/.cache/wal/colors.sh)
    cava_config="$HOME/.config/cava/config"
    sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '$color1'/" "$cava_config"
    sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '$color2'/" "$cava_config"
    pkill -USR2 cava 2>/dev/null

    # Optional: save current wallpaper
    cp "$selected_wallpaper" ~/wallpapers/pywallpaper.jpg
}

main
