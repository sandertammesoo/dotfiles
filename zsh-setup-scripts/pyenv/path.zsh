#!/bin/zsh

# # https://github.com/pyenv/pyenv/issues/950
# export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
# export CFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix readline)/include -I$(brew --prefix zlib)/include -I$(xcrun --show-sdk-path)/usr/include" 
# export LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix zlib)/lib"
# export CPPFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix readline)/include -I$(brew --prefix zlib)/include -I$(xcrun --show-sdk-path)/usr/include" 

if command -v pyenv >/dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/shims:$PATH"
    eval "$(pyenv init --path)"
    debug "Set PYENV_ROOT and added to PATH"
else
    warn "Could not find pyenv. pyenv is not installed?"
fi