#!/bin/zsh


# Always list directory contents upon 'cd'
function cd() {
	builtin cd "$@"; la; #autoenv_init;
}

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}

# Remove directory
function rmd() {
	rmdir "$@" && lsd;
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* *;
	fi;
}

# `v` with no arguments opens the current directory in Vim, otherwise opens the
# given location
function v() {
	if [ $# -eq 0 ]; then
		nvim;
	else
		nvim "$@";
	fi;
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
	if [ $# -eq 0 ]; then
		open .;
	else
		open "$@";
	fi;
}

# Colormap
function colormap() {
  for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

