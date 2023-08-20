# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# generic interactive shell configuration
. "${XDG_CONFIG_HOME:-$HOME/.config}/shell/interactive.sh"

PS1='[\u@\h \W]\$ '

export HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/bash/history"
