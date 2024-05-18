# Creating a repository for storing the user configuration files

```sh
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}"
dir_git="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles_git"
mkdir $dir_git
git init --bare $dir_git
git --git-dir=$dir_git --work-tree=$HOME config --local status.showUntrackedFiles no
git --git-dir=$dir_git --work-tree=$HOME add $HOME/.zshrc
git --git-dir=$dir_git --work-tree=$HOME commit -m "add .zshrc"
```

## Git command shorthand

For executing Git commands with user config repository parameters, it is convenient to define a command:

-   Via `alias` in a shell startup file:
    ```sh
    alias dotgit="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles_git" --work-tree=$HOME
    ```
-   Or as a script in `PATH`:

    ```sh
    #!/usr/bin/env sh

    exec git --git-dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles_git" --work-tree=$HOME "$@"
    ```
