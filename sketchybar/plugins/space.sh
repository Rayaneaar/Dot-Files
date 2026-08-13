#!/usr/bin/env bash
set -u

# Workspace Item Controller — Clean text hover & scroll (No expanding boxes)
SID="${1:-${NAME#space.}}"
CACHE_FILE="/tmp/sketchybar_aerospace_prev_workspace"
ACTIVE_WS=""

if [ -f "$CACHE_FILE" ]; then
    ACTIVE_WS="$(cat "$CACHE_FILE" 2>/dev/null || echo "")"
fi

if [ -z "$ACTIVE_WS" ]; then
    ACTIVE_WS="$(aerospace list-workspaces --focused 2>/dev/null || echo "1")"
fi

case "${SENDER:-}" in
    "mouse.entered")
        # Simply brighten the text on hover — no expanding background box
        if [ "$SID" != "$ACTIVE_WS" ]; then
            sketchybar --set "$NAME" icon.color=0xffffffff
        fi
        ;;

    "mouse.exited"|"mouse.exited.global")
        # Restore muted text on exit
        if [ "$SID" != "$ACTIVE_WS" ]; then
            sketchybar --set "$NAME" icon.color=0xff6c7086
        fi
        ;;

    "mouse.scrolled"|"mouse.scrolled.global")
        DELTA="${SCROLL_DELTA:-0}"
        if [ "$DELTA" -gt 0 ]; then
            aerospace workspace --wrap-around --no-stdin next 2>/dev/null || true
        elif [ "$DELTA" -lt 0 ]; then
            aerospace workspace --wrap-around --no-stdin prev 2>/dev/null || true
        fi
        ;;

    *)
        if [ "${1:-}" != "" ]; then
            aerospace workspace "$1" 2>/dev/null || true
        fi
        ;;
esac
