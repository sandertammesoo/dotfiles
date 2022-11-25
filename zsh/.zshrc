# ~/.config/.zsh/.zshrc
#
# shortcut to this dotfiles path is $ZSH
export ZSH=$XDG_CONFIG_HOME/.dotfiles

# Stash your environment variables in ~/.localrc. This means they'll stay out
# of your main dotfiles repository (which may be public, like this one), but
# you'll have access to them in your scripts.
if [[ -a ~/.config/.localrc ]]
then
  source ~/.config/.localrc
fi

# Get all of our zsh files from the .dotfile filetree
typeset -U config_files
config_files=($ZSH/**/*.zsh)

# Load in all the path.zsh files that export environment variables
for file in ${(M)config_files:#*/path.zsh}
do
  source $file
done

# Load everything but the path and completion files
for file in ${${config_files:#*/path.zsh}:#*/completion.zsh}
do
  source $file
done

# initialize autocomplete here, otherwise functions won't be loaded
autoload -U compinit
compinit

# load every completion after autocomplete loads
for file in ${(M)config_files:#*/completion.zsh}
do
  source $file
done

unset config_files
