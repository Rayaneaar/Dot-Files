#!/usr/bin/env bash
set -u

# Detect Wi-Fi device dynamically
WIFI_DEV=$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi/{getline; print $2}')
WIFI_DEV="${WIFI_DEV:-en0}"

# Query Wi-Fi SSID
SSID="$(ipconfig getsummary "$WIFI_DEV" 2>/dev/null | awk -F': ' '/ SSID : / {print $2}')"

if [ -n "$SSID" ]; then
    # Truncate SSID if too long
    if [ ${#SSID} -gt 16 ]; then
        SSID="${SSID:0:13}..."
    fi
    sketchybar --set "$NAME" icon="󰖩" icon.color="0xffa6e3a1" label="$SSID"
else
    # Check default network interface (e.g. Ethernet / USB LAN)
    DEFAULT_IF="$(route -n get default 2>/dev/null | awk '/interface: / {print $2}')"
    if [ -n "$DEFAULT_IF" ]; then
        sketchybar --set "$NAME" icon="󰈀" icon.color="0xff89b4fa" label="LAN"
    else
        sketchybar --set "$NAME" icon="󰖪" icon.color="0xfff38ba8" label="Offline"
    fi
fi
