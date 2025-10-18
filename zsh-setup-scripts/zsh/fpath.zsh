#!/usr/bin/env zsh

# Add custom completions directory
log_verbose "Add custom completions directory $XDG_CONFIG_HOME/zsh/completions to fpath"
export fpath=("$XDG_CONFIG_HOME/zsh/completions" $fpath)

log_verbose "Add each topic folder to fpath so that they can add functions and completion scripts"
for topic_folder in "$ZSH"/*; do
  if [[ -d "$topic_folder" ]]; then
    log_trace "$(color_text ${LOG_COLORS[TRACE]} bold "Adding to fpath:") $topic_folder"
    export fpath=("$topic_folder" $fpath)
  fi
done
