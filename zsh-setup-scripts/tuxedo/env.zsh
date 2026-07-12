#!/usr/bin/env zsh

if command -v tuxedo &> /dev/null; then
    log_success "tuxedo is installed, setting up shell integration"

    # tuxedo resolves its todo file in this order (TUI *and* CLI use the same order):
    #   1. explicit FILE arg (TUI only)
    #   2. $TODO_FILE
    #   3. $TODO_DIR/todo.txt
    #   4. ./todo.txt in cwd        <- only reached if neither env var is set
    #   5. first-run create/sample prompt
    # Setting TODO_DIR pins ONE global list, so `tuxedo` and `tuxedo add ...` hit the
    # same file from any directory. The trade-off: a cwd ./todo.txt is then ignored
    # (env vars outrank step 4). functions.zsh restores per-project lists. See README.md.
    export_n_log TODO_DIR="$XDG_DATA_HOME/tuxedo"   # -> $TODO_DIR/todo.txt (+ sibling done.txt)

    # done.txt is auto-created as a sibling of todo.txt; override only to split it out:
    # export_n_log DONE_FILE="$TODO_DIR/done.txt"

    # Create the data dir up front so first run doesn't drop into the create/sample prompt.
    if [[ ! -d "$TODO_DIR" ]]; then
        mkdir -p "$TODO_DIR"
        log_success "Created tuxedo todo directory at $TODO_DIR"
    fi

    # Uncomment to skip tuxedo's network version check on shell startup:
    # export_n_log TUXEDO_NO_UPDATE_CHECK=1
else
    log_skip "tuxedo not found, skipping tuxedo shell integration"
    return
fi
