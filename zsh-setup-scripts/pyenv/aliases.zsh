#!/usr/bin/env zsh

if command -v pyenv &> /dev/null; then
    log_success "pyenv is installed, setting up aliases"
    alias py='pyenv'
    alias py-activate='pyenv activate'
    alias py-deactivate='pyenv deactivate'
    alias py-global='pyenv global'
    alias py-local='pyenv local'
    alias py-shell='pyenv shell'
    alias py-versions='pyenv versions'
    alias py-install='pyenv install'
    alias py-uninstall='pyenv uninstall'
    alias py-rehash='pyenv rehash'
    alias py-which='pyenv which'
    alias py-shims='pyenv shims'
    # alias pip=pip3
    # alias python=python3
else
    log_skip "pyenv not found, skipping pyenv aliases"
    return
fi
