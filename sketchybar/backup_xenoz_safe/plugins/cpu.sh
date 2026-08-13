#!/usr/bin/env bash
set -u

# Calculate CPU usage percentage
CPU_USAGE="$(top -l 1 -n 0 2>/dev/null | awk '/CPU usage/ {print $3}' | tr -d '%')"
CPU_INT="${CPU_USAGE%.*}"

if [ -z "$CPU_INT" ]; then
    CPU_INT="0"
fi

sketchybar --set "$NAME" label="${CPU_INT}%"
