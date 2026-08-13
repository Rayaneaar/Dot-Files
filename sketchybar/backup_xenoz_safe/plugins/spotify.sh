#!/usr/bin/env bash
set -u

# Query Spotify state via AppleScript
SPOTIFY_STATE="$(osascript -e '
if application "Spotify" is running then
    tell application "Spotify"
        if player state is playing then
            return (get name of current track) & " — " & (get artist of current track)
        end if
    end tell
end if
return ""
' 2>/dev/null)"

if [ -z "$SPOTIFY_STATE" ]; then
    sketchybar --set "$NAME" drawing=off
else
    # Truncate song title if longer than 28 characters
    MAX_LEN=28
    if [ ${#SPOTIFY_STATE} -gt $MAX_LEN ]; then
        LABEL="${SPOTIFY_STATE:0:$((MAX_LEN-3))}..."
    else
        LABEL="$SPOTIFY_STATE"
    fi
    sketchybar --set "$NAME" drawing=on icon="󰝚" label="$LABEL"
fi
