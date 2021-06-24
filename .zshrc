# Based on "Luke's config for the Zoomer Shell"

# default .profile
source $HOME/.profile 2>/dev/null

# use the GNU utils on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [ ! -d /usr/local/opt/coreutils/libexec/gnubin ]; then
    echo "zshrc: GNU coreutils for macOS are not found (sourcing coreutils)"
  else
    PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:${MANPATH}"
  fi
fi

# Enable colors and change prompt:
autoload -U colors && colors

# remember and cd to last dir
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
cdr

# git
if command="$(type -p "git")" || ! [[ -z $command ]]; then
  autoload -Uz vcs_info
  precmd_vcs_info() { vcs_info }
  precmd_functions+=( precmd_vcs_info update-term-window-title )
  setopt prompt_subst
  zstyle ':vcs_info:git:*' formats "$bg[white]$fg[black]  %b %{$reset_color%}"
else
  precmd_functions+=( update-term-window-title )
fi

# prompt colors
USERHOSTCOLOR='cyan'
if [[ $(whoami) == 'root' ]]; then
  USERHOSTCOLOR='magenta'
fi

# ssh session status in prompt
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

# function to fix corrupt zsh_history
function fix_zsh_histfile {
  mv $HISTFILE $HOME/.zsh_history_old
  strings $HOME/.zsh_history_old > $HISTFILE
  rm $HOME/.zsh_history_old
}

[ ! -f $HOME/.cache/zsh ] && mkdir -p $HOME/.cache/zsh && touch $HOME/.cache/zsh/history
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
[ -f $HOME/ssh-bookmark/ssh-bookmark ] && source $HOME/ssh-bookmark/ssh-bookmark

# use nvim as manpages pager
if command="$(type -p "nvim")" || ! [[ -z $command ]]; then
  export MANPAGER='nvim +Man!'
  export MANWIDTH=999
fi

# alias

if [[ "$OSTYPE" == "darwin"* ]] && [ ! -d /usr/local/opt/coreutils/libexec/gnubin ]; then
  echo "zshrc: GNU utils for macOS are not found (ls alias)"
else
  alias ls='ls -hAFX --color --group-directories-first'
fi

alias mv='mv -v'
alias cp='cp -rv'
alias rm='rm -v'
alias mkdir='mkdir -p'
alias tree='tree -CF'
alias nvim_nogit='nvim --cmd "let g:nogit=1"'
alias less="less -R"
alias diskspace="df -h | grep Filesystem; df -h | grep /dev/sd; df -h | grep @"
alias dmenu='setdmenu -l 8'
alias dotgit='git --git-dir=$HOME/.dotfiles-git/ --work-tree=$HOME'
alias sshdirp='chmod 700 ~/.ssh; chmod 600 ~/.ssh/*; chmod 644 -f ~/.ssh/*.pub ~/.ssh/authorized_keys ~/.ssh/known_hosts'
alias myip='curl https://ipinfo.io/'

# general user scripts
[ -d "$HOME/scripts" ] && export USERSCRIPTS=$HOME/scripts && PATH=$PATH:$HOME/scripts

# editor
  if command="$(type -p "nvim")" || ! [[ -z $command ]]; then; export EDITOR="nvim"
elif command="$(type -p "vim")" || ! [[ -z $command ]]; then; export EDITOR="vim"
elif command="$(type -p "vi")" || ! [[ -z $command ]]; then; export EDITOR="vi"
elif command="$(type -p "nano")" || ! [[ -z $command ]]; then; export EDITOR="nano"; fi

# update terminal window title with relevant info
function update-term-window-title {
  echo -n "\033]0;${TERM} - ${USER}@${HOST} - ${PWD}\007"
}
update-term-window-title

if command="$(type -p "bat")" || ! [[ -z $command ]]; then
  export BAT_THEME="ansi"
  export BAT_STYLE="plain"
fi

# fzf options and completion
if command="$(type -p "fzf")" || ! [[ -z $command ]]; then
  if command="$(type -p "bat")" || ! [[ -z $command ]]; then
    export FZF_DEFAULT_OPTS="--tabstop=2 --cycle --color=dark --layout=reverse --preview 'bat --color=always --line-range=:500 {}'"
  else
    export FZF_DEFAULT_OPTS="--tabstop=4 --cycle --color=dark --height 50% --layout=reverse"
  fi

  if [ -f /usr/share/fzf/completion.zsh ]; then
    source /usr/share/fzf/completion.zsh
  else
    [ -d $HOME/.fzf ] && source $HOME/.fzf/shell/completion.zsh
  fi
fi

# nvm
if [ -d $HOME/.nvm ]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    [ -s /usr/local/opt/nvm/nvm.sh ] && . /usr/local/opt/nvm/nvm.sh
    [ -s /usr/local/opt/nvm/etc/bash_completion.d/nvm ] && . /usr/local/opt/nvm/etc/bash_completion.d/nvm
  else
    [ -s $HOME/.nvm/nvm.sh ] && . $HOME/.nvm/nvm.sh
    [ -s $HOME/.nvm/bash_completion ] && . $HOME/.nvm/bash_completion
  fi
  export NVM_DIR=$HOME/.nvm
fi

# updating zshrc
export update_zshrc() {
  wget --no-cache -P $HOME/ https://raw.githubusercontent.com/andis-spr/linux-user-config/master/.zshrc
  [ -f $HOME/.zshrc.1 ] && rm $HOME/.zshrc && mv $HOME/.zshrc.1 $HOME/.zshrc
}

# PATH
export PATH=$PATH

# load zsh-syntax-highlighting; should be last
# arch, macos, debian
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null \
  || source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null \
  || source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
