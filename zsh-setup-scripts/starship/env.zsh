#!/usr/bin/env zsh

if command -v starship &> /dev/null; then
    log_success "starship is installed, setting up starship shell integration"
    # find out which distribution we are running on
    LFILE="/etc/*-release"
    MFILE="/System/Library/CoreServices/SystemVersion.plist"
    
    if [[ -f $LFILE ]]; then
        _distro=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')
    elif [[ -f $MFILE ]]; then
        _distro="macos"
    elif [[ -n "$WSL_DISTRO_NAME" ]]; then
        # WSL (Windows Subsystem for Linux)
        _distro="wsl-${WSL_DISTRO_NAME}"
    elif [[ "$(uname -s)" == "FreeBSD" ]] || [[ "$(uname -s)" == "OpenBSD" ]]; then
        # BSD systems
        _distro=$(uname -s | tr '[:upper:]' '[:lower:]')
    else
        log_warn "Unknown distribution, using default icon"
        _distro="unknown"
    fi

    # set an icon based on the distro
    # make sure your font is compatible with https://github.com/lukas-w/font-logos
    case $_distro in
        *kali*)                  ICON="ﴣ";;
        *arch*)                  ICON="";;
        *debian*)                ICON="";;
        *raspbian*)              ICON="";;
        *ubuntu*)                ICON="";;
        *elementary*)            ICON="";;
        *fedora*)                ICON="";;
        *coreos*)                ICON="";;
        *gentoo*)                ICON="";;
        *mageia*)                ICON="";;
        *centos*)                ICON="";;
        *opensuse*|*tumbleweed*) ICON="";;
        *sabayon*)               ICON="";;
        *slackware*)             ICON="";;
        *linuxmint*)             ICON="";;
        *alpine*)                ICON="";;
        *aosc*)                  ICON="";;
        *nixos*)                 ICON="";;
        *devuan*)                ICON="";;
        *manjaro*)               ICON="";;
        *rhel*)                  ICON="";;
        *macos*)                 ICON="";;
        *wsl*)                   ICON="";;  # WSL
        *freebsd*)               ICON="";;  # FreeBSD
        *openbsd*)               ICON="";;  # OpenBSD
        *unknown*)               ICON="";;  # Unknown/default
        *)                       ICON="";;
    esac

    export STARSHIP_DISTRO="$ICON"

    export STARSHIP_CONFIG=$ZDOTDIR/starship.toml
    # Load Starship
    if eval "$(starship init zsh)"; then
        log_success "starship init successful"
    else
        log_fatal "starship init failed"
    fi
else
    log_skip "starship not found, skipping starship shell integration"
fi
