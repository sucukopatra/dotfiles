#!/bin/sh
MAC="E8:EE:CC:E1:9A:CC"

if [ -z "$MAC" ]; then
    notify-send -u critical "Bluetooth" "No MAC address provided, please edit the script."
    exit 1
fi

NAME=$(bluetoothctl info "$MAC" | grep "Name" | cut -d' ' -f2-)

bluetoothctl power on >/dev/null

if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
    if bluetoothctl disconnect "$MAC"; then
        notify-send "Bluetooth" "$NAME disconnected"
    else
        notify-send "Bluetooth" "Failed to disconnect $NAME"
    fi
else
    if bluetoothctl connect "$MAC"; then
        notify-send "Bluetooth" "$NAME connected"
    else
        notify-send "Bluetooth" "Failed to connect $NAME"
    fi
fi
