1. mkdir ~/projects
2. git clone https://github.com/sandertammesoo/dotfiles.git
3. cd ~/projects/dotfiles/
4. ./run-dotbot
    - Installs Homebrew
    - Installs dotbot
    - Creates ~/.config and symblinks
5. ./install-all
    - Installs Brewfile packages
    - Installs mise to `~/.local/bin/mise` with `curl https://mise.run | sh`,
      not Homebrew (owner of all language runtimes — see
      docs/adr/0001-mise-for-runtime-management.md). Update it with
      `mise self-update`.
6. mise install
    - Installs the global runtimes (node, python, go) pinned in
      xdg_config/mise/config.toml
7. mise trust ~/projects/dotfiles/mise.toml
    - Allows the repo's task definitions (`mise run test`, `mise run link`)
8. Install brew-drift: `make install` in `~/projects/utils/brew-drift`
    - `install-all` already wrote `~/.config/brew-drift/config.toml`
      (profile `mac`) and a launchd agent that runs `brew-drift status`
      each Monday at 10:00. It shows a notification when it finds drift.
    - The notification comes from Script Editor. If you see none, allow
      notifications for Script Editor in System Settings → Notifications.

## Headless server (e.g. jupiter)

An always-on Mac that you reach over SSH. It gets the same shell, but only
the tools in `brewfiles/server.Brewfile` — no GUI apps, no window management.

Before you start, on the server (one time, with a monitor or Screen Sharing):

1. In System Settings → General → Sharing, turn on Remote Login and
   Screen Sharing (or Remote Management).
2. From your main Mac, run `ssh-copy-id <user>@<host>.local`.
   `install-server` refuses to disable password login without a key.

Then, in an SSH session on the server:

1. Install Homebrew (this also installs git):
   `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
2. `git clone https://github.com/sandertammesoo/dotfiles.git ~/projects/dotfiles`
3. `~/projects/dotfiles/install-server --hostname <host>`
    - DotBot links, then `server.Brewfile`
    - pmset: no sleep, lid close ignored, display off after 1 min
    - sshd: key-only login (`/etc/ssh/sshd_config.d/050-server.conf`)
    - tailscale and batt as root services; battery capped at 80%
    - mise from `mise.run` (to `~/.local/bin/mise`), then `mise install`
    - `~/.config/brew-drift/config.toml` with profile `server`. There is no
      weekly reminder on a server: run `brew-drift status` over SSH.
4. Open a new SSH session. Test key-only login with `ssh -S none <host> true`
   — `-S none` skips a shared ControlMaster connection, which would
   otherwise pass the test without a new login.

`install-server` is idempotent. Run it again after you change
`server.Brewfile` or `zsh-setup-scripts/server/setup.sh`.
