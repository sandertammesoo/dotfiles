#!/usr/bin/env zsh
#
# Keeps $HOME tidy after ./run-dotbot: fixes the modes of the XDG
# directories and moves files that tools wrote to $HOME before the XDG
# exports in .zshenv existed.
#
# Named setup.sh, not install.sh or *.zsh, so neither the find in
# install-all nor get_zsh_files picks it up. run-dotbot sources it.
#
# XDG_TIDY_HOME replaces $HOME so the specs can use a temp dir.

# dotbot 1.24's `create` calls chmod(path, 0o777) after makedirs, which
# skips the umask. Directories made before dotbot.conf.yaml set a mode are
# world-writable. Remove group and other write from each base directory
# and its direct children that this user owns.
xdg_fix_modes() {
  local -a bases=("$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME")
  local -a fixed
  local base dir
  for base in $bases; do
    [[ -d "$base" && ! -L "$base" ]] || continue
    fixed+=(${(f)"$(find "$base" -maxdepth 1 -type d -user "$USER" -perm +022 2>/dev/null)"})
  done
  (( ${#fixed} )) || { log_success "XDG directory modes are correct"; return 0; }
  for dir in $fixed; do
    chmod go-w "$dir" || { log_error "Could not chmod $dir"; return 1; }
    log_info "Removed group/other write: $dir"
  done
  log_success "Fixed the mode of ${#fixed} XDG directories"
}

# Leftovers in $HOME, each replaced by an XDG path in .zshenv or a config:
#   .zsh_history   HISTFILE
#   .lesshst       LESSHISTFILE
#   .zsh_sessions  SHELL_SESSIONS_DISABLE (Terminal.app session restore)
#   .cargo         CARGO_HOME
#   .rustup        RUSTUP_HOME
#   .atuin         [logs] dir in atuin/config.toml; only when it holds logs
#                  alone, because the atuin install script puts bin/ there
xdg_move_home_leftovers() {
  local home="${XDG_TIDY_HOME:-$HOME}"
  local dest="$XDG_STATE_HOME/dotfiles/home-leftovers/$(date +%Y%m%d-%H%M%S)"
  local -a found
  local name

  for name in .zsh_history .lesshst .zsh_sessions .cargo .rustup; do
    [[ -e "$home/$name" && ! -L "$home/$name" ]] && found+=("$name")
  done
  if [[ -d "$home/.atuin" && ! -L "$home/.atuin" ]]; then
    local -a atuin_entries=("$home/.atuin"/*(DN:t))
    [[ "${atuin_entries[*]}" == "logs" || ${#atuin_entries} -eq 0 ]] && found+=(.atuin)
  fi

  (( ${#found} )) || { log_success "No leftovers in $home"; return 0; }

  mkdir -p "$dest" || { log_error "Could not create $dest"; return 1; }
  for name in $found; do
    mv "$home/$name" "$dest/" || { log_error "Could not move $home/$name"; return 1; }
    log_info "Moved $home/$name"
  done
  log_warn "Moved ${#found} leftovers to $dest. Delete that directory when you do not need them."
}

xdg_tidy_home() {
  local tidy_status=0
  xdg_fix_modes || tidy_status=1
  xdg_move_home_leftovers || tidy_status=1
  return $tidy_status
}
