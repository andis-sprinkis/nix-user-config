#!/usr/bin/env sh

() {
  # generic interactive shell configuration
  . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/interactive"

  # inactivity timeout
  TMOUT="1600"

  # fn: detect if given command is executable
  is_exec() { [ "$(command -v "$1")" ] }

  # fn: cursor shape for different vi modes
  echo_cur_beam() {
    case "$TERM" in
      "linux")
        printf "\x1b\x5b?2\x63"
      ;;
      *)
        echo -ne "\033[5 q"
      ;;
    esac
  }

  echo_cur_block() {
    case "$TERM" in
      "linux")
        printf "\x1b\x5b?6;$((8+4+2+1));$((37+0+8+4+2+1))\x63"
      ;;
      *)
        echo -ne "\033[1 q"
      ;;
    esac
  }

  # fn: zle widgets
  zle-keymap-select() {
    case "$KEYMAP" in
      "vicmd")
        echo_cur_block
      ;;
      "viins"|"main")
        echo_cur_beam
      ;;
    esac
  }

  zle-line-init() { zle -K "viins" && echo_cur_beam }

  # expand alias in insert mode

  function expand_alias() {
    zle "_expand_alias"
    zle "self-insert"
  }

  zle -N "expand_alias"
  bindkey -M main " " "expand_alias"

  # fn: preexec
  preexec() {
    # increase inactivity timeout
    if [ "${TMOUT:-""}" != "0" ]; then
      TMOUT="5400"
    fi
  }

  # history file length in lines
  export SAVEHIST="500"

  # zsh opts
  setopt "SHARE_HISTORY" "AUTOCD" "PROMPT_SUBST" "INTERACTIVE_COMMENTS"
  disable "r"

  # remember last dir
  autoload -Uz "chpwd_recent_dirs" "cdr" "add-zsh-hook"
  add-zsh-hook "chpwd" "chpwd_recent_dirs"
  zstyle ':chpwd:*' "recent-dirs-file" "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/chpwd-recent-dirs"

  # enable colors
  autoload -U "colors" && colors

  # fn: set RPROMPT prompt
  set_prompt_rprompt() {
    local tmout_status=""
    if [ "${TMOUT:-""}" = "0" ]; then 
      tmout_status="TMOUT0 ";
    fi

    RPROMPT="${tmout_status}(\$?) %D{%K:%M:%S}"
  }

  # use homebrew site-functions
  if [ "${BREW_PREFIX:-""}" ] && [ -f "${BREW_PREFIX}/bin/brew" ]; then
    fpath[1,0]="${BREW_PREFIX}/share/zsh/site-functions"
  fi

  if is_exec "git"; then
    # git-completion plugin
    fpath=($fpath "${XDG_DATA_HOME:-$HOME/.local/share}/git-completion/zsh")

    # precmd_functions
    autoload -Uz "vcs_info"
    precmd_functions+=("set_prompt_rprompt" "vcs_info" "set_window_title")
    zstyle ":vcs_info:git:*" "formats" "$bg[white]$fg[black]  %b "
  else 
    precmd_functions+=("set_prompt_rprompt" "set_window_title")
  fi

  # set PS1 prompt
  () {
    if [ "$USER" = "root" ]; then
      local role_params=("magenta" "#")
    else
      local role_params=("cyan" "$")
    fi

    local userhost="%{$bg[$role_params[1]] $fg[black]%}%n@%M %{$reset_color%}"

    local ssh_status="$(
      if [ "${SSH_CONNECTION:-""}" ] || [ "${SSH_CLIENT:-""}" ] || [ "${SSH_TTY:-""}" ]; then
        echo "%{$bg[blue]$fg[black]%} SSH %{$reset_color%}";
      fi
    )"

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

  # use vim keys in tab complete menu
  bindkey -M "menuselect" "h" "vi-backward-char"
  bindkey -M "menuselect" "k" "vi-up-line-or-history"
  bindkey -M "menuselect" "l" "vi-forward-char"
  bindkey -M "menuselect" "j" "vi-down-line-or-history"
  bindkey -M "menuselect" "^[[Z" "reverse-menu-complete"
  bindkey -v "^?" "backward-delete-char"

  # vi mode
  bindkey -v

  # use alt-enter to enter a new line in insert mode
  bindkey '^[^M' self-insert-unmeta

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

  # edit line in editor
  autoload "edit-command-line"
  zle -N "edit-command-line"
  bindkey "^e" "edit-command-line"
  bindkey -a "^e" "edit-command-line"

  # configure tldr
  if [ -f "$HOME/.local/bin/tldr" ]; then
    compctl -k "($(tldr 2>/dev/null --list))" "tldr"
  fi

  # configure fzf
  if is_exec "fzf"; then
    local fzf_completion
    for fzf_completion in \
      "/usr/share/fzf/completion.zsh" \
      "$BREW_PREFIX/opt/fzf/shell/completion.zsh" \
      "$HOME/.fzf/shell/completion.zsh"
    do
      if [ -f "$fzf_completion" ]; then
        . "$fzf_completion"
        break
      fi
    done

    # cd with fzf

    bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'
    bindkey -M vicmd -s '^f' 'i^ucd "$(dirname "$(fzf)")"\n'

    # search history with fzf

    function fzf_search_history() {
      BUFFER=$(fc -l -n "1" | uniq | fzf --no-preview --tac --query "$LBUFFER")
      CURSOR="$#BUFFER"
      zle "reset-prompt"
    }

    zle -N "fzf_search_history"
    bindkey "^k" "fzf_search_history"
  fi

  # configure pyenv

  # if is_exec "pyenv"; then
  #   eval "$(pyenv init - zsh)"
  # fi

  export PATH="/home/usr0/.local/share/pyenv/shims:${PATH}"
  export PYENV_SHELL="zsh"

  pyenv() {
    local command="${1:-""}"

    if [ "$#" -gt 0 ]; then
      shift
    fi

    case "$command" in
      "rehash"|"shell")
        eval "$(pyenv "sh-$command" "$@")"
      ;;
      *)
        command pyenv "$command" "$@"
      ;;
    esac
  }

  # source local zsh plugins
  . "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh"
  . "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
}
