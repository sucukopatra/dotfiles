#!/bin/bash
# Sets a random wallpaper from $WALLPAPER_DIR with awww, never repeating the current one.
# awww always shows $NEXT, a hard link that is moved to the next pick right after each change,
# so the daemon's own cache restore brings up a fresh wallpaper at login.
set -uo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/media/photos/wallpapers}"
NEXT="${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper"

queue_next() {
  local skip=() pick
  [[ -e "$NEXT" ]] && skip=(! -samefile "$NEXT")
  pick=$(find "$WALLPAPER_DIR" -name .git -prune -o -type f "${skip[@]}" \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) -print0 \
    | shuf -z -n 1 | tr -d '\0')
  if [[ -z "$pick" ]]; then
    dunstify -a random-wallpaper "Wallpaper" "No images found in $WALLPAPER_DIR" -t 3000
    exit 1
  fi
  ln -f "$pick" "$NEXT" || { dunstify -a random-wallpaper "Wallpaper" "Can't hard-link into $NEXT" -t 3000; exit 1; }
}

[[ -e "$NEXT" ]] || queue_next

if ! awww query &>/dev/null; then
  awww-daemon &>/dev/null & disown
  for _ in {1..20}; do awww query 2>/dev/null | grep -q 'image:' && break; sleep 0.1; done
  # The daemon restores $NEXT itself, unless its cache predates this script or was cleared.
  awww query | grep -qF "image: $NEXT" || awww img "$NEXT" --transition-type none
else
  awww img "$NEXT" --transition-type grow --transition-pos 0.5,0.5 --transition-duration 1
fi

queue_next
