# The user configuration files installation

```sh
mkdir -p "$HOME/.local/state"
git_url_cfg="https://github.com/andis-sprinkis/nix-user-config"
dir_cfg_git="$HOME/.local/state/dotfiles_git"
git clone --bare $git_url_cfg $dir_cfg_git
git --git-dir=$dir_cfg_git --work-tree=$HOME config --local status.showUntrackedFiles no
git --git-dir=$dir_cfg_git --work-tree=$HOME checkout -f
git --git-dir=$dir_cfg_git --work-tree=$HOME submodule update --init
```
