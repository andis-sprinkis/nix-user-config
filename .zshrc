# Based on "Luke's config for the Zoomer Shell"

# use the GNU utils on macOS
if [[ "$OSTYPE" == "darwin"* ]]
then
  if [ ! -d /usr/local/opt/coreutils/libexec/gnubin ]
  then
    echo "GNU coreutils for macOS are not found (sourcing coreutils)"
  else
    PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:${MANPATH}"
  fi
fi

if [[ "$OSTYPE" == "darwin"* ]]
then
  install_coreutils_macos() {
    brew install coreutils findutils gnu-tar gnu-sed gawk gnutls gnu-indent gnu-getopt grep
  }
fi

# Enable colors and change prompt:
autoload -U colors && colors

# remember and cd to last dir
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
cdr

# git
if command="$(type -p "git")" || ! [[ -z $command ]]
then
  autoload -Uz vcs_info
  precmd_vcs_info() { vcs_info }
  precmd_functions+=( precmd_vcs_info update-term-window-title )
  setopt prompt_subst
  zstyle ':vcs_info:git:*' formats "$bg[white]$fg[black]  %b %{$reset_color%}"
else
  precmd_functions+=( update-term-window-title )
fi

# prompt colors
#
USERHOSTCOLOR='cyan'

if [[ $(whoami) == 'root' ]]
then
  USERHOSTCOLOR='magenta'
fi

SSHSTATUS=''
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  SSHSTATUS="%{$bg[blue]$fg[black]%} SSH "
fi

# prompt
PS1="%{$bg[$USERHOSTCOLOR] $fg[black]%}%n@%M $SSHSTATUS%{$reset_color%}\$vcs_info_msg_0_%{$bg[white]$fg[black]%} %/ 
%{$reset_color$fg[$USERHOSTCOLOR]%}$%{$reset_color%} "

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000

if [ ! -f $HOME/.cache/zsh ]
then
  mkdir -p $HOME/.cache/zsh
  touch $HOME/.cache/history
fi

HISTFILE=~/.cache/zsh/history

# basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# lf cd
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}

# auto cd
setopt autocd

# ssh bookmarks
SSHBOOKMARKS=$HOME/ssh-bookmark/ssh-bookmark
if [ -f $SSHBOOKMARKS ]
then
  source $SSHBOOKMARKS
fi

# alias

COREUTILS_LS='ls -hAFX --color --group-directories-first'

if [[ "$OSTYPE" == "darwin"* ]]
then
  if [ ! -d /usr/local/opt/coreutils/libexec/gnubin ]
  then
    echo "GNU utils for macOS are not found (ls alias)"
  else
    alias ls=$COREUTILS_LS
  fi
else
  alias ls=$COREUTILS_LS
fi

alias mv='mv -v'
alias mkdir='mkdir -p'
alias v='nvim'
alias vim='nvim'
alias rss='newsboat'
alias less="less -R"
alias diskspace="df -h | grep Filesystem; df -h | grep /dev/sd; df -h | grep @"
alias dmenu='setdmenu -l 8'
alias dotgit='git --git-dir=$HOME/.dotfiles-git/ --work-tree=$HOME'
alias zshrcgit='git --git-dir=$HOME/.zshrc-git/ --work-tree=$HOME'
alias set_ssh_dir_permissions='chmod 700 ~/.ssh; chmod 600 ~/.ssh/*; chmod 644 -f ~/.ssh/*.pub ~/.ssh/authorized_keys ~/.ssh/known_hosts'

# general user scripts
USERSCRIPTS="$HOME/scripts"
if [ -d "$USERSCRIPTS" ]
then
  export USERSCRIPTS="$HOME/scripts"
  PATH=$PATH:$USERSCRIPTS
fi

# editor
if command="$(type -p "nvim")" || ! [[ -z $command ]]
then
  EDITOR="nvim"
elif command="$(type -p "vim")" || ! [[ -z $command ]]
then
  EDITOR="vim"
elif command="$(type -p "vi")" || ! [[ -z $command ]]
then
  EDITOR="vi"
elif command="$(type -p "nano")" || ! [[ -z $command ]]
then
  EDITOR="nano"
fi

export EDITOR=$EDITOR

# update terminal window title with relevant info
function update-term-window-title {
    echo -n "\033]0;${TERM} - ${USER}@${HOST} - ${PWD}\007"
}
update-term-window-title

# fzf options and completion
if command="$(type -p "fzf")"
then
  export FZF_DEFAULT_OPTS="--tabstop=4 --cycle --height 50% --layout=reverse"
  if [ -d /usr/share/fzf ]
  then
    source /usr/share/fzf/completion.zsh
  elif [ -d $HOME/.fzf ]
  then
    source $HOME/.fzf/shell/completion.zsh
  fi
fi

# nvm

if [[ "$OSTYPE" == "darwin"* ]]
then
  if [ ! -d /usr/local/opt/nvm ]
  then
    # echo "nvm for macOS is not found"
  else
    export NVM_DIR="$HOME/.nvm"
    [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
    [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
  fi
else
  NVM_DIR=$HOME/.nvm
  if [ ! -d $NVM_DIR ]
  then
    # echo "nvm is not found"
  else
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    export NVM_DIR=$NVM_DIR
  fi
fi

# npm bin PATH
if command="$(type -p "npm")"
then
  PATH=$PATH:$(npm bin -g)
fi

# updating itself
export update_zshrc() {
  wget --no-cache -P $HOME/ https://raw.githubusercontent.com/andis-spr/linux-user-config/master/.zshrc
  if [ -f $HOME/.zshrc.1 ]
  then
    rm .zshrc
    mv .zshrc.1 .zshrc
  fi
}

# PATH
export PATH=$PATH

# load zsh-syntax-highlighting; should be last
# TODO: check for macos/brew path
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
