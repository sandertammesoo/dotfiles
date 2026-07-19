1. mkdir ~/projects
2. git clone https://github.com/sandertammesoo/dotfiles.git
3. cd ~/projects/dotfiles/
4. ./run-dotbot
    - Installs Homebrew
    - Installs dotbot
    - Creates ~/.config and symblinks
5. ./install-all
    - Installs Brewfile packages, including mise (owner of all language
      runtimes — see docs/adr/0001-mise-for-runtime-management.md)
6. mise install
    - Installs the global runtimes (node, python, go) pinned in
      xdg_config/mise/config.toml
7. mise trust ~/projects/dotfiles/mise.toml
    - Allows the repo's task definitions (`mise run test`, `mise run link`)
