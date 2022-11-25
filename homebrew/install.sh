#!/bin/sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for Homebrew
if test ! $(which brew); then
	echo "  Installing Homebrew for you."

	# Install the correct homebrew for each OS type
	if test "$(uname)" = "Darwin"; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	elif test "$(expr substr $(uname -s) 1 5)" = "Linux"; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

fi

# Install comandline tools and applications using homebrew bundle

set -e

echo "››› brew update"
brew update

echo "››› brew upgrade"
brew upgrade

# Run Homebrew through the Brewfile
echo "››› brew bundle"
brew bundle

echo "››› brew cleanup"
brew cleanup

exit 0
