# Headless server profile — installed by ./install-server
#
# A subset of brewfiles/Brewfile: the shell environment, the CLI tools that
# are useful over SSH, and the server services. No GUI apps, no window
# management, no casks. Keep each line identical to its Brewfile line so a
# tool behaves the same on both machines.

# Dotfiles bootstrap — run-dotbot needs both
brew "dotbot"                   # Bootstrap your dotfiles https://github.com/anishathalye/dotbot
brew "gettext"                  # envsubst for run-dotbot https://www.gnu.org/software/gettext/

# Shell — every tool that .zshrc loads by name
brew "zsh-autosuggestions"      # Fish-like autosuggestions for zsh (zsh/plugins.zsh sources it)
brew "zsh-syntax-highlighting"  # Fish shell like syntax highlighting for zsh (zsh/plugins.zsh sources it)
brew "starship"                 # Cross-shell prompt for astronauts https://starship.rs/
brew "atuin"                    # Improved shell history https://atuin.sh/
brew "zoxide"                   # Shell extension to navigate your filesystem faster https://github.com/ajeetdsouza/zoxide
brew "fzf"                      # Command-line fuzzy finder written in Go https://github.com/junegunn/fzf
brew "mise"                     # Polyglot runtime version manager, env vars, task runner https://mise.jdx.dev/

# Everyday CLI
brew "coreutils"                # GNU File, Shell, and Text utilities https://www.gnu.org/software/coreutils
brew "ripgrep"                  # Search tool like grep and The Silver Searcher https://github.com/BurntSushi/ripgrep
brew "fd"                       # Simple, fast and user-friendly alternative to find https://github.com/sharkdp/fd
brew "bat"                      # Clone of cat(1) with syntax highlighting and Git integration https://github.com/sharkdp/bat
brew "eza"                      # Modern, maintained replacement for ls https://github.com/eza-community/eza
brew "tree"                     # Display directories as trees https://oldmanprogrammer.net/source.php?dir=projects/tree
brew "jq"                       # Lightweight and flexible command-line JSON processor https://jqlang.github.io/jq/
brew "tlrc"                     # Official tldr client written in Rust https://tldr.sh/tlrc
brew "yazi"                     # Blazing fast terminal file manager https://yazi-rs.github.io/

# Git
brew "git"                      # Distributed revision control system https://git-scm.com
brew "gitleaks"                 # Detect hardcoded secrets in git repos — the machine-wide pre-commit gate
brew "lazygit"                  # Simple terminal UI for git commands https://github.com/jesseduffield/lazygit/
brew "delta"                    # Syntax-highlighting pager for git, diff, and grep output https://github.com/dandavison/delta

# Sessions — a session survives a dropped SSH connection
brew "tmux"                     # Terminal multiplexer https://github.com/tmux/tmux
brew "herdr"                    # Terminal workspace manager for AI coding agents https://herdr.dev/

# Monitoring
brew "htop"                     # Improved top (interactive process viewer) https://htop.dev/
brew "ncdu"                     # NCurses Disk Usage https://dev.yorhel.nl/ncdu
brew "duf"                      # Disk Usage/Free Utility https://github.com/muesli/duf

# Server services — install-server starts both as root services
brew "tailscale"                # Mesh VPN; the formula runs tailscaled as a boot-time daemon https://tailscale.com/
brew "batt"                     # Battery charge limiter for Apple Silicon https://github.com/charlie0129/batt
