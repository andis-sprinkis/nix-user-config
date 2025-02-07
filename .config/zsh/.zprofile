() {
  # fn: detect if given command is executable
  is_exec() { [ "$(command -v "$1")" ] }

  # configure pyenv
  if is_exec "pyenv"; then
    eval "$(pyenv init - zsh)"
  fi
}
