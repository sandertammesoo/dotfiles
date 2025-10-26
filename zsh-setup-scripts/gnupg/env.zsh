#!/usr/bin/env zsh

if command -v gpg &> /dev/null; then
    log_success "gpg is installed, setting up gpg environment"
    # Set GPG environment variables
    export_n_log GNUPGHOME="$XDG_CONFIG_HOME/gnupg" # Set GnuPG home directory
    # Ensure the directory exists with proper permissions
    if [[ ! -d "$GNUPGHOME" ]]; then
        mkdir -p "$GNUPGHOME"
        chmod 700 "$GNUPGHOME"
    fi
    [[ -d $GNUPGHOME/bin ]] && add_to PATH "$GNUPGHOME/bin" # Add GnuPG bin to PATH
    [[ -d $GNUPGHOME/libexec ]] && add_to PATH "$GNUPGHOME/libexec" # Add GnuPG libexec to PATH
    export_n_log GPG_AGENT_INFO="$GNUPGHOME/S.gpg-agent:0:1" # Set GPG agent info
    export_n_log GPG_TTY=$(tty) # Set GPG TTY
else
    log_skip "gpg not found, skipping gpg environment setup"
    return
fi

