#!/usr/bin/env zsh
##############################################################################
# Neovim Helper Functions (Currently Disabled)
#
# This file is reserved for custom neovim wrapper functions.
# The `v` function below is disabled because it depends on `nvim-my` which
# may not be available in all environments.
#
# TODO: Decide if we need a wrapper for nvim
# - If nvim-my is a custom script, document its location and purpose
# - If not needed, this file can be removed
##############################################################################

# Disabled: `v` function that opens neovim
# Uncomment and modify when nvim-my is available:
#
# function v() {
# 	if [ $# -eq 0 ]; then
# 		nvim-my
# 	else
# 		nvim-my "$@"
# 	fi
# }
