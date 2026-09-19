#!/usr/bin/env bash
set -euo pipefail

# Install the profile for the current user. No sudo is required.
readonly BUNDLE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly PROFILE_NAME="Neo-Night.profile"
readonly SCHEME_NAME="Neo-Night.colorscheme"
readonly DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/konsole"
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly CONFIG_FILE="$CONFIG_DIR/konsolerc"
readonly STATE_DIR="$DATA_DIR/.neo-night"
readonly STATE_FILE="$STATE_DIR/default-profile.state"

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

read_default_profile() {
    local value
    if command -v kreadconfig6 >/dev/null 2>&1; then
        kreadconfig6 --file "$CONFIG_FILE" --group 'Desktop Entry' \
            --key DefaultProfile --default '__NEO_NIGHT_MISSING__'
        return
    fi
    if command -v kreadconfig5 >/dev/null 2>&1; then
        kreadconfig5 --file "$CONFIG_FILE" --group 'Desktop Entry' \
            --key DefaultProfile --default '__NEO_NIGHT_MISSING__'
        return
    fi
    if [[ -f "$CONFIG_FILE" ]]; then
        value="$(awk '
            /^\[Desktop Entry\]$/ { in_group=1; next }
            /^\[/ { in_group=0 }
            in_group && /^DefaultProfile=/ { sub(/^DefaultProfile=/, ""); print; exit }
        ' "$CONFIG_FILE")"
        if [[ -n "$value" ]]; then
            printf '%s\n' "$value"
        else
            printf '%s\n' '__NEO_NIGHT_MISSING__'
        fi
    else
        printf '%s\n' '__NEO_NIGHT_MISSING__'
    fi
}

rewrite_default_profile() {
    local action="$1"
    local value="${2:-}"
    local temp

    mkdir -p "$CONFIG_DIR"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        if [[ "$action" == set ]]; then
            printf '[Desktop Entry]\nDefaultProfile=%s\n' "$value" > "$CONFIG_FILE"
        fi
        return
    fi

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
        END {
            if (in_group) emit_key()
            if (action == "set" && !found_group) {
                print "[Desktop Entry]"
                print "DefaultProfile=" value
            }
        }
    ' "$CONFIG_FILE" > "$temp"
    mv -- "$temp" "$CONFIG_FILE"
}

set_default_profile() {
    if command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file "$CONFIG_FILE" --group 'Desktop Entry' \
            --key DefaultProfile "$PROFILE_NAME"
    elif command -v kwriteconfig5 >/dev/null 2>&1; then
        kwriteconfig5 --file "$CONFIG_FILE" --group 'Desktop Entry' \
            --key DefaultProfile "$PROFILE_NAME"
    else
        rewrite_default_profile set "$PROFILE_NAME"
    fi
}

mkdir -p "$DATA_DIR" "$STATE_DIR/original"
[[ -f "$BUNDLE_DIR/$PROFILE_NAME" ]] || die "missing $PROFILE_NAME"
[[ -f "$BUNDLE_DIR/$SCHEME_NAME" ]] || die "missing $SCHEME_NAME"

for name in "$PROFILE_NAME" "$SCHEME_NAME"; do
    destination="$DATA_DIR/$name"
    backup="$STATE_DIR/original/$name"
    marker="$STATE_DIR/created.$name"
    if [[ -e "$destination" ]]; then
        if [[ ! -e "$backup" ]]; then
            cp -p -- "$destination" "$backup"
        fi
    elif [[ ! -e "$marker" ]]; then
        : > "$marker"
    fi
    install -m 0644 "$BUNDLE_DIR/$name" "$destination"
done

if [[ ! -e "$STATE_FILE" ]]; then
    if [[ -f "$CONFIG_FILE" ]]; then
        printf 'value\n%s\n' "$(read_default_profile)" > "$STATE_FILE"
    else
        printf 'file-missing\n' > "$STATE_FILE"
    fi
fi
set_default_profile

printf 'Installed %s and %s to %s\n' "$PROFILE_NAME" "$SCHEME_NAME" "$DATA_DIR"
printf 'Default Profile: %s\n' "$PROFILE_NAME"
printf 'Previous state is tracked in %s for uninstall/restore.\n' "$STATE_DIR"
