#!/usr/bin/env sh

() {
  # generic shell environment configuration
  . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env"

  # fn: detect if given command is executable
  is_exec() { [ "$(command -v "$1")" ]; }

  # configure pyenv
  export PYENV_SHELL="zsh"
}
