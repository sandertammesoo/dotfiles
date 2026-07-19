#!/usr/bin/env zsh

# Python runtime versions are managed by mise (see xdg_config/mise/config.toml);
# this module only sets the XDG-compliant Python environment.

if command -v python3 &> /dev/null; then
    log_success "Python found, setting up XDG-compliant environment"

    export_n_log PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
    export_n_log PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
    export_n_log PYTHONUSERBASE="$XDG_DATA_HOME/python"
    export_n_log IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
else
    log_skip "Python not found, skipping Python environment setup"
fi
