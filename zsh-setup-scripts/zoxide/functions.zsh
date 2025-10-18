#!/usr/bin/env zsh

# if (( $+commands[zoxide] )); then
# 	success " ✓ zoxide is installed, setting up zoxide environment"
	
# 	# Initialize zoxide
# 	eval "$(zoxide init zsh)"
	
# 	# Add hook to list directory contents after changing directory
# 	chpwd() {
# 		la
# 	}
# fi

# Always list directory contents upon 'cd'
function cd() {
	#!/usr/bin/env zsh

# Check if zoxide is available and z function is defined
	if command -v zoxide &>/dev/null && type z &>/dev/null 2>&1; then
		z "$@"
	else
		builtin cd "$@"
	fi
	la
}