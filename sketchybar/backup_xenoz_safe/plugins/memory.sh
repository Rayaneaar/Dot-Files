#!/usr/bin/env bash
set -u

# Compute active + wired + compressed memory on macOS
RAM="$(vm_stat 2>/dev/null | perl -ne '/page size of (\d+)/ and $size=$1; /Pages active:\s+(\d+)/ and $active=$1; /Pages wired down:\s+(\d+)/ and $wired=$1; /Pages occupied by compressor:\s+(\d+)/ and $comp=$1; END { printf "%.1fG\n", ($active+$wired+$comp)*$size/(1024*1024*1024) }')"

if [ -z "$RAM" ]; then
    RAM="0.0G"
fi

sketchybar --set "$NAME" label="$RAM"
