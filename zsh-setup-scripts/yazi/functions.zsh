#!/usr/bin/env zsh
#
# The `y` wrapper from yazi's quick-start: yazi writes its final directory to a
# temp file on exit and the wrapper cds there, so browsing to a directory and
# quitting leaves the shell in it. Plain `yazi` still exits where it started.
#
# Only for standalone use. Inside a herdr pane the ray.file-explorer plugin
# (prefix+y) opens yazi in its own split, where a cd would have nothing to
# affect.

if ! command -v yazi &> /dev/null; then
    log_skip "yazi not found, skipping yazi shell integration"
    return
fi

log_success "yazi is installed, setting up the y wrapper"

y() {
    local tmp cwd
    tmp="$(mktemp -t 'yazi-cwd.XXXXXX')"
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
}
