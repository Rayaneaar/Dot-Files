#!/usr/bin/env bash
set -u

BATT_INFO="$(pmset -g batt 2>/dev/null)"
PERCENTAGE="$(echo "$BATT_INFO" | grep -Eo "\d+%" | head -n 1 | tr -d '%')"
CHARGING="$(echo "$BATT_INFO" | grep -i 'AC Power\|charging\|charged')"

if [ -z "$PERCENTAGE" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

sketchybar --set "$NAME" drawing=on

if [ -n "$CHARGING" ]; then
    ICON="󰂄"
    COLOR="0xffa6e3a1"
else
    if [ "$PERCENTAGE" -ge 80 ]; then
        ICON="󰁹"
        COLOR="0xffa6e3a1"
    elif [ "$PERCENTAGE" -ge 50 ]; then
        ICON="󰁾"
        COLOR="0xffa6e3a1"
    elif [ "$PERCENTAGE" -ge 20 ]; then
        ICON="󰁼"
        COLOR="0xfffab387"
    else
        ICON="󰁺"
        COLOR="0xfff38ba8"
    fi
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
