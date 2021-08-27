# fn: detect if given command is executable
is-exec() { if command="$(command -v "$1")" || [[ -z $command ]] && return 0; return 1 }

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

# fn: fix corrupted history file
fix-zsh-histfile() {
  mv $HISTFILE $HOME/.zsh-history-old
  strings $HOME/.zsh-history-old > $HISTFILE
  rm $HOME/.zsh-history-old
}

# fn: set terminal emulator window title
update-window-title() { echo -n "\033]0;${TERM} - ${USER}@${HOST} - ${PWD}\007" }

# fn: cursor shape for different vi modes
echo-cur-beam() { echo -ne '\e[5 q' }
echo-cur-block() { echo -ne '\e[1 q' }

# fn: zle widgets
zle-keymap-select() {
  case $KEYMAP in
    vicmd) echo-cur-block;;
    viins|main|.safe) echo-cur-beam;;
  esac
}
zle-line-init() { zle -K viins && echo-cur-beam }

# fn: preexec
preexec() { echo-cur-beam }

# source .local_profile
[ -f $HOME/.local_profile ] && . $HOME/.local_profile

# use user local PATHs
[ -d $HOME/.local/bin ] && PATH=$HOME/.local/bin:$PATH
[ -d $HOME/scripts ] && PATH=$PATH:$HOME/scripts

# use the GNU utils on macOS
if [[ $OSTYPE == "darwin"* ]]; then
  [ -d /usr/local/opt/coreutils/libexec/gnubin ] && PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"
  [ -d /usr/local/opt/coreutils/libexec/gnuman ] && export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:${MANPATH}"
fi

# store history
[ ! -f $HOME/.cache/zsh ] && mkdir -p $HOME/.cache/zsh && touch $HOME/.cache/zsh/history && echo $HOME >> $HOME/.cache/zsh/history
HISTSIZE=10000 SAVEHIST=10000 HISTFILE=$HOME/.cache/zsh/history 

# remember last dir 
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# cd to last dir
cdr 

# set window title
update-window-title 

# enable colors
autoload -U colors && colors 

# precmd_functions
if is-exec "git"; then
  autoload -Uz vcs_info
  precmd_functions+=( vcs_info update-window-title )
  zstyle ':vcs_info:git:*' formats "$bg[white]$fg[black]  %b "
else
  precmd_functions+=( update-window-title )
fi

# prompt substitution
setopt promptsubst

# prompt: PS1
userhost="%{$bg[$([[ $(whoami) == 'root' ]] && echo 'magenta' || echo 'cyan')] $fg[black]%}%n@%M %{$reset_color%}"
ssh_status=$([ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] && echo "%{$bg[blue]$fg[black]%} SSH %{$reset_color%}")
vcs_info="\$vcs_info_msg_0_%{$reset_color%}"
cwd_path="%{$bg[white]$fg[black]%} %/ %{$reset_color%}"
prompt_symbol="
$([[ $(whoami) == 'root' ]] && echo "%{$fg[magenta]%}#" || echo "%{$fg[cyan]%}$")%{$reset_color%} "
PS1="$userhost$ssh_status$vcs_info$cwd_path$prompt_symbol"

# prompt: RPROMPT
timestamp="%D{%K:%M:%S}"
RPROMPT="$timestamp"

# comments in interactive mode
setopt interactive_comments 

# basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files.

# use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# vi mode
bindkey -v
export KEYTIMEOUT=1

# set zle widgets
zle -N zle-keymap-select
zle -N zle-line-init

# edit line in editor with ctrl-e:
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

# auto cd
setopt autocd

# use nvim as man-pager
is-exec "nvim" && export MANPAGER="nvim +Man!" MANWIDTH=999

# alias
alias \
  mv='mv -v' \
  cp='cp -rv' \
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
for editor in "nvim" "vim" "vi" "nano"; do; is-exec $editor && export EDITOR=$editor && break; done

# configure bat
is-exec "bat" && export BAT_THEME="ansi" BAT_STYLE="plain"

# configure fzf
if is-exec "fzf"; then
  is-exec "bat" && export FZF_DEFAULT_OPTS="--tabstop=2 --cycle --color=dark --layout=reverse --preview 'bat --color=always --line-range=:500 {}'" \
    || export FZF_DEFAULT_OPTS="--tabstop=4 --cycle --color=dark --height 50% --layout=reverse"

  for fzf_completion in \
    /usr/share/fzf/completion.zsh \
    $HOME/.fzf/shell/completion.zsh
  do; if [ -f $fzf_completion ]; then; . $fzf_completion; break; fi; done
fi

# initialize nvm
for nvm_sh in \
  /usr/share/nvm/nvm.sh \
  /usr/local/opt/nvm/nvm.sh \
  $HOME/.nvm/nvm.sh
do; if [ -f $nvm_sh ]; then
  . $nvm_sh
  [ ! -d $HOME/.nvm ] && mkdir -p $HOME/.nvm
  export NVM_DIR=$HOME/.nvm
break; fi; done

for nvm_bash_completion in \
  /usr/share/nvm/bash_completion \
  /usr/local/opt/nvm/etc/bash_completion.d/nvm \
  $HOME/.nvm/bash_completion
do; if [ -f $nvm_bash_completion ]; then; . $nvm_bash_completion; break; fi; done

# load zsh-syntax-highlighting (should be last)
# per platform: arch, macos, debian
for zsh_highlighting_init in \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
do; if [ -f $zsh_highlighting_init ]; then; . $zsh_highlighting_init; break; fi; done
