# shellcheck shell=zsh
# ShellSpec tests for the Starship prompt config.
#
# herdr resizes panes often. A prompt line that reaches the full pane width
# wraps on a resize, and zsh then redraws the prompt without erasing the old
# copy. These tests pin the layout that avoids that, and keep the prompt free
# of Starship warnings (a custom command run through zsh used to hit
# command_timeout, because zsh sources .zshenv first).

Describe 'starship prompt config'
  CONFIG="xdg_config/zsh/starship.toml"

  # Prints the body of the top-level `format = """...."""` block.
  left_format() {
    awk '/^format = """/{on=1; next} on && /"""/{exit} on' "$CONFIG"
  }

  # Prints the name of each [custom.*] table that has no `shell =` key.
  custom_modules_without_shell() {
    awk '
      /^\[/ { if (name != "" && !has_shell) print name; name = ""; has_shell = 0 }
      /^\[custom\./ { name = $0 }
      name != "" && /^shell *=/ { has_shell = 1 }
      END { if (name != "" && !has_shell) print name }
    ' "$CONFIG"
  }

  Describe 'layout'
    It 'keeps $fill out of the left format, so line 1 never fills the pane'
      When call left_format
      The output should not include '$fill'
    End

    It 'puts the right-hand modules in right_format'
      The contents of file "$CONFIG" should include 'right_format = '
    End

    It 'sets TRANSIENT_RPROMPT, so scrollback carries no right prompt to re-wrap'
      The contents of file "zsh-setup-scripts/zsh/config.zsh" should include 'setopt TRANSIENT_RPROMPT'
    End
  End

  Describe 'custom modules'
    It 'gives every [custom.*] module an explicit shell'
      When call custom_modules_without_shell
      The output should equal ''
    End
  End

  Describe 'rendered prompt'
    Skip if "starship not installed" test -z "$(command -v starship)"

    render() {
      STARSHIP_CONFIG="$PWD/$CONFIG" STARSHIP_LOG=warn starship prompt "$@" </dev/null
    }

    It 'renders the left prompt without warnings'
      When call render
      The output should include '❯'
      The error should equal ''
    End

    # Its content depends on the machine (cloud, node, git email), so only
    # stderr is checked.
    right_warnings() { render --right 2>&1 >/dev/null; }

    It 'renders the right prompt without warnings'
      When call right_warnings
      The status should be success
      The output should equal ''
    End
  End
End
