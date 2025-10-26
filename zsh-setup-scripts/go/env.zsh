#!/usr/bin/env zsh

if command -v go &> /dev/null; then
    log_success "go is installed, setting up go environment"
    export_n_log GOPATH=$PROJECTS/go
    add_to PATH "$GOPATH/bin"
else
    log_skip "go not found, skipping go environment setup"
fi
