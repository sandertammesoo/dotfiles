# Add tab completion for many Bash commands
TMP_LC_ALL=$LC_ALL
LC_ALL=C
if which brew > /dev/null && [ -f "$(brew --prefix)/etc/bash_completion" ]; then
	source "$(brew --prefix)/etc/bash_completion";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;
LC_ALL=$TMP_LC_ALL
