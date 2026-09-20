#!/usr/bin/env bash
set -euo pipefail

readonly DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/konsole"
readonly TARGET_FILE="$DATA_DIR/neo-terminal-cleanup.bash"
readonly STATE_DIR="$DATA_DIR/.neo-session-cleanup"
readonly BACKUP_FILE="$STATE_DIR/neo-terminal-cleanup.bash.previous"
readonly CREATED_MARKER="$STATE_DIR/helper-created"
readonly BASHRC="${NEO_BASHRC:-$HOME/.bashrc}"
readonly START_MARKER='# >>> Neo Konsole terminal cleanup >>>'
readonly END_MARKER='# <<< Neo Konsole terminal cleanup <<<'

if [[ -f "$BASHRC" ]]; then
    temp="$(mktemp "$BASHRC.XXXXXX")"
    awk -v start="$START_MARKER" -v end="$END_MARKER" '
        $0 == start { skipping=1; next }
        $0 == end { skipping=0; next }
        !skipping { print }
    ' "$BASHRC" > "$temp"
    mv -- "$temp" "$BASHRC"
fi

if [[ -e "$BACKUP_FILE" ]]; then
    install -m 0644 "$BACKUP_FILE" "$TARGET_FILE"
    rm -f -- "$BACKUP_FILE"
elif [[ -e "$CREATED_MARKER" ]]; then
    rm -f -- "$TARGET_FILE" "$CREATED_MARKER"
fi

rmdir --ignore-fail-on-non-empty "$STATE_DIR" 2>/dev/null || true
printf 'Uninstalled opt-in alternate-screen helpers from Bash.\n'
printf 'Open a new shell, or unset the loaded functions with:\n'
printf '  unset -f neo_screen neo_ssh __neo_screen_in_alternate_screen\n'
