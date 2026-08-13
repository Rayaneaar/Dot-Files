#!/usr/bin/env bash

FOCUSED="$FOCUSED_WORKSPACE"

# Get the index of the focused workspace
INDEX=0

for workspace in $(aerospace list-workspaces --all); do
    INDEX=$((INDEX + 1))

    if [ "$workspace" = "$FOCUSED" ]; then
        break
    fi
done

# Workspace spacing
STEP=45

# Calculate indicator position
OFFSET=$(((INDEX - 1) * STEP))

# Show and animate
sketchybar --animate tanh 18 \
    --set workspace_indicator \
    drawing=on \
    position=absolute \
    x_offset="$OFFSET"
