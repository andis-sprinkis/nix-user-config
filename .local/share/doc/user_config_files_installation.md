# The user configuration files installation

```sh
mkdir -p "$HOME/.local/state"
git_url="https://github.com/andis-sprinkis/nix-user-config"
dir_git="$HOME/.local/state/dotfiles_git"
git clone --bare $git_cfg $dir_git
git --git-dir=$dir_git --work-tree=$HOME config --local status.showUntrackedFiles no
git --git-dir=$dir_git --work-tree=$HOME checkout -f
git --git-dir=$dir_git --work-tree=$HOME submodule update --init
```
