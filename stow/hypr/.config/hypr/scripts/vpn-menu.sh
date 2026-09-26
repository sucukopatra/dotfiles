#!/bin/bash
# fuzzel menu to connect, switch or disconnect WireGuard tunnels from /etc/wireguard.
# Tunnels run as wg-quick@<name>.service. On first run it installs a polkit rule
# (one password prompt) so later switches never ask for a password.
set -uo pipefail

WG_DIR=/etc/wireguard
RULE=/etc/polkit-1/rules.d/50-vpn-menu.rules

# Only interface names, never paths: a path would let a user-owned config run
# PostUp commands as root. The regex is the one wg-quick uses for names, minus a
# leading "-" (systemd unescapes "-" to "/" if the unit ever switches to %I).
RULE_JS='// Installed by ~/.config/hypr/scripts/vpn-menu.sh
polkit.addRule(function (action, subject) {
    if (action.id == "org.freedesktop.systemd1.manage-units" &&
        subject.isInGroup("wheel") && subject.local && subject.active &&
        /^wg-quick@[a-zA-Z0-9_][a-zA-Z0-9_=+.-]{0,14}\.service$/.test(action.lookup("unit")) &&
        ["start", "stop", "restart"].indexOf(action.lookup("verb")) >= 0) {
        return polkit.Result.YES;
    }
});'

notify() { dunstify -a vpn-menu -r 51820 "VPN" "$1" -t "${2:-3000}"; }

# Makes config names listable; the .conf files themselves stay 0600.
# Both happen in one pkexec, so a readable $WG_DIR means setup is done.
setup() {
  pkexec /bin/bash -c 'printf "%s\n" "$3" > "$1" && chmod 644 "$1" && install -d -m 755 "$2"' \
    _ "$RULE" "$WG_DIR" "$RULE_JS"
}

tunnel_down() {
  local name="$1"
  if systemctl is-active --quiet "wg-quick@$name"; then
    systemctl stop "wg-quick@$name"
  else
    # Started by hand with wg-quick, not through systemd.
    pkexec /usr/bin/wg-quick down "$name"
  fi
}

if [[ ! -r "$WG_DIR" ]]; then
  setup || { notify "Setup cancelled, can't manage tunnels" 5000; exit 1; }
fi

mapfile -t configs < <(find "$WG_DIR" -maxdepth 1 -name '*.conf' -printf '%f\n' | sed 's/\.conf$//' | sort)
if (( ${#configs[@]} == 0 )); then
  notify "No configs in $WG_DIR" 5000
  exit 1
fi

active=""
for iface in $(ip -br link show type wireguard | awk '{print $1}'); do
  [[ " ${configs[*]} " == *" $iface "* ]] && { active="$iface"; break; }
done

entries=()
for c in "${configs[@]}"; do
  [[ "$c" == "$active" ]] && entries+=("●  $c  (connected)") || entries+=("   $c")
done
[[ -n "$active" ]] && entries+=("✕  Disconnect")

idx=$(printf '%s\n' "${entries[@]}" | fuzzel --dmenu --index --prompt "vpn › " --lines "${#entries[@]}") || exit 0
[[ "$idx" =~ ^[0-9]+$ ]] || exit 0

if (( idx == ${#configs[@]} )); then
  tunnel_down "$active" && notify "Disconnected from $active" || notify "Failed to disconnect $active" 5000
  exit
fi

choice="${configs[idx]}"
[[ "$choice" == "$active" ]] && exit 0

if [[ -n "$active" ]] && ! tunnel_down "$active"; then
  notify "Failed to disconnect $active" 5000
  exit 1
fi

if systemctl start "wg-quick@$choice"; then
  notify "Connected to $choice"
else
  notify "Failed to connect to $choice"$'\n'"journalctl -u wg-quick@$choice" 8000
  exit 1
fi
