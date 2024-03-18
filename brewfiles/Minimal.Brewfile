# # Make sure we’re using the latest Homebrew
#brew update

# # Upgrade any already-installed formulae
#brew upgrade

cask_args appdir: '/Applications'

tap 'homebrew/bundle'
tap 'homebrew/cask-fonts'
tap 'homebrew/services'

tap 'felixkratz/formulae'       # For Sketchybar
tap 'koekeishiya/formulae'      # For Yabai
brew 'mas'                      # Apple's Mac App Store CLI
brew 'brew-cask-completion'     # Fish completion for brew-cask

#  Cask-Update tool that works with brew cask to update all of your Mac apps. To upgrade all of you Mac apps, just do: brew cu
# Cask-Update details some other features. In particular, I like brew cu pin <caskname> which locks an app to a specific version.
tap "buo/cask-upgrade" 

# Version Control
brew 'git'
brew 'git-flow'

# CLI Utils
brew 'coreutils'    # GNU File, Shell, and Text utilities https://www.gnu.org/software/coreutils
brew 'moreutils'    # Collection of tools that nobody wrote when UNIX was young https://joeyh.name/code/moreutils/
brew 'findutils'    # Collection of GNU find, xargs, and locate https://www.gnu.org/software/findutils/
brew 'grep'         # GNU grep, egrep and fgrep https://www.gnu.org/software/grep/
brew 'tree'         # Display directories as trees (with optional color/HTML output) https://oldmanprogrammer.net/source.php?dir=projects/tree
brew 'wget'         # Internet file retriever https://www.gnu.org/software/wget/
brew "htop"         # Improved top (interactive process viewer) https://htop.dev/
brew "jq"           # Lightweight and flexible command-line JSON processor https://jqlang.github.io/jq/
# brew 'gnu-sed', args: ['with-default-names'] # GNU implementation of the famous stream editor https://www.gnu.org/software/sed/

brew "felixkratz/formulae/sketchybar"   # Custom macOS statusbar with shell plugin, interaction and graph support https://github.com/FelixKratz/SketchyBar
brew "koekeishiya/formulae/skhd"        # Simple hotkey-daemon for macOS. https://github.com/koekeishiya/skhd
brew "koekeishiya/formulae/yabai"       # A tiling window manager for macOS based on binary space partitioning. https://github.com/koekeishiya/yabai
cask "font-hack-nerd-font"              # Developer targeted fonts with a high number of glyphs
cask "font-sf-pro"                      # Sans-serif variant of "San Francisco" by Apple
cask "sf-symbols"