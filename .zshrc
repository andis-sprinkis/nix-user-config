# Based on "Luke's config for the Zoomer Shell"

# Enable colors and change prompt:
autoload -U colors && colors

# -------------------------

# remember last dir
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# -------------------------

# git

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info update-term-window-title )
setopt prompt_subst
zstyle ':vcs_info:git:*' formats "$bg[white]$fg[black]  %b %{$reset_color%}"

# prompt

PS1="%{$bg[cyan] $fg[black]%}%n@%M %{$reset_color%}\$vcs_info_msg_0_%{$bg[white]$fg[black]%} %/ 
%{$reset_color$fg[cyan]%}$%{$reset_color%} "

# -------------------------

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# -------------------------

setopt  autocd

source $HOME/ssh-cmd
source $HOME/smb-cmd

alias l='lf'
alias ls='ls -haNF --color=auto --group-directories-first'
alias mkdir='mkdir -p'
alias v='nvim'
alias vim='nvim'
alias rss='newsboat'
alias dmenu='setdmenu'

alias dotgit='/usr/bin/git --git-dir=$HOME/.dotfiles-git/ --work-tree=$HOME'

export USERSCRIPTS="$HOME/scripts"
export I3WMSCRIPTS="$HOME/.config/i3/scripts"
export PATH=$PATH:$USERSCRIPTS:$I3WMSCRIPTS
export EDITOR="nvim"

export FZF_DEFAULT_OPTS="--tabstop=4 --cycle --color bw --height 50% --layout=reverse"

# update terminal window title with relevant info

function update-term-window-title {
    echo -n "\033]0;st - ${USER}@${HOST} - ${PWD}\007"
}
update-term-window-title

# -------------------------
# 

# Load zsh-syntax-highlighting; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
