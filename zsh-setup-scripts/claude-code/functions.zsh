#!/usr/bin/env zsh

switch-claude() {
  local profile="${1:-}"
  case "$profile" in
    work-fra)
      ~/.claude/ccswitch.sh --switch-to sander.tammesoo@fractory.com
      unset CLAUDE_CONFIG_DIR
      ;;
    work-per)
      ~/.claude/ccswitch.sh --switch-to sander.tammesoo@gmail.com
      unset CLAUDE_CONFIG_DIR
      ;;
    personal)
      ~/.claude/ccswitch.sh --switch-to sander.tammesoo@gmail.com
      export CLAUDE_CONFIG_DIR="$HOME/.claude/profiles/personal"
      ;;
    personal-fra)
      ~/.claude/ccswitch.sh --switch-to sander.tammesoo@fractory.com
      export CLAUDE_CONFIG_DIR="$HOME/.claude/profiles/personal"
      ;;
    *)
      echo "Usage: switch-claude [work-fra|work-per|personal|personal-fra]"
      echo ""
      ~/.claude/ccswitch.sh --list
      return 1
      ;;
  esac
  echo "$profile" > "$HOME/.claude/.active-profile"
  echo "→ switched to: $profile"
}