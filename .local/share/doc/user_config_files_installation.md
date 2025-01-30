# The user configuration files installation

```sh
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}"
dir_git="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles_git"
dir_tmp=$(mktemp -d)
git clone --separate-git-dir=$dir_git https://github.com/andis-sprinkis/nix-user-config $dir_tmp
rsync --recursive --verbose --exclude '.git/' $dir_tmp/ $HOME
git --git-dir=$dir_git --work-tree=$HOME config --local status.showUntrackedFiles no
git --git-dir=$dir_git --work-tree=$HOME submodule update --init
```
