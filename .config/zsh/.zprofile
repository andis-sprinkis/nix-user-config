# fn: detect if given command is executable
is_exec() { [ "$(command -v "$1")" ]; }

#!/usr/bin/env sh

# configure pyenv
if is_exec "pyenv"; then
  eval "$(pyenv init - zsh)"
fi
