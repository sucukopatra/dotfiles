#!/bin/bash

DEVICE="E8:EE:CC:E1:9A:CC"

STATUS=$(bluetoothctl info "$DEVICE" | grep "Connected: yes")

if [ -n "$STATUS" ]; then
    bluetoothctl disconnect "$DEVICE"
else
    bluetoothctl power on
    bluetoothctl connect "$DEVICE"
fi
