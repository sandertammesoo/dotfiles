#!/usr/bin/env zsh

if ! command -v harlequin &> /dev/null; then
    log_skip "harlequin not found, skipping harlequin DB helpers"
    return
fi

log_success "harlequin is installed, setting up Fractory DB helpers"

# Fractory API DB launchers. The full connection profile — host, port,
# database, user, password — lives in 1Password DATABASE items and is
# fetched at launch with a single `op item get` (Touch ID prompt), so
# nothing environment-specific is stored in this repo. The DB hosts
# resolve via Tailscale MagicDNS to private RDS addresses, so Tailscale
# must be up.
#
# The profile is appended to a 0600 temp copy of the tracked config and
# passed via --config-path — the password never appears on a command
# line, and an explicit config file merges LAST, outranking any
# .harlequin.toml in the cwd that could otherwise silently redirect the
# profile's host (and the password with it) to an attacker-controlled
# server.
# Environment is signalled visually: staging keeps tokyo-night, production
# uses monokai, whose red-pink secondary (#F92672) colors harlequin's
# selections and highlights. Themes are limited to Textual's built-ins, so
# this is the reddest available. Inside tmux, a production session also
# renames the window to "🔴 PROD DB" with a red status style while open;
# inside herdr, the tab and pane are renamed the same way (the tab's
# previous label is saved and restored — tab rename has no --clear).
_hq_fractory() {
    local env_name="$1" op_item="$2" theme="$3"
    shift 3
    local config_file="${XDG_CONFIG_HOME:-$HOME/.config}/harlequin/config.toml"

    local dep
    for dep in op jq; do
        if ! command -v "$dep" &> /dev/null; then
            log_error "${dep} not found — cannot fetch the ${env_name} DB profile from 1Password"
            return 1
        fi
    done
    if [[ ! -r "$config_file" ]]; then
        log_error "harlequin config not found at ${config_file}"
        return 1
    fi

    local item_json
    if ! item_json="$(op item get "$op_item" \
            --account fractorysolutionso.1password.com --format=json)"; then
        log_error "Failed to read '${op_item}' from 1Password"
        return 1
    fi

    local host port database db_user password
    host="$(jq -r '.fields[] | select(.id == "hostname").value // empty' <<< "$item_json")"
    port="$(jq -r '.fields[] | select(.id == "port").value // empty' <<< "$item_json")"
    database="$(jq -r '.fields[] | select(.id == "database").value // empty' <<< "$item_json")"
    db_user="$(jq -r '.fields[] | select(.id == "username").value // empty' <<< "$item_json")"
    password="$(jq -r '.fields[] | select(.id == "password").value // empty' <<< "$item_json")"

    if [[ -z "$host" || -z "$port" || -z "$database" || -z "$db_user" || -z "$password" ]]; then
        log_error "1Password item '${op_item}' is missing one of: hostname, port, database, username, password"
        return 1
    fi
    if [[ "$port" != <-> ]]; then
        log_error "1Password item '${op_item}' has a non-numeric port: ${port}"
        return 1
    fi
    # Values are written as TOML literal strings ('...'), which have no
    # escape mechanism — a single quote in them cannot be represented
    local value
    for value in "$host" "$database" "$db_user" "$password"; do
        if [[ "$value" == *"'"* ]]; then
            log_error "A 1Password field of '${op_item}' contains a single quote — cannot write it into the TOML profile"
            return 1
        fi
    done

    # No .toml suffix: BSD mktemp only substitutes trailing Xs, and
    # harlequin reads any non-pyproject filename as plain TOML anyway
    local tmp_config
    if ! tmp_config="$(mktemp "${TMPDIR:-/tmp}/harlequin-XXXXXX")"; then
        log_error "Failed to create a temporary harlequin config"
        return 1
    fi
    # Resolve through Tailscale MagicDNS explicitly and connect by IP.
    # The DB hostname is a CNAME into rds.amazonaws.com, which falls
    # OUTSIDE the tailnet's split-DNS zone — macOS getaddrinfo chases the
    # CNAME via the regular resolver and intermittently returns the
    # firewalled public IP (opaque ~60s Errno 60 timeouts). MagicDNS
    # recurses inside the VPC and reliably returns the private address.
    # If MagicDNS doesn't answer (Tailscale down), keep the hostname and
    # let the pre-flight below fail with a clear message.
    local resolved
    resolved="$(dig +short +time=2 +tries=1 @100.100.100.100 "$host" 2>/dev/null \
        | grep -E '^(10|172\.(1[6-9]|2[0-9]|3[01])|192\.168)\.' | head -1)"
    if [[ -n "$resolved" ]]; then
        host="$resolved"
    fi

    # Pre-flight: fail fast instead of a long connect timeout
    if ! nc -z -G 3 "$host" "$port" &> /dev/null; then
        log_error "Cannot reach ${host}:${port} within 3s — is Tailscale connected?"
        return 1
    fi

    local tmux_flagged=false
    local herdr_flagged=false herdr_prev_label=""
    if [[ "$env_name" == "production" ]]; then
        if [[ -n "$TMUX" ]]; then
            tmux rename-window "🔴 PROD DB"
            tmux set -w window-status-current-style 'fg=#1a1b26,bg=#f7768e,bold'
            tmux set -w window-status-style 'fg=#f7768e,bold'
            tmux_flagged=true
        fi
        if [[ -n "$HERDR_TAB_ID" ]] && command -v herdr &> /dev/null; then
            herdr_prev_label="$(herdr tab get "$HERDR_TAB_ID" 2>/dev/null \
                | jq -r '.result.tab.label // empty')"
            if herdr tab rename "$HERDR_TAB_ID" "🔴 PROD DB" &> /dev/null; then
                herdr_flagged=true
            fi
            if [[ -n "$HERDR_PANE_ID" ]]; then
                herdr pane rename "$HERDR_PANE_ID" "🔴 PROD DB" &> /dev/null
            fi
        fi
    fi

    {
        chmod 600 "$tmp_config"
        cat "$config_file" > "$tmp_config"
        cat >> "$tmp_config" <<EOF

[profiles.fractory-${env_name}]
adapter = "mysql"
host = '${host}'
port = ${port}
database = '${database}'
user = '${db_user}'
password = '${password}'
theme = "${theme}"
limit = 100
EOF

        harlequin --config-path "$tmp_config" --profile "fractory-${env_name}" "$@"
    } always {
        rm -f "$tmp_config"
        if [[ "$tmux_flagged" == "true" ]]; then
            tmux set -wu window-status-current-style
            tmux set -wu window-status-style
            tmux set -w automatic-rename on
        fi
        if [[ "$herdr_flagged" == "true" ]]; then
            if [[ -n "$herdr_prev_label" ]]; then
                herdr tab rename "$HERDR_TAB_ID" "$herdr_prev_label" &> /dev/null
            fi
            if [[ -n "$HERDR_PANE_ID" ]]; then
                # --clear must come after the pane id — before it, herdr's
                # CLI misparses it as the PANE_ID (despite its usage text)
                herdr pane rename "$HERDR_PANE_ID" --clear &> /dev/null
            fi
        fi
    }
}

hq-staging() {
    _hq_fractory staging "My API staging READ-ONLY" tokyo-night "$@"
}

hq-prod() {
    _hq_fractory production "My API prod READ-ONLY" monokai "$@"
}
