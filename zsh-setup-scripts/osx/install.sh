#!/bin/sh
set -e
source helpers.zsh

if test ! "$(uname)" = "Darwin"; then
	error "      MacOS not detected!"
	return
	#exit 0
fi

# The Brewfile handles Homebrew-based app and library installs, but there may
# still be updates and installables in the Mac App Store. There's a nifty
# command line interface to it that we can use to just install everything, so
# yeah, let's do that.

debug "      › sudo softwareupdate -i -a"
sudo softwareupdate -i -a
