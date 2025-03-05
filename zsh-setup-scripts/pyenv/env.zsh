#!/bin/zsh
src "$(basename "${(%):-%x}")"

# # https://github.com/pyenv/pyenv/issues/950
# export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
# export CFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix readline)/include -I$(brew --prefix zlib)/include -I$(xcrun --show-sdk-path)/usr/include" 
# export LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix zlib)/lib"
# export CPPFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix readline)/include -I$(brew --prefix zlib)/include -I$(xcrun --show-sdk-path)/usr/include" 

if (( $+commands[pyenv] )); then
    export_n_log PYENV_ROOT="$XDG_CONFIG_HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && add_to PATH "$PYENV_ROOT/bin"
    eval "$(pyenv init - zsh)"
else
    warn " ! Could not find pyenv. Is it installed?"
fi
