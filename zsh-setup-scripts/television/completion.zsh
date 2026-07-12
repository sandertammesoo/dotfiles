#!/usr/bin/env zsh

# Register tv's completion function with compinit. env.zsh already defined _tv
# via `tv init zsh`, but its own compdef call runs before compinit exists —
# completion files are sourced after compinit, so registering here works.
if (( $+functions[_tv] )); then
    if compdef _tv tv 2>/dev/null; then
        log_success "television completion registered"
    else
        log_failure "Failed to register television completion"
    fi
else
    log_skip "television _tv function not defined, skipping completion registration"
fi
