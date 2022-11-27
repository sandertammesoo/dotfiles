# ~/.config/.zsh/.zshrc
#

# shortcut to this dotfiles path is $ZSH
export ZSH=$XDG_CONFIG_HOME/.dotfiles/zsh-setup-scripts
source $XDG_CONFIG_HOME/.dotfiles/helpers.zsh
# info $ZSH

# Stash your environment variables in ~/.localrc. This means they'll stay out
# of your main dotfiles repository (which may be public, like this one), but
# you'll have access to them in your scripts.
if [[ -a $XDG_CONFIG_HOME/.localrc ]]
then
  # info ".localrc found"
  source $XDG_CONFIG_HOME/.localrc
  # success ".localrc sourced"
# else
#   fail ".localrc not found"
fi

# Get all of our zsh files from the .dotfile filetree
# info "looking for zsh setup scripts"
typeset -U config_files
config_files=($ZSH/**/*.zsh)
# success "done"

# Load in all the path.zsh files that export environment variables
for file in ${(M)config_files:#*/path.zsh}
do
  # info "sourcing "${file}
  source $file
  # success "done"
done

# Load everything but the path and completion files
for file in ${${config_files:#*/path.zsh}:#*/completion.zsh:#*/functions.zsh}
do
  # info "sourcing "${file}
  source $file
  # success "done"
done

for file in ${(M)config_files:#*/functions.zsh}
do
  # info "sourcing "${file}
  source $file
  # success "done"
done

# initialize autocomplete here, otherwise functions won't be loaded
autoload -U compinit
compinit

# load every completion after autocomplete loads
for file in ${(M)config_files:#*/completion.zsh}
do
  # info "sourcing "${file}
  source $file
  # success "done"
done

unset config_files
