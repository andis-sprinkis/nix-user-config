# Based on "Luke's config for the Zoomer Shell"

# default .profile
[ -f $HOME/.profile ] && source $HOME/.profile

# use the GNU utils on macOS
if [[ $OSTYPE == "darwin"* ]]; then
  if [ ! -d /usr/local/opt/coreutils/libexec/gnubin ]; then
    echo "zshrc: GNU coreutils for macOS are not found (sourcing coreutils)"
  else
    PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:${MANPATH}"
  fi
fi

# Enable colors and change prompt:
autoload -U colors
colors

# comments in interactive mode
setopt interactive_comments

# remember and cd to last dir
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
cdr

# function to detect if given command is executable
is-exec() {
  if command="$(type -p "$1")" || [[ -z $command ]] && return 0
  return 1
}

# git
if is-exec "git"; then
  autoload -Uz vcs_info
  precmd_vcs_info() { vcs_info }
  precmd_functions+=( precmd_vcs_info update-term-window-title )
  setopt prompt_subst
  zstyle ':vcs_info:git:*' formats "$bg[white]$fg[black]  %b %{$reset_color%}"
else
  precmd_functions+=( update-term-window-title )
fi

# prompt colors
[[ $(whoami) == 'root' ]] && USERHOSTCOLOR='magenta' || USERHOSTCOLOR='cyan'

# ssh session status in prompt
[ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] && SSHSTATUS="%{$bg[blue]$fg[black]%} SSH " || SSHSTATUS=''

# prompt
PS1="%{$bg[$USERHOSTCOLOR] $fg[black]%}%n@%M $SSHSTATUS%{$reset_color%}\$vcs_info_msg_0_%{$bg[white]$fg[black]%} %/ 
%{$reset_color$fg[$USERHOSTCOLOR]%}$%{$reset_color%} "
RPROMPT="%{$bg[black]$fg[white]%}%D{%L:%M:%S%p}%{$reset_color%}"
TMOUT=1
TRAPALRM() { zle reset-prompt }

# History in cache directory:
[ ! -f $HOME/.cache/zsh ] && mkdir -p $HOME/.cache/zsh && touch $HOME/.cache/zsh/history
HISTFILE=~/.cache/zsh/history
HISTSIZE=10000
SAVEHIST=10000

# function to fix corrupted zsh_history
fix-zsh-histfile() {
  mv $HISTFILE $HOME/.zsh-history-old
  strings $HOME/.zsh-history-old > $HISTFILE
  rm $HOME/.zsh-history-old
}

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
zle-keymap-select() {
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
    [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
  fi
}

# auto cd
setopt autocd

# Edit line in editor with ctrl-e:
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

# function to set correct .ssh persmissions
ssh-set-dir-permissions() {
  chmod 700 $HOME/.ssh
  chmod 600 $HOME/.ssh/*
  chmod 644 -f $HOME/.ssh/*.pub $HOME/.ssh/authorized_keys $HOME/.ssh/known_hosts
}

# use nvim as manpages pager
is-exec "nvim" && export MANPAGER="nvim +Man!" MANWIDTH=999

# alias
alias \
  mv='mv -iv' \
  cp='cp -riv' \
  rm='rm -vI' \
  mkdir='mkdir -pv' \
  tree='tree -CF' \
  bc='bc -ql' \
  nvim_nogit='nvim --cmd "let g:nogit=1"' \
  less="less -R" \
  diskspace="df -h | grep Filesystem; df -h | grep /dev/sd; df -h | grep @" \
  dmenu='setdmenu -l 8' \
  dotgit='git --git-dir=$HOME/.dotfiles-git/ --work-tree=$HOME' \
  myip='curl https://ipinfo.io/' \

if [[ $OSTYPE == "darwin"* ]] && [ ! -d /usr/local/opt/coreutils/libexec/gnubin ]; then
  echo "zshrc: GNU utils for macOS are not found (GNU util alias)"
else
  alias \
    ls='ls -hAFX --color=auto --group-directories-first --time-style=long-iso' \
    grep='grep --color=auto' \
    diff='diff --color=auto'
fi

# general user scripts
[ -d $HOME/scripts ] && PATH=$PATH:$HOME/scripts

# editor
if is-exec "nvim"; then; export EDITOR="nvim"
elif is-exec "vim"; then; export EDITOR="vim"
elif is-exec "vi"; then; export EDITOR="vi"
elif is-exec "nano"; then; export EDITOR="nano"; fi

# update terminal window title with relevant info
update-term-window-title() { echo -n "\033]0;${TERM} - ${USER}@${HOST} - ${PWD}\007" }
update-term-window-title

# bat settings
is-exec "bat" && export BAT_THEME="ansi" BAT_STYLE="plain"

# fzf options and completion
if is-exec "fzf"; then
  if is-exec "bat"; then
    export FZF_DEFAULT_OPTS="--tabstop=2 --cycle --color=dark --layout=reverse --preview 'bat --color=always --line-range=:500 {}'"
  else
    export FZF_DEFAULT_OPTS="--tabstop=4 --cycle --color=dark --height 50% --layout=reverse"
  fi

  if [ -f /usr/share/fzf/completion.zsh ]; then; source /usr/share/fzf/completion.zsh
  elif [ -f $HOME/.fzf/shell/completion.zsh ]; then; source $HOME/.fzf/shell/completion.zsh; fi
fi

# nvm
if [ -d $HOME/.nvm ]; then
  if [[ $OSTYPE == "darwin"* ]]; then
    [ -s /usr/local/opt/nvm/nvm.sh ] && . /usr/local/opt/nvm/nvm.sh
    [ -s /usr/local/opt/nvm/etc/bash_completion.d/nvm ] && . /usr/local/opt/nvm/etc/bash_completion.d/nvm
  else
    [ -s $HOME/.nvm/nvm.sh ] && . $HOME/.nvm/nvm.sh
    [ -s $HOME/.nvm/bash_completion ] && . $HOME/.nvm/bash_completion
  fi
  export NVM_DIR=$HOME/.nvm
fi

# updating zshrc
update-zshrc() {
  wget --no-cache -P $HOME/ https://raw.githubusercontent.com/andis-sprinkis/linux-user-config/master/.zshrc
  [ -f $HOME/.zshrc.1 ] && rm $HOME/.zshrc && mv $HOME/.zshrc.1 $HOME/.zshrc
}

# load zsh-syntax-highlighting; should be last
# arch, macos, debian
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null \
  || source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null \
  || source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
