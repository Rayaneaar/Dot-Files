#!/usr/bin/env bash
set -u

THEME_DIR="$HOME/.config/sketchybar/theme"
CACHE="$THEME_DIR/current"

mkdir -p "$THEME_DIR"

PRIMARY=""
SECONDARY=""
TERTIARY=""

# Get current desktop wallpaper safely via System Events or Finder
WALLPAPER="$(osascript -e 'tell application "System Events" to get picture of first desktop' 2>/dev/null || osascript -e 'tell application "Finder" to get POSIX path of (desktop picture as alias)' 2>/dev/null || echo "")"

if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
    WALLPAPER_HASH=$(shasum "$WALLPAPER" 2>/dev/null | awk '{print $1}')
    if [ -f "$CACHE.wallpaper" ] && [ "$(cat "$CACHE.wallpaper" 2>/dev/null)" = "$WALLPAPER_HASH" ]; then
        # Already up to date
        exit 0
    fi
    echo "$WALLPAPER_HASH" >"$CACHE.wallpaper"

    # Extract colors if ImageMagick is available, else use XENOZ theme palette
    if command -v magick >/dev/null 2>&1; then
        PALETTE=$(magick "$WALLPAPER" -resize 100x100 -colors 8 -format "%c" histogram:info:- 2>/dev/null || true)
        COLORS=$(echo "$PALETTE" | grep -oE '#[0-9A-Fa-f]{6}' | head -8 || true)
        PRIMARY=$(echo "$COLORS" | sed -n '1p')
        SECONDARY=$(echo "$COLORS" | sed -n '2p')
        TERTIARY=$(echo "$COLORS" | sed -n '3p')
    elif [ -f "$HOME/.config/xenoz/current/colors.lua" ]; then
        PRIMARY=$(grep 'accent =' "$HOME/.config/xenoz/current/colors.lua" | head -1 | grep -oE '#[0-9A-Fa-f]{6}' || true)
        SECONDARY=$(grep 'accent_secondary =' "$HOME/.config/xenoz/current/colors.lua" | head -1 | grep -oE '#[0-9A-Fa-f]{6}' || true)
        TERTIARY=$(grep 'foreground =' "$HOME/.config/xenoz/current/colors.lua" | head -1 | grep -oE '#[0-9A-Fa-f]{6}' || true)
    fi
fi

# Fallback Catppuccin / XENOZ purple palette if empty or invalid
if [[ ! "$PRIMARY" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
    PRIMARY="#cba6f7"
fi
if [[ ! "$SECONDARY" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
    SECONDARY="#89b4fa"
fi
if [[ ! "$TERTIARY" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
    TERTIARY="#cdd6f4"
fi

hex_to_argb() {
    local HEX="${1#\#}"
    echo "0xff${HEX}"
}

PRIMARY_ARGB=$(hex_to_argb "$PRIMARY")
SECONDARY_ARGB=$(hex_to_argb "$SECONDARY")
TERTIARY_ARGB=$(hex_to_argb "$TERTIARY")
PRIMARY_RAW="${PRIMARY#\#}"

# Preserve Caelestia floating glass bar appearance
sketchybar --bar color="0x4011111b" border_color="0x35${PRIMARY_RAW}" blur_radius=35 2>/dev/null || true

# Update workspace indicator dynamic glass capsule color
sketchybar --set workspace_indicator \
    background.color="0x45${PRIMARY_RAW}" \
    background.border_color="0x80${PRIMARY_RAW}" 2>/dev/null || true

# Update island brackets accent borders
sketchybar --set left_island background.border_color="0x30${PRIMARY_RAW}" 2>/dev/null || true
sketchybar --set center_island background.border_color="0x30${PRIMARY_RAW}" 2>/dev/null || true

# Update accent icons
sketchybar --set apple_logo icon.color="$PRIMARY_ARGB" 2>/dev/null || true

# Update JankyBorders only if daemon is already running
if pgrep -x borders >/dev/null 2>&1; then
    borders active_color="$PRIMARY_ARGB" inactive_color="0x55303030" 2>/dev/null || true
fi

echo "$PRIMARY_ARGB" >"$CACHE.primary"
echo "$SECONDARY_ARGB" >"$CACHE.secondary"
echo "$TERTIARY_ARGB" >"$CACHE.tertiary"
