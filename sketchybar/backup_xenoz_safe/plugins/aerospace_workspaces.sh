#!/usr/bin/env bash
set -u

# Invoked on click or event
if [ "${1:-}" != "" ]; then
    aerospace workspace "$1"
else
    exec lua "$CONFIG_DIR/lua/workspace.lua"
fi
