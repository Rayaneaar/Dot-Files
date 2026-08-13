#!/usr/bin/env bash

THEME_DIR="$HOME/.config/sketchybar/theme"
CACHE="$THEME_DIR/current"

# Get the wallpaper used by the primary desktop
WALLPAPER=$(osascript -e 'tell application "System Events" to get picture of desktop 1' 2>/dev/null)

[ -f "$WALLPAPER" ] || exit 0

# Avoid recalculating colors when the wallpaper hasn't changed
WALLPAPER_HASH=$(shasum "$WALLPAPER" | awk '{print $1}')

if [ -f "$CACHE.wallpaper" ] && [ "$(cat "$CACHE.wallpaper")" = "$WALLPAPER_HASH" ]; then
    exit 0
fi

echo "$WALLPAPER_HASH" >"$CACHE.wallpaper"

# Extract dominant colors
PALETTE=$(magick "$WALLPAPER" \
    -resize 100x100 \
    -colors 8 \
    -format "%c" histogram:info:- 2>/dev/null)

# Pick the most common colors
COLORS=$(echo "$PALETTE" \
    grep -oE '#[0-9A-Fa-f]{6}' \
    head -8)

PRIMARY=$(echo "$COLORS" | sed -n '1p')
SECONDARY=$(echo "$COLORS" | sed -n '2p')
TERTIARY=$(echo "$COLORS" | sed -n '3p')

# Fallback
PRIMARY=${PRIMARY:-#cba6f7}
SECONDARY=${SECONDARY:-#89b4fa}
TERTIARY=${TERTIARY:-#f5c2e7}

# Convert #RRGGBB -> 0xAARRGGBB
hex_to_argb() {
    local HEX="${1#\#}"
    echo "0xff${HEX}"
}

PRIMARY_ARGB=$(hex_to_argb "$PRIMARY")
SECONDARY_ARGB=$(hex_to_argb "$SECONDARY")
TERTIARY_ARGB=$(hex_to_argb "$TERTIARY")

# Dark translucent bar background
sketchybar --bar \
    color="0x70000000"

# Dynamic workspace colors
sketchybar --set '/space\..*/' \
    icon.color="$PRIMARY_ARGB" \
    background.color="0x30000000"

# Focused workspace
sketchybar --set '/space\..*/' \
    icon.highlight_color="$PRIMARY_ARGB"

# General bar colors
sketchybar --default \
    icon.color="$SECONDARY_ARGB" \
    label.color="$TERTIARY_ARGB"

# JankyBorders
borders \
    active_color="$PRIMARY_ARGB" \
    inactive_color="0x55303030"

echo "$PRIMARY_ARGB" >"$CACHE.primary"
echo "$SECONDARY_ARGB" >"$CACHE.secondary"
echo "$TERTIARY_ARGB" >"$CACHE.tertiary"
