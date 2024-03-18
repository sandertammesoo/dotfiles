# ~/.config/.zsh/.zshrc
log_info "Loading $ZDOTDIR/.zshrc"

# shortcut to this dotfiles path is $ZSH
export ZSH=$XDG_CONFIG_HOME/.dotfiles/zsh-setup-scripts
debug "Set ZSH=$ZSH"

# Helper functions for printing loging info in to the terminal
#source $XDG_CONFIG_HOME/.dotfiles/helpers.zsh
# info $ZSH

# The order of zsh dotfiles to be loaded:
# $XDG_CONFIG_HOME/.localrc
# All path.zsh files in $ZSH tree folder
# All *.zsh (exept path, completion and functions) files in $ZSH tree folder
# All functions.zsh files in $ZSH tree folder
# All completion.zsh files in $ZSH tree folder

# Stash your environment variables in $XDG_CONFIG_HOME/.localrc (~/.config/.localrc). 
# This means they'll stay out of your main dotfiles repository (which may be public, 
# like this one), but you'll have access to them in your scripts.
if [[ -a $XDG_CONFIG_HOME/.localrc ]]
then
  source $XDG_CONFIG_HOME/.localrc
  debug "Done."
else
  warn ".localrc not found in $XDG_CONFIG_HOME"
fi

log_info "Loading *.zsh configuration files from .dotfiles"
debug "Get all of our zsh files from the .dotfile filetree ($ZSH)"
typeset -U config_files
config_files=($ZSH/**/*.zsh)

debug "PATH - Load in Homebrew path.zsh file"
if [[ -a $ZSH/homebrew/path.zsh ]]
then
  debug "Loading $ZSH/homebrew/path.zsh"
  source $ZSH/homebrew/path.zsh
else
  warn "$ZSH/homebrew/path.zsh"
fi

debug "PATH - Load in System path.zsh file"
if [[ -a $ZSH/system/path.zsh ]]
then
  debug "Loading $ZSH/system/path.zsh"
  source $ZSH/system/path.zsh
else
  warn "$ZSH/system/path.zsh"
fi

debug "PATH - Load in other the path.zsh files that export environment variables"
for file in ${${${(M)config_files:#*/path.zsh}:#*/homebrew/path.zsh}:#*/system/path.zsh}
do
  debug "Loading "${file}
  source $file
done

debug "OTHER - Load everything but the path, completion and functions files"
for file in ${${${config_files:#*/path.zsh}:#*/completion.zsh}:#*/functions.zsh}
do
  debug "Loading "${file}
  source $file
done

debug "FUNC - Load in all the functions.zsh files"
for file in ${(M)config_files:#*/functions.zsh}
do
  debug "Loading "${file}
  source $file
done

debug "initialize autocomplete, otherwise functions won't be loaded"
autoload -U compinit
compinit

debug "COMPLETION - load every completion after autocomplete loads"
for file in ${(M)config_files:#*/completion.zsh}
do
  debug "Loading "${file}
  source $file
done

unset config_files
