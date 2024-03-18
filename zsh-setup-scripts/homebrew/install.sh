#!/bin/sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.
set -e
source helpers.zsh

# Check for Homebrew
if test ! $(which brew); then
	echo "Homebrew not installed..."
	echo "  Installing Homebrew for you."

	# Install the correct homebrew for each OS type
	if test "$(uname)" = "Darwin"; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	elif test "$(expr substr $(uname -s) 1 5)" = "Linux"; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	else
		error "  FAILED: unknown uname!"
		return
	fi
fi

echo "Updateing brew formulae..."
brew update

echo "Installing packages from Brewfile..."
brew bundle --file=./brewfiles/Minimal.Brewfile
brew bundle --file=./brewfiles/Base.Brewfile
brew bundle --file=./brewfiles/zsh.Brewfile
brew bundle --file=./brewfiles/dev.Brewfile
brew bundle --file=./brewfiles/nvim.Brewfile
brew bundle --file=./brewfiles/misc.Brewfile
brew bundle --file=./brewfiles/CTF.Brewfile

echo "Brew cleanup..."
brew cleanup

exit 0
