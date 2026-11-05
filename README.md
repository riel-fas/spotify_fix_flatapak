# Spotify Flatpak audio fix

Spotify shows a song playing but you hear nothing? On some Linux sessions, forcing Spotify to use **PulseAudio** fixes this. This script applies that fix without sudo, including on 42 school sessions.

## Requirements

- Linux with Bash, Flatpak, and `pactl` available.
- Spotify installed as the Flatpak app `com.spotify.Client`.
- Run from your logged-in desktop session with a working PulseAudio-compatible audio server.

## Run

```bash
git clone https://github.com/riel-fas/spotify_fix_flatapak.git
cd spotify_fix_flatapak
bash spotify-fix.sh
```

Spotify will close and reopen. Press **Play**.

The script saves `--audio-api=pulseaudio` in Spotify's `spotify-flags.conf`, so the fix also applies when you open Spotify normally. It preserves existing settings and backs up an existing flags file before changing it. It does not change system audio settings or need administrator permissions.

This targets Spotify's audio backend issue; it does not fix every possible cause of missing sound.

## Optional: install a shortcut

```bash
mkdir -p "$HOME/.local/bin"
install -m 755 spotify-fix.sh "$HOME/.local/bin/spotify-fix"
```

Ensure this line is in `~/.zshrc` (Zsh) or `~/.bashrc` (Bash):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Open a new terminal, then run `spotify-fix` whenever needed. For the alternative command `spotify problem`, add this function to the same shell configuration:

```bash
spotify() {
    if [ "${1:-}" = problem ]; then
        "$HOME/.local/bin/spotify-fix"
    else
        flatpak run com.spotify.Client "$@"
    fi
}
```

## Troubleshooting and undo

If Spotify does not open, check `~/.cache/spotify-fix/launch.log` (or `$XDG_CACHE_HOME/spotify-fix/launch.log` if configured).

To undo the audio setting, remove the `--audio-api=pulseaudio` line from `~/.var/app/com.spotify.Client/config/spotify-flags.conf` and restart Spotify. On sessions with redirected app storage, that path may be a symlink to the actual configuration directory.
