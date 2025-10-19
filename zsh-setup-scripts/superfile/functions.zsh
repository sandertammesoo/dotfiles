#!/usr/bin/env zsh

if ! command -v spf &> /dev/null; then
    log_info " !  superfile (spf) not found, skipping superfile shell integration"
    return
fi

log_success "superfile (spf) is installed, setting up superfile shell integration"

# Set up lastdir path based on OS (export once, not in function)
case "$(uname -s)" in
    Linux)
        export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
        ;;
    Darwin)
        export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
        ;;
    *)
        log_warn "Unknown OS for superfile integration, using default path"
        export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
        ;;
esac

# Wrap spf to save last directory
spf() {
    command spf "$@"

    [ ! -f "$SPF_LAST_DIR" ] || {
        . "$SPF_LAST_DIR"
        rm -f -- "$SPF_LAST_DIR" > /dev/null
    }
}
