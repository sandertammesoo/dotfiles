#!/usr/bin/env zsh

# Keybinding landscape (resolved 2026-07-12, see git log for the investigation):
#   tv init zsh binds ^T (smart autocomplete) and ^R (shell history) — both
#   configurable under [shell_integration.keybindings] in television/config.toml,
#   but a history binding cannot be disabled, only remapped to another ctrl-* key.
#
#   ^T: fzf/env.zsh binds it first (fzf-file-widget); we load after fzf
#       (env files source alphabetically) so tv takes ^T on purpose. tv's smart
#       autocomplete is channel-aware (git checkout -> git-branch, claude --resume
#       -> claude-sessions, ...) and falls back to path completion, superseding
#       fzf's plain file picker. fzf keeps alt-c (cd) and **<tab> completion.
#   ^R: tv grabs it here, but atuin is sourced later in .zshrc (after the env
#       block, see the starship->atuin ordering note there) and reclaims ^R.
#       Final owner: atuin. Do not "fix" this by moving atuin earlier.
#   ^G: navi. No conflict with tv.
#
# The init script ends with `compdef _tv tv`, which fails silently here because
# compinit only runs later in .zshrc — completion.zsh in this module registers
# it after compinit instead.
if command -v tv &> /dev/null; then
    log_success "television is installed, setting up shell integration"
    if eval "$(tv init zsh)" 2>/dev/null; then
        log_success "television shell integration configured successfully"
    else
        log_failure "Failed to initialize television shell integration"
    fi
else
    log_skip "television not found, skipping television shell integration"
fi
