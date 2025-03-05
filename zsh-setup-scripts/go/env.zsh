#!/bin/zsh
src "$(basename "${(%):-%x}")"

if (( $+commands[go] )); then
    export_n_log GOPATH=$PROJECTS/go
    add_to PATH "$GOPATH/bin"
else
    warn " ! Could not find go. go is not installed?"
fi
