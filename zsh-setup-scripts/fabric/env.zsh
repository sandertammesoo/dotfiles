#!/usr/bin/env zsh

if command -v fabric-ai &> /dev/null; then
    log_success "fabric-ai is installed, setting up fabric-ai environment"

    # Check if Golang is installed
    if command -v go &> /dev/null; then
        # Check if GOROOT is already set
        if [[ -z "$GOROOT" ]]; then
            # Determine if Go was installed via Homebrew
            if command -v brew &> /dev/null && [[ -d "$(brew --prefix go)/libexec" ]]; then
                export_n_log GOROOT=$(brew --prefix go)/libexec
            else
                export_n_log GOROOT=$(go env GOROOT)
            fi
            log_success "Set GOROOT for fabric-ai to $GOROOT"
        fi
        # Check if GOPATH is already set
        if [[ -z "$GOPATH" ]]; then
            export_n_log GOPATH=$PROJECTS/go
            log_success "Set GOPATH for fabric-ai to $GOPATH"
            # Set GOBIN if not already set
            if [[ -z "$GOBIN" ]]; then
                export_n_log GOBIN="$GOPATH/bin"
                log_success "Set GOBIN for fabric-ai to $GOBIN"
                add_to PATH "$GOBIN"
            fi
        fi
    else
        log_warn "go not found, skipping fabric-ai GOPATH setup"
    fi 
else
    log_warn "fabric-ai not found, skipping fabric-ai environment setup"
fi
