if [ -f /usr/local/etc/bash_completion.d/.git-completion.bash ]; then
  source /usr/local/etc/bash_completion.d/.git-completion.bash
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null && [ -f /usr/local/etc/bash_completion.d/.git-completion.bash ]; then
	complete -o default -o nospace -F _git g;
fi;
