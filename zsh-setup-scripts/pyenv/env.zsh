#!/usr/bin/env zsh

# # https://github.com/pyenv/pyenv/issues/950
# export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
# export CFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix readline)/include -I$(brew --prefix zlib)/include -I$(xcrun --show-sdk-path)/usr/include" 
# export LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix zlib)/lib"
# export CPPFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix readline)/include -I$(brew --prefix zlib)/include -I$(xcrun --show-sdk-path)/usr/include" 

if command -v python3 &> /dev/null || command -v pyenv &> /dev/null; then
    log_success "Python found, setting up XDG-compliant environment"
    
    # Python XDG configuration
    export_n_log PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
    export_n_log PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
    export_n_log PYTHONUSERBASE="$XDG_DATA_HOME/python"
    export_n_log IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
    
    # PyEnv configuration if available
    if command -v pyenv &> /dev/null; then
        log_success "pyenv is installed, setting up pyenv environment"
        export_n_log PYENV_ROOT="$XDG_DATA_HOME/pyenv"
        [[ -d $PYENV_ROOT/bin ]] && add_to PATH "$PYENV_ROOT/bin"
        if eval "$(pyenv init - zsh)"; then
            log_success "pyenv init successful"
            export_n_log PYENV_VIRTUALENV_CACHE_PATH="$XDG_CACHE_HOME/pyenv/pyenv-virtualenv" # Set pyenv-virtualenv cache location
        else
            log_fatal "pyenv init failed"
        fi
    else
        log_warn "pyenv not found, skipping pyenv environment setup"
    fi
else
    log_info " !  Python not found, skipping Python environment setup"
fi