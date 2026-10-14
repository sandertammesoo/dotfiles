#!/usr/bin/env zsh

# Resolve the helpers next to this file, not through ~/.config/.dotfiles:
# on a new machine that link does not exist until run-dotbot creates it.
source "${${(%):-%x}:A:h}/helpers_logging.zsh"
source "${${(%):-%x}:A:h}/helpers_misc.zsh"
