#!/usr/bin/env bash
set -euo pipefail

readonly PROFILE_NAME="Neo-Night.profile"
readonly SCHEME_NAME="Neo-Night.colorscheme"
readonly DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/konsole"
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly CONFIG_FILE="$CONFIG_DIR/konsolerc"
readonly STATE_DIR="$DATA_DIR/.neo-night"
readonly STATE_FILE="$STATE_DIR/default-profile.state"

rewrite_default_profile() {
    local action="$1"
    local value="${2:-}"
    local temp
    [[ -f "$CONFIG_FILE" ]] || return 0
    temp="$(mktemp "$CONFIG_FILE.XXXXXX")"
    awk -v action="$action" -v value="$value" '
        function emit_key() {
            if (action == "set" && !emitted) {
                print "DefaultProfile=" value
                emitted=1
            }
        }
        /^\[/ {
            if (in_group) emit_key()
            in_group=($0 == "[Desktop Entry]")
            if (in_group) found_group=1
            print
            next
        }
        {
            if (in_group && $0 ~ /^DefaultProfile=/) {
                if (action == "set") emit_key()
                next
            }
            print
        }
        END { if (in_group) emit_key() }
    ' "$CONFIG_FILE" > "$temp"
    mv -- "$temp" "$CONFIG_FILE"
}

set_default_profile() {
    local value="$1"
    if [[ "$value" == __NEO_NIGHT_MISSING__ ]] && command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file "$CONFIG_FILE" --group 'Desktop Entry' \
            --key DefaultProfile --delete
    elif [[ "$value" == __NEO_NIGHT_MISSING__ ]] && command -v kwriteconfig5 >/dev/null 2>&1; then
        kwriteconfig5 --file "$CONFIG_FILE" --group 'Desktop Entry' \
            --key DefaultProfile --delete
    elif command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file "$CONFIG_FILE" --group 'Desktop Entry' \
            --key DefaultProfile "$value"
    elif command -v kwriteconfig5 >/dev/null 2>&1; then
        kwriteconfig5 --file "$CONFIG_FILE" --group 'Desktop Entry' \
            --key DefaultProfile "$value"
    elif [[ "$value" == __NEO_NIGHT_MISSING__ ]]; then
        rewrite_default_profile unset
    else
        rewrite_default_profile set "$value"
    fi
}

restore_file() {
    local name="$1"
    local destination="$DATA_DIR/$name"
    local backup="$STATE_DIR/original/$name"
    local marker="$STATE_DIR/created.$name"
    if [[ -e "$backup" ]]; then
        install -m 0644 "$backup" "$destination"
        rm -f -- "$backup"
    elif [[ -e "$marker" ]]; then
        rm -f -- "$destination" "$marker"
    elif [[ -e "$destination" ]]; then
        printf 'Preserved %s: no install state was found.\n' "$destination"
    fi
}

if [[ ! -d "$STATE_DIR" ]]; then
    printf 'Neo-Night install state not found; nothing to uninstall.\n'
    exit 0
fi

if [[ -f "$STATE_FILE" ]]; then
    IFS= read -r state_type < "$STATE_FILE"
    if [[ "$state_type" == file-missing ]]; then
        set_default_profile __NEO_NIGHT_MISSING__
    elif [[ "$state_type" == value ]]; then
        previous="$(sed -n '2p' "$STATE_FILE")"
        set_default_profile "$previous"
    fi
fi

restore_file "$PROFILE_NAME"
restore_file "$SCHEME_NAME"
rm -f -- "$STATE_FILE"
rmdir --ignore-fail-on-non-empty "$STATE_DIR/original" "$STATE_DIR" 2>/dev/null || true

printf 'Uninstalled Neo-Night and restored the previous default Profile.\n'
