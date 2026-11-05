#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == --help ]]; then
    printf '%s\n' 'Usage: spotify-fix' 'Save the PulseAudio fix and restart the Spotify Flatpak (no sudo).'
    exit 0
fi
if (( $# )); then
    printf 'Unknown argument. Use spotify-fix --help.\n' >&2
    exit 2
fi
command -v flatpak >/dev/null || { echo 'Flatpak is not available.' >&2; exit 1; }
flatpak info com.spotify.Client >/dev/null
pactl info >/dev/null || { echo 'Your session audio server is unavailable. Log into your desktop session and retry.' >&2; exit 1; }

# Use the app's own config directory, including 42 goinfre redirects.
flatpak run --command=sh com.spotify.Client -c '
set -eu
config_file="$XDG_CONFIG_HOME/spotify-flags.conf"
mkdir -p "$XDG_CONFIG_HOME"
if ! grep -qxF -- "--audio-api=pulseaudio" "$config_file" 2>/dev/null; then
    if [ -f "$config_file" ]; then
        cp -p "$config_file" "$config_file.backup-$(date +%Y%m%d-%H%M%S)"
    fi
    printf "\n%s\n" "--audio-api=pulseaudio" >> "$config_file"
fi
'

running_apps=$(flatpak ps --columns=application)
if grep -qxF com.spotify.Client <<< "$running_apps"; then
    flatpak kill com.spotify.Client
fi
log_dir="${XDG_CACHE_HOME:-$HOME/.cache}/spotify-fix"
mkdir -p "$log_dir"
# Keep the real process attached to nohup: the packaged launcher backgrounds it.
nohup flatpak run --command=sh com.spotify.Client -c '
exec env PULSE_PROP_application.icon_name=com.spotify.Client LD_PRELOAD=/app/lib/spotify-preload.so /app/extra/bin/spotify --audio-api=pulseaudio
' > "$log_dir/launch.log" 2>&1 < /dev/null &
printf 'PulseAudio fix saved. Spotify is starting; press Play.\nLaunch log: %s/launch.log\n' "$log_dir"
