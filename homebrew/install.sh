# Install comandline tools and applications using homebrew bundle

set -e

echo "› brew update"
brew update

echo "› brew upgrade"
brew upgrade

# Run Homebrew through the Brewfile
echo "› brew bundle"
brew bundle

echo "› brew cleanup"
brew cleanup
