#!/usr/bin/env bash
set -u

VOLUME="${INFO:-}"
if [ -z "$VOLUME" ]; then
    VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo "0")"
fi

MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || echo "false")"

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
    ICON="󰖁"
    COLOR="0xfff38ba8"
elif [ "$VOLUME" -gt 60 ]; then
    ICON="󰕾"
    COLOR="0xffcba6f7"
elif [ "$VOLUME" -gt 30 ]; then
    ICON="󰖀"
    COLOR="0xffcba6f7"
else
    ICON="󰕿"
    COLOR="0xffcba6f7"
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${VOLUME}%"
