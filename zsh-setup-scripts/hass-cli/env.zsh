#!/usr/bin/env zsh

if command -v hass-cli &> /dev/null; then
    log_success "hass-cli is installed, setting up hass-cli environment"
    # export_n_log HASS_SERVER=http://192.168.1.121:8123
    export_n_log HASS_SERVER=https://majakratt.duckdns.org
    export_n_log HASS_TOKEN="$LOCALRC_HASS_TOKEN"
else
    log_skip "hass-cli not found, skipping hass-cli environment setup"
fi
