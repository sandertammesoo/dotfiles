#!/usr/bin/env zsh

if command -v cheat &> /dev/null; then
    log_success "cheat is installed, setting up cheat environment"
    export_n_log CHEAT_CONFIG_PATH="$XDG_CONFIG_HOME/.cheat/conf.yml"
    export_n_log CHEAT_USE_FZF=true
    export_n_log CHEAT_EDITOR="${EDITOR:-vim}"
    export_n_log CHEAT_COLORS=true
    export_n_log CHEAT_PATHS="$XDG_CONFIG_HOME/.cheat:$HOME/.cheat"
    add_to PATH "$XDG_CONFIG_HOME/.cheat/bin"
else
    log_skip "cheat not found, skipping cheat environment setup"
    return
fi

