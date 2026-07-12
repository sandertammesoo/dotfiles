#!/usr/bin/env zsh

# Per-project todo lists for tuxedo, with directory-tree lookup.
#
# Once $TODO_DIR is set (see env.zsh), tuxedo ALWAYS edits that global list and
# ignores any ./todo.txt -- env vars outrank the cwd fallback in tuxedo's resolution
# order. This wrapper restores (and extends) per-project behaviour: it searches for a
# todo.txt starting in $PWD and walking up the parent directories as far as $HOME. The
# nearest one wins; if none is found, tuxedo falls back to the global $TODO_DIR list.
#
# The search never climbs above $HOME, and for a $PWD outside $HOME only $PWD itself is
# checked (so we don't scan system directories like /tmp -> / ).
#
# We inject $TODO_FILE (not a positional FILE arg) because the one-shot CLI subcommands
# (add/ls/do/pri/archive/...) don't accept a FILE argument -- only the TUI does. Setting
# the env var works uniformly for both modes.
#
# Escape hatch: run `command tuxedo ...` to bypass this wrapper and force the global list.
if command -v tuxedo &> /dev/null; then
    tuxedo() {
        local dir="$PWD" found=""
        while true; do
            if [[ -f "$dir/todo.txt" ]]; then
                found="$dir/todo.txt"
                break
            fi
            # Stop after checking $HOME; never climb above it or outside the home tree.
            if [[ "$dir" == "$HOME" || "$dir" != "$HOME"/* ]]; then
                break
            fi
            dir="${dir:h}"   # zsh: parent directory (dirname)
        done

        if [[ -n "$found" ]]; then
            TODO_FILE="$found" command tuxedo "$@"
        else
            command tuxedo "$@"
        fi
    }
fi
