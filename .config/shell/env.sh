# fn: detect if given command is executable
is_exec() { [ "$(command -v "$1")" ]; }

main() {
  # initialize homebrew
  [ -f "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"

  # default macOS homebrew dir. path
  export BREW_DEFAULT_PATH="/opt/homebrew"

  # determine if GNU utilities have been installed with homebrew
  [ -d "$BREW_DEFAULT_PATH/opt/coreutils/libexec/gnubin" ] && export HAS_BREW_GNUBIN="1"

  # use the GNU utils on macOS
  [ "$HAS_BREW_GNUBIN" ] && {
    PATH="$BREW_DEFAULT_PATH/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="$BREW_DEFAULT_PATH/opt/coreutils/libexec/gnuman:$MANPATH"
  }

  # XDG base directories
  export XDG_CACHE_HOME="$HOME/.cache"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_DATA_HOME="$HOME/.local/share"
  export XDG_STATE_HOME="$HOME/.local/state"

  # local bin PATH
  PATH="$HOME/.local/bin:$PATH"

  # set language
  [ "$LANG" ] || export LANG='en_US.UTF-8'

  # set PAGER
  export PAGER="less -Ri"

  # set TERMINAL
  export TERMINAL="kitty --single-instance"

  is_exec "nvim" && {
    # configure nvim as EDITOR, MANPAGER
    export EDITOR="nvim"
    export MANPAGER="nvim +Man!"
  } || {
    # or set a different avail. EDITOR
    local editor
    for editor in "vim" "vi" "nano"; do
      is_exec "$editor" && export EDITOR="$editor" && break
    done
  }

  # configure X11
  export XINITRC="${XDG_CONFIG_HOME:-$HOME/.config}/x11/xinitrc"
  export XAUTHORITY="$XDG_RUNTIME_DIR/xauthority"

  # configure GTK 2.0
  export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc"

  # configure Qt
  export QT_STYLE_OVERRIDE="adwaita-dark"

  # configure GNU readline
  export INPUTRC="${XDG_CONFIG_HOME:-$HOME/.config}/readline/inputrc"

  # configure GNU screen
  export SCREENRC="${XDG_CONFIG_HOME:-$HOME/.config}/screen/screenrc"

  # configure node
  export NODE_REPL_HISTORY="${XDG_CACHE_HOME:-$HOME/.cache}/node/repl_history"

  # configure python
  export PYTHONSTARTUP="${XDG_CONFIG_HOME:-$HOME/.config}/python/pythonrc.py"

  # configure ipython
  export IPYTHONDIR="${XDG_CONFIG_HOME:-$HOME/.config}/ipython"

  # configure pyenv
  export PYENV_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/pyenv"

  # configure jupyter
  export JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/jupyter"

  # configure keras
  export KERAS_HOME="${XDG_STATE_HOME:-$HOME/.local/state}/keras"

  # configure less
  export LESSHISTFILE="-"

  # configure go
  export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"

  # configure cargo
  export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
  PATH="$CARGO_HOME/bin:$PATH"

  # configure volta
  export VOLTA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/volta"
  PATH="$VOLTA_HOME/bin:$PATH"

  # configure homebrew
  export HOMEBREW_NO_ANALYTICS="1"
  export HOMEBREW_NO_EMOJI="1"

  # configure zsh
  export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
}

main
