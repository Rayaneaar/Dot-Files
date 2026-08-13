#!/usr/bin/env bash
# ✦ XENOZ Theme Switcher Wrapper
# Delegates to the high-performance xenoz CLI engine while preserving bash compatibility.

XENOZ_BIN="$HOME/.config/xenoz/xenoz"

if [ -x "$XENOZ_BIN" ]; then
  exec "$XENOZ_BIN" "$@"
elif command -v xenoz >/dev/null 2>&1; then
  exec xenoz "$@"
else
  # Fallback to direct node execution
  exec node "$HOME/.config/xenoz/xenoz" "$@"
fi
