#!/usr/bin/env bash
set -u

# 24-Hour format as requested
TIME="$(date '+%H:%M')"
sketchybar --set "$NAME" label="$TIME"
