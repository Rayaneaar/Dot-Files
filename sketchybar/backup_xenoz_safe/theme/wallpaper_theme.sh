#!/usr/bin/env bash
set -u

THEME_DIR="$HOME/.config/sketchybar/theme"
CACHE="$THEME_DIR/current"

# Get wallpaper
WALLPAPER=$(osascript -e 'tell application "System Events" to get picture of desktop 1' 2>/dev/null || echo "")

if [ -f "$WALLPAPER" ]; then
    WALLPAPER_HASH=$(shasum "$WALLPAPER" | awk '{print $1}')
    if [ -f "$CACHE.wallpaper" ] && [ "$(cat "$CACHE.wallpaper")" = "$WALLPAPER_HASH" ]; then
        exit 0
    fi
    echo "$WALLPAPER_HASH" >"$CACHE.wallpaper"

    # Extract colors if ImageMagick is available
    if command -v magick >/dev/null 2>&1; then
        PALETTE=$(magick "$WALLPAPER" -resize 100x100 -colors 8 -format "%c" histogram:info:- 2>/dev/null || true)
        COLORS=$(echo "$PALETTE" | grep -oE '#[0-9A-Fa-f]{6}' | head -8)
        PRIMARY=$(echo "$COLORS" | sed -n '1p')
        SECONDARY=$(echo "$COLORS" | sed -n '2p')
        TERTIARY=$(echo "$COLORS" | sed -n '3p')
    fi
fi

# Fallback Catppuccin / XENOZ palette
PRIMARY="${PRIMARY:-#cba6f7}"
SECONDARY="${SECONDARY:-#89b4fa}"
TERTIARY="${TERTIARY:-#cdd6f4}"

hex_to_argb() {
    local HEX="${1#\#}"
    echo "0xff${HEX}"
}

PRIMARY_ARGB=$(hex_to_argb "$PRIMARY")
SECONDARY_ARGB=$(hex_to_argb "$SECONDARY")
TERTIARY_ARGB=$(hex_to_argb "$TERTIARY")
PRIMARY_RAW="${PRIMARY#\#}"

# Preserve glass bar appearance
sketchybar --bar color="0x55000000" blur_radius=32

# Update workspace indicator dynamic glass color
sketchybar --set workspace_indicator \
    background.color="0x45${PRIMARY_RAW}" \
    background.border_color="0x65${PRIMARY_RAW}"

# Update accent icons
sketchybar --set apple_logo icon.color="$PRIMARY_ARGB" 2>/dev/null || true

# Update JankyBorders if installed
if command -v borders >/dev/null 2>&1; then
    borders active_color="$PRIMARY_ARGB" inactive_color="0x55303030" 2>/dev/null || true
fi

echo "$PRIMARY_ARGB" >"$CACHE.primary"
echo "$SECONDARY_ARGB" >"$CACHE.secondary"
echo "$TERTIARY_ARGB" >"$CACHE.tertiary"
