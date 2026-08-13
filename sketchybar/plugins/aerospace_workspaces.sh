#!/usr/bin/env bash
set -u

# Safe workspace handler - updates UI state, never switches aerospace workspace from event handler
exec lua "$CONFIG_DIR/lua/workspace.lua"
