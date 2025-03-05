#!/bin/zsh
src "$(basename "${(%):-%x}")"

# Always list directory contents upon 'cd'
function cd() {
	z "$@"; la; #autoenv_init;
	#builtin cd "$@"; la; #autoenv_init;
}

