() {
  # generic interactive shell configuration
  . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/interactive.sh"

  # inactivity timeout
  TMOUT="1600"

  # fn: detect if given command is executable
  is_exec() { [ "$(command -v "$1")" ] }

  # fn: set terminal emulator window title
  set_window_title() { echo -n "\033]0;${PWD}\007" }

  # fn: cursor shape for different vi modes
  echo_cur_beam() { echo -ne "\e[5 q" }
  echo_cur_block() { echo -ne "\e[1 q" }

  # fn: zle widgets
  zle-keymap-select() {
    case "$KEYMAP" in
      "vicmd") echo_cur_block;;
      "viins"|"main") echo_cur_beam;;
    esac
  }

  zle-line-init() { zle -K "viins" && echo_cur_beam }

  function expand_alias() {
    zle "_expand_alias"
    zle "self-insert"
  }

  zle -N "expand_alias"
  bindkey -M main " " "expand_alias"

  # fn: preexec
  preexec() {
    echo_cur_beam 

    # increase inactivity timeout
    TMOUT="5400"
  }

  # set window title
  set_window_title

  # store history
  HISTSIZE="1000000" SAVEHIST="1000000" HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"

  # zsh opts
  setopt "SHARE_HISTORY" "AUTOCD" "PROMPT_SUBST" "INTERACTIVE_COMMENTS"
  disable r

  # remember last dir
  autoload -Uz "chpwd_recent_dirs" "cdr" "add-zsh-hook"
  add-zsh-hook "chpwd" "chpwd_recent_dirs"
  zstyle ':chpwd:*' recent-dirs-file "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/chpwd-recent-dirs"

  # enable colors
  autoload -U "colors" && colors

  # fn: set RPROMPT prompt
  set_prompt_rprompt() { RPROMPT="($?) %D{%K:%M:%S}" }

  is_exec "git" && {
    # git-completion plugin
    fpath=($fpath "${XDG_DATA_HOME:-$HOME/.local/share}/git-completion/zsh")

    # precmd_functions
    autoload -Uz "vcs_info"
    precmd_functions+=("set_prompt_rprompt" "vcs_info" "set_window_title")
    zstyle ":vcs_info:git:*" "formats" "$bg[white]$fg[black]  %b "
  } || precmd_functions+=("set_prompt_rprompt" "set_window_title")

  # set PS1 prompt
  () {
    [[ "$(whoami)" == "root" ]] && local role_params=("magenta" "#") || local role_params=("cyan" "$")
    local userhost="%{$bg[$role_params[1]] $fg[black]%}%n@%M %{$reset_color%}"
    local ssh_status=$([ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] && echo "%{$bg[blue]$fg[black]%} SSH %{$reset_color%}")
    local vcs_info="\$vcs_info_msg_0_%{$reset_color%}"
    local cwd_path="%{$bg[white]$fg[black]%} %/ %{$reset_color%}"
    local prompt_symbol="%{$fg[$role_params[1]]%}$role_params[2]%{$reset_color%} "

    PS1="$userhost$ssh_status$vcs_info$cwd_path
$prompt_symbol"
  }

  # basic auto/tab complete
  setopt "GLOB_COMPLETE" "LIST_PACKED" "LIST_ROWS_FIRST" "LIST_TYPES"
  autoload -U "compinit"
  compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
  zstyle ':completion:*' "completer" "_expand_alias" "_complete" "_ignored"
  zstyle ':completion:*' "matcher-list" '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  zstyle ":completion:*" "menu" "select"
  zstyle ':completion:::::default' menu yes select
  zmodload "zsh/complist"
  _comp_options+=("globdots") # Include hidden files.

  # background pseudo-terminal mod. for applications that use it (e.g. nvim cmp-zsh)
  zmodload "zsh/zpty"

  # disable ctrl-s to freeze terminal
  stty "stop" "undef"

  # use vim keys in tab complete menu
  bindkey -M "menuselect" "h" "vi-backward-char"
  bindkey -M "menuselect" "k" "vi-up-line-or-history"
  bindkey -M "menuselect" "l" "vi-forward-char"
  bindkey -M "menuselect" "j" "vi-down-line-or-history"
  bindkey -M "menuselect" "^[[Z" "reverse-menu-complete"
  bindkey -v "^?" "backward-delete-char"

  # vi mode
  bindkey -v

  # cycle through history based on entered prefix
  autoload -U "history-search-end"
  zle -N "history-beginning-search-backward-end" "history-search-end"
  zle -N "history-beginning-search-forward-end" "history-search-end"
  bindkey "^[[A" "history-beginning-search-backward-end"
  bindkey "^[[B" "history-beginning-search-forward-end"

  # keytimeout
  export KEYTIMEOUT="1"

  # set zle widgets
  zle -N "zle-keymap-select"
  zle -N "zle-line-init"

  # edit line in editor with ctrl-e:
  autoload "edit-command-line"
  zle -N "edit-command-line"
  bindkey "^e" "edit-command-line"
  bindkey -a "^e" "edit-command-line"

  # configure fzf
  is_exec "fzf" && {
    local fzf_completion; for fzf_completion in \
      "/usr/share/fzf/completion.zsh" \
      "$BREW_DEFAULT_PATH/opt/fzf/shell/completion.zsh" \
      "$HOME/.fzf/shell/completion.zsh"
    do; [ -f "$fzf_completion" ] && . "$fzf_completion" && break; done

    bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'
    bindkey -M vicmd -s '^f' 'i^ucd "$(dirname "$(fzf)")"\n'
  }

  # list all shell options
  alias shopt="printf '%s=%s\n' \"\${(@kv)options}\""

  # source local zsh plugins
  . "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh"
  . "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
}
