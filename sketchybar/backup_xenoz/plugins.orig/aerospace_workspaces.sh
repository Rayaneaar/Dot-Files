#!/usr/bin/env bash

WORKSPACE="$1"

if [ "$WORKSPACE" = "$FOCUSED_WORKSPACE" ]; then

    sketchybar --set "$NAME" \
        icon.color=0xffffffff \
        icon.highlight=on

else

    sketchybar --set "$NAME" \
        icon.color=0xffa6adc8 \
        icon.highlight=off

fi
