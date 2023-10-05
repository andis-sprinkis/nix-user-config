# fn: detect if given command is executable
is_exec() { [ "$(command -v "$1")" ]; }

alias \
  bc="bc -ql" \
  cp="cp -rv" \
  date_iso8601="date -u +\"%Y-%m-%dT%H:%M:%SZ\"" \
  dirsize="ncdu -x" \
  diskspace="df -h" \
  dotgit_submodule_upgrade_latest_remote="dotgit submodule update --recursive --remote" \
  git_submodule_upgrade_latest_remote="git submodule update --recursive --remote" \
  h="tldr" \
  ip="ip --color=auto" \
  less="less -Ri" \
  mkdir="mkdir -pv" \
  mv="mv -v" \
  myip="curl https://ipinfo.io/" \
  py="python3 -q" \
  q="exit" \
  r="radian" \
  rm="rm -vI" \
  scan_smb="sudo nmap -sS -p 445 192.168.1.0/24" \
  scan_ssh="sudo nmap -sS -p 22 192.168.1.0/24" \
  tree="tree -CF" \
  wget=wget --hsts-file="${XDG_DATA_HOME:-$HOME/.local/share}/wget-hsts" \
  yay="yay --color=auto"

[[ ! "$OSTYPE" == "darwin"* ]] || [ "$HAS_BREW_GNUBIN" ] && {
  alias \
    diff="diff --color=auto" \
    grep="grep --color=auto" \
    ls="ls -xhAFNX --color=auto --group-directories-first --time-style=long-iso"
}

is_exec "nvim" && alias viff="nvim -d"
