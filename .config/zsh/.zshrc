#!/usr/bin/env sh

() {
  # zmodload zsh/zprof

  # generic interactive shell configuration
  . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/interactive"

  # inactivity timeout
  TMOUT="1600"

  # fn: cursor shape for different vi modes
  case "$TERM" in
    "linux")
      # cur_block="\x1b\x5b?6;$((8+4+2+1));$((37+0+8+4+2+1))\x63"
      cur_block="\x1b\x5b?6;15;52\x63"
      cur_beam="\x1b\x5b?2\x63"
    ;;
    *)
      cur_block="\033[1 q"
      cur_beam="\033[5 q"
    ;;
  esac

  # fn: set terminal emulator window title
  set_window_title() {
    printf "\033]0;%s\007" "$PWD"
  }

  # fn: zle widgets
  zle-keymap-select() {
    case "$KEYMAP" in
      "vicmd")
        echo -n "$cur_block"
      ;;
      "viins"|"main")
        echo -n "$cur_beam"
      ;;
    esac
  }

  zle-line-init() {
    if zle -K "viins"; then
      echo -n "$cur_beam"
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

    timer="$(print -P "%D{%s%3.}")"
  }

  # history file length in lines
  export SAVEHIST="500"

  # zsh opts
  setopt "SHARE_HISTORY" "APPEND_HISTORY" "HIST_EXPIRE_DUPS_FIRST" "AUTOCD" "PROMPT_SUBST" "INTERACTIVE_COMMENTS"
  disable "r"

  # remember last dir
  autoload -Uz "chpwd_recent_dirs" "cdr" "add-zsh-hook"
  add-zsh-hook "chpwd" "chpwd_recent_dirs"
  zstyle ':chpwd:*' "recent-dirs-file" "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/chpwd-recent-dirs"

  # enable colors
  autoload -Uz "colors" && colors

  # fn: set RPROMPT prompt
  set_rprompt() {
    local tmout_status=""
    if [ "${TMOUT:-""}" = "0" ]; then
      tmout_status="TMOUT0 ";
    fi

    local timeprompt=""
    if [ "${timer:-""}" ]; then
      local  now="$(print -P "%D{%s%3.}")"
      local d_ms="$((now - timer))"
      local  d_s="$((d_ms / 1000))"
      local   ms="$((d_ms % 1000))"
      local    s="$((d_s % 60))"
      local    m="$(((d_s / 60) % 60))"
      local    h="$((d_s / 3600))"

        if ((h > 0)); then timeprompt="${h}h ${m}m ${s}s "                     # 1h 1m 1s
      elif ((m > 0)); then timeprompt="${m}m ${s}.$(printf "$((ms / 100))")s " # 1m 12.3s
      elif ((s > 9)); then timeprompt="${s}.$(printf "%02d" "$((ms / 10))")s " # 12.34s
      elif ((s > 0)); then timeprompt="${s}.$(printf "%03d" "$ms")s "          # 1.234s
      else                 timeprompt="${ms}ms "                               # 1ms
      fi

      unset timer
    fi

    RPROMPT="%F{8}${tmout_status}${timeprompt}%D{%K:%M:%S}%(?.. %F{1}(%?%))%f%F{3}%(1j. [%j].)"
  }

  ZLE_RPROMPT_INDENT="0"

  # use homebrew site-functions
  if [ "${BREW_PREFIX:-""}" ] && [ -f "${BREW_PREFIX}/bin/brew" ]; then
    fpath[1,0]="${BREW_PREFIX}/share/zsh/site-functions"
  fi
 
  if command -v "git" 1>/dev/null 2>/dev/null; then
    # git-completion plugin
    fpath=($fpath "${XDG_DATA_HOME:-$HOME/.local/share}/git-completion/zsh")

    # vcs_info git prompt
    autoload -Uz "vcs_info"
    zstyle ':vcs_info:*' enable git
    zstyle ":vcs_info:git:*" "formats" "$bg[white]$fg[black]  %b "

    precmd_functions+=("vcs_info")
  fi

  precmd_functions+=("set_window_title" "set_rprompt")

  # set PROMPT (PS1) prompt
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

  PROMPT="$userhost$ssh_status$vcs_info$cwd_path
$prompt_symbol"

  # auto/tab completion
  setopt "GLOB_COMPLETE" "LIST_PACKED" "LIST_ROWS_FIRST" "LIST_TYPES"

  autoload -Uz "compinit"

  local zcompdump="${ZDOTDIR:-"$HOME"}/.zcompdump"
  local zcompdump_age_max_s="172800"
  # 24h = 86400s
  #  1h =  3600s

  case "$OSTYPE" in
    "darwin"*)
      if
        [ ! -f "$zcompdump" ] || [ "$(("$(LOCALE=C date +'%s')" - "$(LOCALE=C /usr/bin/stat -f '%m' "$zcompdump")"))" -gt "$zcompdump_age_max_s" ]
      then
        compinit
      else
        compinit -C
      fi
    ;;
    *)
      if
        [ ! -f "$zcompdump" ] || [ "$(("$(LOCALE=C date +'%s')" - "$(LOCALE=C stat -c '%Y' "$zcompdump")"))" -gt "$zcompdump_age_max_s" ]
      then
        compinit
      else
        compinit -C
      fi
    ;;
  esac

  {
    # compile zcompdump, if modified, to increase startup speed.
    if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
      zcompile "$zcompdump"
    fi
  } &! # execute code in the background to not affect the current session

  zstyle -e ':completion:*:default' 'list-colors' 'BASE_OF_PREFIX="${PREFIX##*/}" && reply=("${BASE_OF_PREFIX:+=(#b)($BASE_OF_PREFIX)(*)=0=1;35=0}:$LS_COLORS")'
  zstyle ':completion:*' 'completer' '_expand_alias' '_complete' '_approximate' '_ignored'
  zstyle ':completion:*' 'matcher-list' '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  zstyle ':completion:*' 'menu' 'yes' 'select'
  zstyle ':completion:*:descriptions' 'format' '%F{8}%d:%f'
  zmodload "zsh/complist"
  _comp_options+=("globdots") # include hidden files

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
  bindkey '^[^M' "self-insert-unmeta"

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
  if command -v "fzf" 1>/dev/null 2>/dev/null; then
    local fzf_completion
    for fzf_completion in \
      "/usr/share/fzf/completion.zsh" \
      "${BREW_PREFIX:+"${BREW_PREFIX}/opt/fzf/shell/completion.zsh"}"
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
      BUFFER="$(fc -l -n "1" | uniq | fzf --no-preview --tac --query "$LBUFFER")"
      CURSOR="$#BUFFER"
      zle "reset-prompt"
    }

    zle -N "fzf_search_history"
    bindkey "^k" "fzf_search_history"
  fi

  if [ -f "${BREW_PREFIX:+"${BREW_PREFIX}/opt/pyenv/completions/pyenv.zsh"}" ]; then
    . "/opt/homebrew/opt/pyenv/completions/pyenv.zsh"
  fi

  # configure zsh-system-clipboard
  unset ZSH_SYSTEM_CLIPBOARD_METHOD

  case "$OSTYPE" in
    "linux"*)
      if [ "$UID" -ge "1000" ]; then
        if [ "${DISPLAY:-""}" ] && [ -z "${WAYLAND_DISPLAY:-""}" ]; then
          export ZSH_SYSTEM_CLIPBOARD_METHOD="xcc"
        elif [ "${WAYLAND_DISPLAY:-""}" ]; then
          export ZSH_SYSTEM_CLIPBOARD_METHOD="wlc"
        elif [ "${TMUX:-""}" ]; then
          export ZSH_SYSTEM_CLIPBOARD_METHOD="tmux"
        fi
      else
        if [ "${TMUX:-""}" ]; then
          export ZSH_SYSTEM_CLIPBOARD_METHOD="tmux"
        fi
      fi

      if [ "${ZSH_SYSTEM_CLIPBOARD_METHOD:-""}" ]; then
        if [ "${TMUX:-""}" ]; then
          export ZSH_SYSTEM_CLIPBOARD_TMUX_SUPPORT="true"
        fi

        . "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh"
      fi
    ;;
    *)
      if [ "${TMUX:-""}" ]; then
        export ZSH_SYSTEM_CLIPBOARD_TMUX_SUPPORT="true"
      fi

      . "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh"
    ;;
  esac

  . "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
}

#compdef pnpm
###-begin-pnpm-completion-###
if type compdef &>/dev/null; then
  _pnpm_completion () {
    local reply
    local si=$IFS

    IFS=$'\n' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" SHELL=zsh pnpm completion-server -- "${words[@]}"))
    IFS=$si

    if [ "$reply" = "__tabtab_complete_files__" ]; then
      _files
    else
      _describe 'values' reply
    fi
  }
  # When called by the Zsh completion system, this will end with
  # "loadautofunc" when initially autoloaded and "shfunc" later on, otherwise,
  # the script was "eval"-ed so use "compdef" to register it with the
  # completion system
  if [[ $zsh_eval_context == *func ]]; then
    _pnpm_completion "$@"
  else
    compdef _pnpm_completion pnpm
  fi
fi
###-end-pnpm-completion-###
