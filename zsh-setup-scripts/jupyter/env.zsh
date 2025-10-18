#!/usr/bin/env zsh

if command -v jupyter &> /dev/null; then
    log_success "Jupyter found, setting up environment"
    export_n_log JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter" # Set Jupyter config directory
    export_n_log JUPYTER_DATA_DIR="$XDG_DATA_HOME/jupyter" # Set Jupyter data directory
    export_n_log JUPYTER_RUNTIME_DIR="$XDG_STATE_HOME/jupyter/runtime" # Set Jupyter runtime directory
    [[ -d $JUPYTER_CONFIG_DIR/bin ]] && add_to PATH "$JUPYTER_CONFIG_DIR/bin" # Add Jupyter bin to PATH
    [[ -d $JUPYTER_DATA_DIR/bin ]] && add_to PATH "$JUPYTER_DATA_DIR/bin" # Add Jupyter data bin to PATH
    # Create runtime directory if it doesn't exist
    if [[ ! -d $JUPYTER_RUNTIME_DIR ]]; then
        mkdir -p "$JUPYTER_RUNTIME_DIR"
        log_success "Created Jupyter runtime directory at $JUPYTER_RUNTIME_DIR"
    fi
    [[ -d $JUPYTER_RUNTIME_DIR/bin ]] && add_to PATH "$JUPYTER_RUNTIME_DIR/bin" # Add Jupyter runtime bin to PATH
    log_success "Jupyter environment configured successfully"
else
    log_warn "Jupyter not found, skipping jupyter environment setup"
fi