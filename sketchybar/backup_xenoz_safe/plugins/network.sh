#!/usr/bin/env bash
set -u

# Check Wi-Fi SSID
SSID="$(ipconfig getsummary en0 2>/dev/null | awk -F': ' '/ SSID : / {print $2}')"

if [ -n "$SSID" ]; then
    sketchybar --set "$NAME" icon="󰖩" icon.color="0xffa6e3a1" label="$SSID"
else
    # Check default network interface (e.g. Ethernet / USB)
    DEFAULT_IF="$(route -n get default 2>/dev/null | awk '/interface: / {print $2}')"
    if [ -n "$DEFAULT_IF" ]; then
        sketchybar --set "$NAME" icon="󰈀" icon.color="0xff89b4fa" label="Eth"
    else
        sketchybar --set "$NAME" icon="󰖪" icon.color="0xfff38ba8" label="Offline"
    fi
fi
