# Installation
```
git clone --separate-git-dir=$HOME/.dotfiles-git git@github.com:andis-spr/dotfiles-vm-00.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
```
# Git Configuration
```
dot-git config --local status.showUntrackedFiles no
```

# First Time Preparations
```
echo 'alias dotgit='/usr/bin/git --git-dir=$HOME/.dotfiles-git/ --work-tree=$HOME'' >>$HOME/.zshrc
. .zshrc
mkdir $HOME/.dotfiles-git
git init --bare $HOME/.dotfiles-git
dotgit config --local status.showUntrackedFiles no
```
