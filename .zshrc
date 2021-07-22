# source user local .profile
[ -f $HOME/.profile ] && . $HOME/.profile

# use user local PATHs
[ -d $HOME/.local/bin ] && PATH=$HOME/.local/bin:$PATH
[ -d $HOME/scripts ] && PATH=$PATH:$HOME/scripts

# use the GNU utils on macOS
if [[ $OSTYPE == "darwin"* ]]; then
  [ -d /usr/local/opt/coreutils/libexec/gnubin ] && PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"
  [ -d /usr/local/opt/coreutils/libexec/gnuman ] && export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:${MANPATH}"
fi

# fn: detect if given command is executable
is-exec() { if command="$(type -p "$1")" || [[ -z $command ]] && return 0; return 1 }

# fn: fetch updated .zshrc
update-zshrc() {
  wget --no-cache -P $HOME/ https://raw.githubusercontent.com/andis-sprinkis/linux-user-config/master/.zshrc
  [ -f $HOME/.zshrc.1 ] && rm $HOME/.zshrc && mv $HOME/.zshrc.1 $HOME/.zshrc
}

# fn: use lf for changing directory
lfcd() {
  tmp="$(mktemp)"
  if [ -f "$tmp" ]; then
    lf -last-dir-path="$tmp" "$@"
    dir="$(cat "$tmp")"
    rm -f "$tmp"
    [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
  fi
}

# fn: set correct .ssh persmissions
ssh-set-dir-permissions() {
  chmod 700 $HOME/.ssh
  chmod 600 $HOME/.ssh/*
  chmod 644 -f $HOME/.ssh/*.pub $HOME/.ssh/authorized_keys $HOME/.ssh/known_hosts
}

# fn: set terminal emulator window title
update-term-window-title() { echo -n "\033]0;${TERM} - ${USER}@${HOST} - ${PWD}\007" }

# fn: fix corrupted history file
fix-zsh-histfile() {
  mv $HISTFILE $HOME/.zsh-history-old
  strings $HOME/.zsh-history-old > $HISTFILE
  rm $HOME/.zsh-history-old
}

# set terminal emulator window title
update-term-window-title

# enable colors
autoload -U colors && colors

# remember and cd to last dir
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
cdr

# comments in interactive mode
setopt interactive_comments

# display git status
if is-exec "git"; then
  autoload -Uz vcs_info
  precmd_vcs_info() { vcs_info }
  precmd_functions+=( precmd_vcs_info update-term-window-title )
  setopt prompt_subst
  zstyle ':vcs_info:git:*' formats "$bg[white]$fg[black]  %b %{$reset_color%}"
else
  precmd_functions+=( update-term-window-title )
fi

# prompt: set color for host in prompt depending if root or not
[[ $(whoami) == 'root' ]] && USERHOSTCOLOR='magenta' || USERHOSTCOLOR='cyan'

# prompt: display ssh session status
[ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] && SSHSTATUS="%{$bg[blue]$fg[black]%} SSH " || SSHSTATUS=''

# prompt
setopt promptsubst
left='%m | %~'
PS1="%{$bg[$USERHOSTCOLOR] $fg[black]%}%n@%M $SSHSTATUS%{$reset_color%}\$vcs_info_msg_0_%{$bg[white]$fg[black]%} %/ 
%{$reset_color$fg[$USERHOSTCOLOR]%}$%{$reset_color%} "
RPROMPT="%{$reset_color%}%D{%K:%M:%S}"
# TMOUT=1
# TRAPALRM() { zle reset-prompt } # reset prompt every TMOUT

# store history
[ ! -f $HOME/.cache/zsh ] && mkdir -p $HOME/.cache/zsh && touch $HOME/.cache/zsh/history
HISTSIZE=10000 SAVEHIST=10000 HISTFILE=$HOME/.cache/zsh/history 

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

# change cursor shape for different vi modes.
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

# auto cd
setopt autocd

# edit line in editor with ctrl-e:
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

# use nvim as man-pager
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
  myip='curl https://ipinfo.io/'

if [[ $OSTYPE == "darwin"* ]] && [ ! -d /usr/local/opt/coreutils/libexec/gnubin ]; then
  echo "zshrc: GNU utils for macOS are not found (GNU util alias)"
else
  alias \
    ls='ls -hAFX --color=auto --group-directories-first --time-style=long-iso' \
    grep='grep --color=auto' \
    diff='diff --color=auto'
fi

# set EDITOR
if is-exec "nvim"; then; export EDITOR="nvim"
elif is-exec "vim"; then; export EDITOR="vim"
elif is-exec "vi"; then; export EDITOR="vi"
elif is-exec "nano"; then; export EDITOR="nano"; fi

# configure bat
is-exec "bat" && export BAT_THEME="ansi" BAT_STYLE="plain"

# configure fzf
if is-exec "fzf"; then
  is-exec "bat" && export FZF_DEFAULT_OPTS="--tabstop=2 --cycle --color=dark --layout=reverse --preview 'bat --color=always --line-range=:500 {}'" \
    || export FZF_DEFAULT_OPTS="--tabstop=4 --cycle --color=dark --height 50% --layout=reverse"

  if [ -f /usr/share/fzf/completion.zsh ]; then; . /usr/share/fzf/completion.zsh
  elif [ -f $HOME/.fzf/shell/completion.zsh ]; then; . $HOME/.fzf/shell/completion.zsh; fi
fi

# initialize nvm
if [ -s /usr/local/opt/nvm/nvm.sh ]; then; . /usr/local/opt/nvm/nvm.sh
elif [ -s $HOME/.nvm/nvm.sh ]; then; . $HOME/.nvm/nvm.sh; fi

if [ -s /usr/local/opt/nvm/etc/bash_completion.d/nvm ]; then; . /usr/local/opt/nvm/etc/bash_completion.d/nvm
elif [ -s $HOME/.nvm/bash_completion ]; then; . $HOME/.nvm/bash_completion; fi

[ -d $HOME/.nvm ] && export NVM_DIR=$HOME/.nvm

# load zsh-syntax-highlighting (should be last)
# per platform: arch, macos, debian
. /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null \
  || . /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null \
  || . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
