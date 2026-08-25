# Live per-command tab renaming for the herdr-automatic-rename plugin.
#
# herdr emits no "foreground command changed" event, so the plugin ships zsh
# preexec/precmd hooks to cover that gap; its own [[events]] handle everything
# else. Without this file a new tab name waits for the next focus or tab event.
#
# Lives in functions.zsh, not env.zsh, for two reasons: the func batch is
# sourced after the explicit starship -> atuin -> navi block in .zshrc, which is
# the order the plugin's README asks for, and the vendor hook's whole job is
# registering two hook functions. It is safe either way — the hook appends via
# add-zsh-hook and wraps no ZLE widget or keymap, so it cannot reproduce the
# FUNCNEST class of bug that pins the starship/atuin order.
#
# The plugin is provisioned by zsh-setup-scripts/herdr/install.sh. herdr installs
# it into a hashed directory, hence the glob; (N) keeps a missing plugin quiet.

# The vendor hook no-ops outside a herdr pane on its own. Testing HERDR_PANE_ID
# here as well skips the glob entirely in a plain terminal.
if [[ -n "${HERDR_PANE_ID:-}" ]]; then
  for _har_hook in ${XDG_CONFIG_HOME:-$HOME/.config}/herdr/plugins/github/herdr-automatic-rename-*/shell/hook.zsh(N); do
    try_source "$_har_hook" debug
    break
  done
  unset _har_hook
fi
