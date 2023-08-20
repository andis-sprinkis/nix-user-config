# Andis *nix user configuration files

## Installation

```sh
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}"
dir_git="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles_git"
dir_tmp=$(mktemp -d)
git clone --separate-git-dir=$dir_git https://github.com/andis-sprinkis/nix-user-config $dir_tmp
rsync --recursive --verbose --exclude '.git' $dir_tmp/ $HOME
git --git-dir=$dir_git --work-tree=$HOME config --local status.showUntrackedFiles no
git --git-dir=$dir_git --work-tree=$HOME submodule update --init
```

## Setting up a repository like this one for storing user configuration files
```sh
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}"
dir_git="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles_git"
mkdir $dir_git
git init --bare $dir_git
git --git-dir=$dir_git --work-tree=$HOME config --local status.showUntrackedFiles no
git --git-dir=$dir_git --work-tree=$HOME add $HOME/.zshrc
git --git-dir=$dir_git --work-tree=$HOME commit -m "add .zshrc"
```

### Git command shorthand

For executing Git commands with user config repository parameters, it is convenient to define a command:
- Via `alias` in a shell startup file:
  ```sh
  alias dotgit="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles_git" --work-tree=$HOME
  ```
- Or as a script in `PATH`:
  ```sh
  #!/bin/sh

  exec git --git-dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles_git" --work-tree=$HOME "$@"
  ```
