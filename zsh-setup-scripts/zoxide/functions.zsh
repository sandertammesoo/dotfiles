#!/usr/bin/env zsh

function cd() {
	# Check if zoxide is available and z function is defined
	if command -v zoxide &>/dev/null && type z &>/dev/null 2>&1; then
		z "$@"
	else
		builtin cd "$@"
	fi
}