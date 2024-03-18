#!/bin/zsh

if command -v go >/dev/null; then
    export GOPATH=$PROJECTS/go
    export PATH="$GOPATH/bin:$PATH"
    debug "Set GOPATH and added to PATH"
else
    warn "Could not find go. go is not installed?"
fi