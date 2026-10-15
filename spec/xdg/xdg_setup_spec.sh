# shellcheck shell=zsh
# ShellSpec tests for the $HOME tidy step (zsh-setup-scripts/xdg/setup.sh).
#
# Each test uses a temp home and temp XDG directories, so nothing outside
# TEST_DIR changes.

Describe 'XDG home tidy (xdg/setup.sh)'
  setup() {
    REPO_ROOT="$PWD"
    TEST_DIR="$(mktemp -d)"

    export LOG_LEVEL="ERROR" LOG_ENABLED=true LOG_COLOR=never
    source "${REPO_ROOT}/helpers_logging.zsh"
    source "${REPO_ROOT}/helpers_misc.zsh"

    export XDG_TIDY_HOME="${TEST_DIR}/home"
    export XDG_CONFIG_HOME="${TEST_DIR}/home/.config"
    export XDG_DATA_HOME="${TEST_DIR}/home/.local/share"
    export XDG_CACHE_HOME="${TEST_DIR}/home/.cache"
    export XDG_STATE_HOME="${TEST_DIR}/home/.local/state"
    mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME"
    source "${REPO_ROOT}/zsh-setup-scripts/xdg/setup.sh"
  }

  cleanup() {
    rm -rf "$TEST_DIR"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  mode_of() { stat -f '%Lp' "$1"; }
  backup_dir() { print -r -- "$XDG_STATE_HOME"/dotfiles/home-leftovers/*(N[1]); }

  Describe 'xdg_fix_modes'
    It 'removes group and other write from base dirs and their children'
      mkdir -p "$XDG_CONFIG_HOME/npm" "$XDG_STATE_HOME/less"
      chmod 777 "$XDG_CONFIG_HOME" "$XDG_CONFIG_HOME/npm" "$XDG_STATE_HOME/less"
      When call xdg_fix_modes
      The status should be success
      The value "$(mode_of $XDG_CONFIG_HOME)" should equal "755"
      The value "$(mode_of $XDG_CONFIG_HOME/npm)" should equal "755"
      The value "$(mode_of $XDG_STATE_HOME/less)" should equal "755"
    End

    It 'keeps a stricter mode as it is'
      mkdir -p "$XDG_DATA_HOME/gnupg"
      chmod 700 "$XDG_DATA_HOME/gnupg"
      When call xdg_fix_modes
      The status should be success
      The value "$(mode_of $XDG_DATA_HOME/gnupg)" should equal "700"
    End

    It 'does not go deeper than one level'
      mkdir -p "$XDG_CACHE_HOME/npm/_cacache"
      chmod 777 "$XDG_CACHE_HOME/npm/_cacache"
      When call xdg_fix_modes
      The status should be success
      The value "$(mode_of $XDG_CACHE_HOME/npm/_cacache)" should equal "777"
    End
  End

  Describe 'xdg_migrate_home_dirs'
    It 'moves tool data to the XDG path that .zshenv sets'
      mkdir -p "$XDG_TIDY_HOME/.codex/sessions" "$XDG_TIDY_HOME/.gemini"
      touch "$XDG_TIDY_HOME/.codex/auth.json" "$XDG_TIDY_HOME/.duckdb_history"
      When call xdg_migrate_home_dirs
      The status should be success
      The path "$XDG_TIDY_HOME/.codex" should not be exist
      The path "$XDG_DATA_HOME/codex/auth.json" should be file
      The path "$XDG_DATA_HOME/codex/sessions" should be directory
      The path "$XDG_DATA_HOME/gemini/.gemini" should be directory
      The path "$XDG_STATE_HOME/duckdb/history" should be file
    End

    It 'backs up the copy in HOME when the XDG path already exists'
      mkdir -p "$XDG_TIDY_HOME/.gnupg" "$XDG_CONFIG_HOME/gnupg"
      touch "$XDG_TIDY_HOME/.gnupg/stray" "$XDG_CONFIG_HOME/gnupg/real"
      When call xdg_migrate_home_dirs
      The status should be success
      The path "$XDG_CONFIG_HOME/gnupg/real" should be file
      The path "$XDG_CONFIG_HOME/gnupg/stray" should not be exist
      The path "$(backup_dir)/.gnupg/stray" should be file
    End

    It 'moves into an empty target that dotbot created, instead of backing up'
      mkdir -p "$XDG_TIDY_HOME/.gnupg" "$XDG_CONFIG_HOME/gnupg"
      touch "$XDG_TIDY_HOME/.gnupg/pubring.kbx"
      When call xdg_migrate_home_dirs
      The status should be success
      The path "$XDG_CONFIG_HOME/gnupg/pubring.kbx" should be file
      The path "$XDG_STATE_HOME/dotfiles" should not be exist
    End

    It 'rewrites the herdr hook path in the moved Codex hooks.json'
      mkdir -p "$XDG_TIDY_HOME/.codex"
      print -r -- "{\"command\": \"bash '$XDG_TIDY_HOME/.codex/herdr-agent-state.sh' session\"}" \
        > "$XDG_TIDY_HOME/.codex/hooks.json"
      When call xdg_migrate_home_dirs
      The status should be success
      The contents of file "$XDG_DATA_HOME/codex/hooks.json" should include "$XDG_DATA_HOME/codex/herdr-agent-state.sh"
      The contents of file "$XDG_DATA_HOME/codex/hooks.json" should not include "$XDG_TIDY_HOME/.codex/"
    End

    It 'moves the netrw history and removes the then empty .vim'
      mkdir -p "$XDG_TIDY_HOME/.vim"
      touch "$XDG_TIDY_HOME/.vim/.netrwhist" "$XDG_TIDY_HOME/.viminfo"
      When call xdg_migrate_home_dirs
      The status should be success
      The path "$XDG_TIDY_HOME/.vim" should not be exist
      The path "$XDG_STATE_HOME/vim/.netrwhist" should be file
      The path "$XDG_STATE_HOME/vim/viminfo" should be file
    End

    It 'keeps .vim when it holds more than the netrw history'
      mkdir -p "$XDG_TIDY_HOME/.vim/pack"
      When call xdg_migrate_home_dirs
      The status should be success
      The path "$XDG_TIDY_HOME/.vim/pack" should be directory
    End
  End

  Describe 'xdg_move_home_leftovers'
    It 'moves shell startup files that zsh never reads, because ZDOTDIR is set'
      touch "$XDG_TIDY_HOME/.zprofile" "$XDG_TIDY_HOME/.profile" "$XDG_TIDY_HOME/.tcshrc"
      When call xdg_move_home_leftovers
      The status should be success
      The path "$XDG_TIDY_HOME/.zprofile" should not be exist
      The path "$(backup_dir)/.profile" should be exist
      The path "$(backup_dir)/.tcshrc" should be exist
    End

    It 'moves the known leftovers into one dated backup directory'
      touch "$XDG_TIDY_HOME/.zsh_history" "$XDG_TIDY_HOME/.lesshst"
      mkdir -p "$XDG_TIDY_HOME/.zsh_sessions" "$XDG_TIDY_HOME/.cargo/bin" "$XDG_TIDY_HOME/.rustup"
      When call xdg_move_home_leftovers
      The status should be success
      The path "$XDG_TIDY_HOME/.zsh_history" should not be exist
      The path "$XDG_TIDY_HOME/.cargo" should not be exist
      The path "$(backup_dir)/.lesshst" should be exist
      The path "$(backup_dir)/.cargo/bin" should be directory
    End

    It 'moves .atuin when it holds only logs'
      mkdir -p "$XDG_TIDY_HOME/.atuin/logs"
      When call xdg_move_home_leftovers
      The status should be success
      The path "$XDG_TIDY_HOME/.atuin" should not be exist
      The path "$(backup_dir)/.atuin/logs" should be directory
    End

    It 'keeps .atuin when the atuin install script put bin/ there'
      mkdir -p "$XDG_TIDY_HOME/.atuin/logs" "$XDG_TIDY_HOME/.atuin/bin"
      When call xdg_move_home_leftovers
      The status should be success
      The path "$XDG_TIDY_HOME/.atuin/bin" should be directory
    End

    It 'keeps a symlink, because something placed it on purpose'
      mkdir -p "${TEST_DIR}/elsewhere"
      ln -s "${TEST_DIR}/elsewhere" "$XDG_TIDY_HOME/.cargo"
      When call xdg_move_home_leftovers
      The status should be success
      The path "$XDG_TIDY_HOME/.cargo" should be symlink
    End

    It 'creates no backup directory when there is nothing to move'
      When call xdg_move_home_leftovers
      The status should be success
      The path "$XDG_STATE_HOME/dotfiles" should not be exist
    End
  End
End
