#!/usr/bin/env sh

() {
  # zmodload zsh/zprof

  # generic interactive shell configuration
  . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/interactive"

  # inactivity timeout
  TMOUT="1600"

  # fn: detect if given command is executable
  is_exec() {
    command -v "$1" 1>/dev/null 2>/dev/null
  }

  # fn: cursor shape for different vi modes
  case "$TERM" in
    "linux")
      echo_cur_block() {
        printf "\x1b\x5b?6;$((8+4+2+1));$((37+0+8+4+2+1))\x63"
      }

      echo_cur_beam() {
        printf "\x1b\x5b?2\x63"
      }
    ;;
    *)
      echo_cur_block() {
        echo -ne "\033[1 q"
      }

      echo_cur_beam() {
        echo -ne "\033[5 q"
      }
    ;;
  esac

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

  zle-line-init() {
    if zle -K "viins"; then
      echo_cur_beam
    fi
  }

  # expand alias in insert mode

  expand_alias() {
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

    timer="$(print -P %D{%s%3.})"
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
  autoload -Uz "colors" && colors

  # fn: set RPROMPT prompt
  set_prompt_rprompt() {
    local tmout_status=""
    if [ "${TMOUT:-""}" = "0" ]; then 
      tmout_status="TMOUT0 ";
    fi

    local timeprompt=""	
    if [ "${timer:-""}" ]; then
      local  now="$(print -P %D{%s%3.})"
      local d_ms="$((now - timer))"
      local  d_s="$((d_ms / 1000))"
      local   ms="$((d_ms % 1000))"
      local    s="$((d_s % 60))"
      local    m="$(((d_s / 60) % 60))"
      local    h="$((d_s / 3600))"

        if ((h > 0)); then timeprompt="${h}h${m}m${s}s"
      elif ((m > 0)); then timeprompt="${m}m${s}.$(printf $((ms / 100)))s" # 1m12.3s
      elif ((s > 9)); then timeprompt="${s}.$(printf %02d $((ms / 10)))s"  # 12.34s
      elif ((s > 0)); then timeprompt="${s}.$(printf %03d $ms)s"            # 1.234s
      else                 timeprompt="${ms}ms"
      fi

      unset timer
    fi

    RPROMPT="${tmout_status}%D{%K:%M:%S}${timeprompt:+" $timeprompt"} (\$?)"
  }

  # use homebrew site-functions
  if [ "${BREW_PREFIX:-""}" ] && [ -f "${BREW_PREFIX}/bin/brew" ]; then
    fpath[1,0]="${BREW_PREFIX}/share/zsh/site-functions"
  fi

  if is_exec "git"; then
    # git-completion plugin
    fpath=($fpath "${XDG_DATA_HOME:-$HOME/.local/share}/git-completion/zsh")

    # vcs_info git prompt
    autoload -Uz "vcs_info"
    zstyle ':vcs_info:*' enable git
    zstyle ":vcs_info:git:*" "formats" "$bg[white]$fg[black]  %b "

    precmd_functions+=("vcs_info")
  fi

  precmd_functions+=("set_prompt_rprompt" "set_window_title" prompt)

  # set PS1 prompt
  () {
    if [ "$USER" = "root" ]; then
      local role_params=("magenta" "#")
    else
      local role_params=("cyan" "$")
    fi

    local userhost="%{$bg[$role_params[1]] $fg[black]%}%n@%M %{$reset_color%}"

    local ssh_status
    if [ "${SSH_CONNECTION:-""}" ] || [ "${SSH_CLIENT:-""}" ] || [ "${SSH_TTY:-""}" ]; then
      ssh_status="%{$bg[blue]$fg[black]%} SSH %{$reset_color%}";
    fi

    local vcs_info="\$vcs_info_msg_0_%{$reset_color%}"
    local cwd_path="%{$bg[white]$fg[black]%} %/ %{$reset_color%}"
    local prompt_symbol="%{$fg[$role_params[1]]%}$role_params[2]%{$reset_color%} "

    PS1="$userhost$ssh_status$vcs_info$cwd_path
$prompt_symbol"
  }

  # basic auto/tab complete
  setopt "GLOB_COMPLETE" "LIST_PACKED" "LIST_ROWS_FIRST" "LIST_TYPES"

  autoload -Uz "compinit"

  local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"

  case "$(uname)" in
    "Darwin")
      if [ ! -f "$zcompdump" ] || [ "$(("$(LOCALE=C date +'%s')" - "$(LOCALE=C /usr/bin/stat -f '%m' "$zcompdump")"))" -gt "86400" ]; then
        compinit
      else
        compinit -C
      fi
    ;;
    *)
      if [ ! -f "$zcompdump" ] || [ "$(("$(LOCALE=C date +'%s')" - "$(LOCALE=C stat -c '%Y' "$zcompdump")"))" -gt "86400" ]; then
        compinit
      else
        compinit -C
      fi
    ;;
  esac

  # Execute code in the background to not affect the current session
  {
    # Compile zcompdump, if modified, to increase startup speed.
    if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
      zcompile "$zcompdump"
    fi
  } &!

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
  autoload -Uz "history-search-end"
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
  # if [ -f "${HOME}/.local/bin/tldr" ]; then
  #   compctl -k "($(tldr 2>/dev/null --list))" "tldr"
  # fi

  # configure fzf
  if is_exec "fzf"; then
    local fzf_completion
    for fzf_completion in \
      "/usr/share/fzf/completion.zsh" \
      "${BREW_PREFIX:+"${BREW_PREFIX}/opt/fzf/shell/completion.zsh"}" \
      "${HOME}/.fzf/shell/completion.zsh"
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

    fzf_search_history() {
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

  export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/pyenv/shims:${PATH}"
  export PYENV_SHELL="zsh"

  if [ -f "${BREW_PREFIX:+"${BREW_PREFIX}/opt/pyenv/completions/pyenv.zsh"}" ]; then
    . "/opt/homebrew/opt/pyenv/completions/pyenv.zsh"
  fi

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
