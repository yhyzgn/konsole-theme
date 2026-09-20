# Opt-in alternate-screen isolation without changing normal shell behavior.
# shellcheck shell=bash

__neo_terminal_remove_legacy_prompt_hook() {
    local hook

    if ! declare -p PROMPT_COMMAND >/dev/null 2>&1; then
        return
    fi

    if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" == 'declare -a '* ]]; then
        local -a retained_hooks=()
        for hook in "${PROMPT_COMMAND[@]}"; do
            if [[ "$hook" != __neo_terminal_restore_prompt_state ]]; then
                retained_hooks+=("$hook")
            fi
        done
        PROMPT_COMMAND=("${retained_hooks[@]}")
        return
    fi

    PROMPT_COMMAND="${PROMPT_COMMAND//__neo_terminal_restore_prompt_state; /}"
    PROMPT_COMMAND="${PROMPT_COMMAND//; __neo_terminal_restore_prompt_state/}"
    PROMPT_COMMAND="${PROMPT_COMMAND//__neo_terminal_restore_prompt_state/}"
}

__neo_screen_in_alternate_screen() (
    local enter_screen
    local leave_screen

    if (( $# == 0 )); then
        printf 'usage: neo_screen command [argument ...]\n' >&2
        return 2
    fi

    if [[ ! -t 0 || ! -t 1 || "${TERM:-dumb}" == dumb ]]; then
        command "$@"
        return
    fi

    if ! enter_screen="$(tput smcup 2>/dev/null)" || [[ -z "$enter_screen" ]]; then
        command "$@"
        return
    fi
    if ! leave_screen="$(tput rmcup 2>/dev/null)" || [[ -z "$leave_screen" ]]; then
        command "$@"
        return
    fi

    trap 'printf "%s" "$leave_screen"; tput cnorm 2>/dev/null || true' EXIT
    printf '%s' "$enter_screen"
    command "$@"
)

# Run only the explicitly supplied command in Konsole's alternate screen.
neo_screen() {
    __neo_screen_in_alternate_screen "$@"
}

# Convenience wrapper for remote full-screen menus that leave stale content.
neo_ssh() {
    neo_screen ssh "$@"
}

__neo_terminal_remove_legacy_prompt_hook

# Remove the previous release's automatic SSH wrapper when this file is
# re-sourced in an already-running shell. Do not touch unrelated user wrappers.
if declare -F ssh >/dev/null \
    && [[ "$(declare -f ssh)" == *'__neo_ssh_in_alternate_screen'* ]]; then
    unset -f ssh
fi

unset -f __neo_terminal_remove_legacy_prompt_hook
unset -f __neo_terminal_restore_prompt_state
unset -f __neo_terminal_install_prompt_hook
unset -f __neo_ssh_has_remote_command
unset -f __neo_ssh_in_alternate_screen
