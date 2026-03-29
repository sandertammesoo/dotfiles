#!/usr/bin/env zsh
if command -v starship &> /dev/null; then
    log_success "starship is installed, setting up starship shell integration"

    # Detect the current OS / distribution
    LFILE="/etc/*-release"
    MFILE="/System/Library/CoreServices/SystemVersion.plist"

    if [[ -f $LFILE ]]; then
        _distro=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')
    elif [[ -f $MFILE ]]; then
        _distro="macos"
    elif [[ -n "$WSL_DISTRO_NAME" ]]; then
        _distro="wsl-${WSL_DISTRO_NAME}"
    elif [[ "$(uname -s)" == "FreeBSD" ]] || [[ "$(uname -s)" == "OpenBSD" ]]; then
        _distro=$(uname -s | tr '[:upper:]' '[:lower:]')
    else
        log_warn "Unknown distribution, using default icon"
        _distro="unknown"
    fi

    # Map distro to icon using explicit Unicode codepoints (never embed raw glyphs).
    # Source: font-logos v1.3.0 — https://github.com/lukas-w/font-logos
    # To update: check the codepoint table in the font-logos README and revise
    # the $'\uXXXX' values below. CSS class names are noted for easy lookup.
    case $_distro in
        *alpine*)                ICON=$'\uf300';;  # fl-alpine
        *aosc*)                  ICON=$'\uf301';;  # fl-aosc
        *macos*)                 ICON=$'\uf302';;  # fl-apple
        *arch*)                  ICON=$'\uf303';;  # fl-archlinux
        *centos*)                ICON=$'\uf304';;  # fl-centos
        *coreos*)                ICON=$'\uf305';;  # fl-coreos
        *debian*)                ICON=$'\uf306';;  # fl-debian
        *devuan*)                ICON=$'\uf307';;  # fl-devuan
        *elementary*)            ICON=$'\uf309';;  # fl-elementary
        *fedora*)                ICON=$'\uf30a';;  # fl-fedora
        *freebsd*)               ICON=$'\uf30c';;  # fl-freebsd
        *gentoo*)                ICON=$'\uf30d';;  # fl-gentoo
        *linuxmint*)             ICON=$'\uf30e';;  # fl-linuxmint
        *mageia*)                ICON=$'\uf310';;  # fl-mageia
        *manjaro*)               ICON=$'\uf312';;  # fl-manjaro
        *nixos*)                 ICON=$'\uf313';;  # fl-nixos
        *opensuse*|*tumbleweed*) ICON=$'\uf314';;  # fl-opensuse
        *raspbian*)              ICON=$'\uf315';;  # fl-raspberry-pi
        *rhel*)                  ICON=$'\uf316';;  # fl-redhat
        *sabayon*)               ICON=$'\uf317';;  # fl-sabayon
        *slackware*)             ICON=$'\uf318';;  # fl-slackware
        *ubuntu*)                ICON=$'\uf31b';;  # fl-ubuntu
        *kali*)                  ICON=$'\uf327';;  # fl-kali-linux
        *openbsd*)               ICON=$'\uf328';;  # fl-openbsd
        *wsl*)                   ICON=$'\uf31a';;  # fl-tux  (no WSL-specific glyph)
        *unknown*|*)             ICON=$'\uf31a';;  # fl-tux  (generic fallback)
    esac

    export STARSHIP_DISTRO="$ICON"
    export STARSHIP_CONFIG=$ZDOTDIR/starship.toml
    
    if eval "$(starship init zsh)"; then
        log_success "starship init successful"
    else
        log_fatal "starship init failed"
    fi
else
    log_skip "starship not found, skipping starship shell integration"
fi