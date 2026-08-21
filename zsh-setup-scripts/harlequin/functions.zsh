#!/usr/bin/env zsh

if ! command -v hq-sql &> /dev/null; then
    log_skip "hq-sql not found (dotbot links it to ~/.local/bin), skipping harlequin DB helpers"
    return
fi

log_success "hq-sql is installed, setting up Fractory DB helpers"

# Thin TUI wrappers over hq-sql (xdg_config/harlequin/scripts/hq-sql),
# which owns all connection machinery: 1Password fetch, MagicDNS
# resolution, reachability pre-flight, ephemeral 0600 profile, and the
# staging/production theming. These functions only add the interactive
# environment signal: inside tmux or herdr, a production session flags
# the window/tab/pane "🔴 PROD DB" while open and restores it after.
_hq_fractory() {
    local env_name="$1"
    shift

    local tmux_flagged=false
    local herdr_flagged=false herdr_prev_label=""
    if [[ "$env_name" == "production" ]]; then
        if [[ -n "$TMUX" ]]; then
            tmux rename-window "🔴 PROD DB"
            tmux set -w window-status-current-style 'fg=#1a1b26,bg=#f7768e,bold'
            tmux set -w window-status-style 'fg=#f7768e,bold'
            tmux_flagged=true
        fi
        if [[ -n "$HERDR_TAB_ID" ]] && command -v herdr &> /dev/null; then
            herdr_prev_label="$(herdr tab get "$HERDR_TAB_ID" 2>/dev/null \
                | jq -r '.result.tab.label // empty')"
            if herdr tab rename "$HERDR_TAB_ID" "🔴 PROD DB" &> /dev/null; then
                herdr_flagged=true
            fi
            if [[ -n "$HERDR_PANE_ID" ]]; then
                herdr pane rename "$HERDR_PANE_ID" "🔴 PROD DB" &> /dev/null
            fi
        fi
    fi

    {
        hq-sql --tui "$env_name" "$@"
    } always {
        if [[ "$tmux_flagged" == "true" ]]; then
            tmux set -wu window-status-current-style
            tmux set -wu window-status-style
            tmux set -w automatic-rename on
        fi
        if [[ "$herdr_flagged" == "true" ]]; then
            if [[ -n "$herdr_prev_label" ]]; then
                herdr tab rename "$HERDR_TAB_ID" "$herdr_prev_label" &> /dev/null
            fi
            if [[ -n "$HERDR_PANE_ID" ]]; then
                # --clear must come after the pane id — before it, herdr's
                # CLI misparses it as the PANE_ID (despite its usage text)
                herdr pane rename "$HERDR_PANE_ID" --clear &> /dev/null
            fi
        fi
    }
}

hq-staging() {
    _hq_fractory staging "$@"
}

hq-prod() {
    _hq_fractory production "$@"
}
