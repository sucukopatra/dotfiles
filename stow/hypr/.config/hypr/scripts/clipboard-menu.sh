#!/bin/bash
set -uo pipefail

pkill -x fuzzel && exit 0

mode=${1:-all}
dir="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist/thumbs"
mkdir -p "$dir"

declare -A entry
ids=()
while IFS=$'\t' read -r id rest; do
  entry[$id]=$rest
  ids+=("$id")
done < <(cliphist list)
(( ${#ids[@]} )) || exit 0

for f in "$dir"/*.png; do
  [ -e "$f" ] || continue
  id=${f##*/}; id=${id%.png}
  [ -n "${entry[$id]+x}" ] || rm -f "$f"
done

opts=(--placeholder="clipboard")
[ "$mode" = images ] && opts=(--hide-prompt --line-height=235 --lines=3 --width=36)

for id in "${ids[@]}"; do
  rest=${entry[$id]}
  if [[ $rest == '[[ binary data '*' png '* ]]; then
    f="$dir/$id.png"
    [ -s "$f" ] || cliphist decode "$id" > "$f"
    label=""
    [ "$mode" = images ] || { label="image ${rest##* png }"; label=${label% ]]}; }
    printf '%s\t%s\0icon\x1f%s\n' "$id" "$label" "$f"
  elif [ "$mode" = images ]; then
    continue
  elif [[ $rest == file://* ]]; then
    read -ra uris <<< "$rest"
    name=${uris[0]##*/}; name=$(printf '%b' "${name//%/\\x}")
    (( ${#uris[@]} > 1 )) && name+=" +$(( ${#uris[@]} - 1 ))"
    printf '%s\t%s\n' "$id" "$name"
  else
    printf '%s\t%s\n' "$id" "$rest"
  fi
done | fuzzel --dmenu --no-sort --with-nth=2 --match-nth=2 --accept-nth=1 "${opts[@]}" | {
  read -r id || exit 0
  type=()
  [[ ${entry[$id]} == file://* ]] && type=(--type text/uri-list)
  cliphist decode "$id" | wl-copy "${type[@]}"
}
