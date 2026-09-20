#!/usr/bin/env bash
set -euo pipefail

readonly BUNDLE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE_FILE="$BUNDLE_DIR/shell/neo-terminal-cleanup.bash"
readonly DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/konsole"
readonly TARGET_FILE="$DATA_DIR/neo-terminal-cleanup.bash"
readonly STATE_DIR="$DATA_DIR/.neo-session-cleanup"
readonly BACKUP_FILE="$STATE_DIR/neo-terminal-cleanup.bash.previous"
readonly CREATED_MARKER="$STATE_DIR/helper-created"
readonly BASHRC="${NEO_BASHRC:-$HOME/.bashrc}"
readonly START_MARKER='# >>> Neo Konsole terminal cleanup >>>'
readonly END_MARKER='# <<< Neo Konsole terminal cleanup <<<'

[[ -f "$SOURCE_FILE" ]] || {
    printf 'error: missing %s\n' "$SOURCE_FILE" >&2
    exit 1
}

mkdir -p "$DATA_DIR" "$STATE_DIR"
if [[ -e "$TARGET_FILE" && ! -e "$BACKUP_FILE" ]]; then
    cp -p -- "$TARGET_FILE" "$BACKUP_FILE"
elif [[ ! -e "$TARGET_FILE" && ! -e "$CREATED_MARKER" ]]; then
    : > "$CREATED_MARKER"
fi
install -m 0644 "$SOURCE_FILE" "$TARGET_FILE"

mkdir -p "$(dirname -- "$BASHRC")"
touch "$BASHRC"
if ! grep -Fqx "$START_MARKER" "$BASHRC"; then
    cat >> "$BASHRC" <<'EOF'

# >>> Neo Konsole terminal cleanup >>>
if [[ -r "${XDG_DATA_HOME:-$HOME/.local/share}/konsole/neo-terminal-cleanup.bash" ]]; then
    source "${XDG_DATA_HOME:-$HOME/.local/share}/konsole/neo-terminal-cleanup.bash"
fi
# <<< Neo Konsole terminal cleanup <<<
EOF
fi

printf 'Installed opt-in alternate-screen helpers for Bash.\n'
printf 'Use neo_screen <command> or neo_ssh <host> when isolation is needed.\n'
printf 'Run: source %q\n' "$BASHRC"
