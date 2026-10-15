#!/usr/bin/env zsh
#
# Keeps $HOME tidy after ./run-dotbot: fixes the modes of the XDG
# directories, moves tool data from $HOME to the XDG path that .zshenv now
# points the tool at, and moves dead leftovers to a backup directory.
#
# Named setup.sh, not install.sh or *.zsh, so neither the find in
# install-all nor get_zsh_files picks it up. run-dotbot sources it.
#
# run-dotbot runs before .zshenv is linked on a new machine, so the paths
# below come from the XDG_* bases, not from CODEX_HOME and friends. Keep
# them in sync with xdg_config/zsh/.zshenv.
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

# _xdg_backup HOME NAME — move $HOME/NAME into this run's backup directory.
_xdg_backup() {
  : ${_XDG_BACKUP_DIR:=$XDG_STATE_HOME/dotfiles/home-leftovers/$(date +%Y%m%d-%H%M%S)}
  local dest="$_XDG_BACKUP_DIR/$2"
  mkdir -p "${dest:h}" || { log_error "Could not create ${dest:h}"; return 1; }
  mv "$1/$2" "$dest" || { log_error "Could not move $1/$2"; return 1; }
  log_warn "Moved $1/$2 to $dest"
}

# Move each item to its XDG path. If the XDG path already exists, the copy
# in $HOME is older or a stray, so it goes to the backup directory instead:
# this never merges two directories.
xdg_migrate_home_dirs() {
  local home="${XDG_TIDY_HOME:-$HOME}"
  local entry name dest moved=0 migrate_status=0
  # NAME in $HOME|new path. Each target is what .zshenv (or the vimrc, or
  # zsh-setup-scripts/gnupg/env.zsh) tells the tool to use.
  local -a migrations=(
    ".codex|$XDG_DATA_HOME/codex"
    ".copilot|$XDG_DATA_HOME/copilot"
    ".gemini|$XDG_DATA_HOME/gemini/.gemini"
    ".ansible|$XDG_DATA_HOME/ansible"
    ".shiv|$XDG_CACHE_HOME/shiv"
    ".jev|$XDG_STATE_HOME/jev"
    ".duckdb_history|$XDG_STATE_HOME/duckdb/history"
    ".viminfo|$XDG_STATE_HOME/vim/viminfo"
    ".vim/.netrwhist|$XDG_STATE_HOME/vim/.netrwhist"
    ".gnupg|$XDG_CONFIG_HOME/gnupg"
  )
  for entry in $migrations; do
    name="${entry%%|*}" dest="${entry#*|}"
    [[ -e "$home/$name" && ! -L "$home/$name" ]] || continue
    # dotbot creates some targets (gnupg) empty; an empty one is not a copy.
    [[ -d "$dest" && -z "$(ls -A "$dest")" ]] && rmdir "$dest"
    if [[ -e "$dest" ]]; then
      _xdg_backup "$home" "$name" || migrate_status=1
    elif mkdir -p "${dest:h}" && mv "$home/$name" "$dest"; then
      log_info "Moved $home/$name to $dest"
      (( moved++ ))
      [[ "$name" == ".codex" ]] && _xdg_fix_codex_hooks "$home/.codex" "$dest"
    else
      log_error "Could not move $home/$name to $dest"
      migrate_status=1
    fi
  done
  # .vim held only .netrwhist; the vim config is in $XDG_CONFIG_HOME/vim.
  [[ -d "$home/.vim" && ! -L "$home/.vim" ]] && rmdir "$home/.vim" 2>/dev/null
  (( moved )) && log_success "Moved $moved items from $home to their XDG paths"
  return $migrate_status
}

# herdr's Codex integration writes an absolute script path into hooks.json.
_xdg_fix_codex_hooks() {
  local old="$1" new="$2" hooks="$2/hooks.json"
  [[ -f "$hooks" ]] && grep -qF "$old/" "$hooks" || return 0
  sed -i '' "s|$old/|$new/|g" "$hooks" && log_info "Updated the script paths in $hooks"
}

# Dead leftovers. Each one is replaced by an XDG path or a setting:
#   .zsh_history   HISTFILE
#   .lesshst       LESSHISTFILE
#   .zsh_sessions  SHELL_SESSIONS_DISABLE (Terminal.app session restore)
#   .cargo         CARGO_HOME
#   .rustup        RUSTUP_HOME
#   .bundle        BUNDLE_USER_CACHE/CONFIG/PLUGIN
#   .matplotlib    MPLCONFIGDIR (only a font cache)
#   .zprofile, .profile, .tcshrc
#                  zsh reads $ZDOTDIR, so these are never read by your
#                  shell; installers (rustup, Docker Desktop) append to them
#   .atuin         [logs] dir in atuin/config.toml; only when it holds logs
#                  alone, because the atuin install script puts bin/ there
xdg_move_home_leftovers() {
  local home="${XDG_TIDY_HOME:-$HOME}"
  local -a found
  local name

  for name in .zsh_history .lesshst .zsh_sessions .cargo .rustup .bundle .matplotlib \
              .zprofile .profile .tcshrc; do
    [[ -e "$home/$name" && ! -L "$home/$name" ]] && found+=("$name")
  done
  if [[ -d "$home/.atuin" && ! -L "$home/.atuin" ]]; then
    local -a atuin_entries=("$home/.atuin"/*(DN:t))
    [[ "${atuin_entries[*]}" == "logs" || ${#atuin_entries} -eq 0 ]] && found+=(.atuin)
  fi

  (( ${#found} )) || { log_success "No leftovers in $home"; return 0; }

  for name in $found; do
    _xdg_backup "$home" "$name" || return 1
  done
  log_warn "Moved ${#found} leftovers to $_XDG_BACKUP_DIR. Delete that directory when you do not need them."
}

xdg_tidy_home() {
  local tidy_status=0
  unset _XDG_BACKUP_DIR
  xdg_fix_modes || tidy_status=1
  xdg_migrate_home_dirs || tidy_status=1
  xdg_move_home_leftovers || tidy_status=1
  return $tidy_status
}
