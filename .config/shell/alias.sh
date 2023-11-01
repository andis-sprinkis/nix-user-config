# fn: detect if given command is executable
is_exec() { [ "$(command -v "$1")" ]; }

alias \
  bc="bc -ql" \
  c="clear" \
  cp="cp -rv" \
  date_iso8601="date -u +\"%Y-%m-%dT%H:%M:%SZ\"" \
  dirsize="ncdu -x" \
  diskspace="df -h --output=\"target,pcent,size,used,avail,fstype,source\"" \
  dg="dotgit" \
  dgc="dotgit commit" \
  dgca="dotgit commit --amend" \
  dgcan="dotgit commit --amend --no-edit" \
  dgl="dotgit log" \
  dgp="dotgit pull" \
  dgs="dotgit status" \
  dgt="dotgit checkout" \
  dg_submodule_init="dotgit submodule update --init --recursive" \
  dg_submodule_upgrade_latest_remote="dotgit submodule update --recursive --remote" \
  e="$EDITOR" \
  g="git" \
  gc="git commit" \
  gca="git commit --amend" \
  gcan="git commit --amend --no-edit" \
  dgs="dotgit status" \
  gl="git log" \
  gp="git pull" \
  gs="git status" \
  gt="git checkout" \
  g_submodule_init="git submodule update --init --recursive" \
  g_submodule_upgrade_latest_remote="git submodule update --recursive --remote" \
  h="tldr" \
  ip="ip --color=auto" \
  less="less -Ri" \
  mkdir="mkdir -pv" \
  mv="mv -v" \
  myip="curl https://ipinfo.io/" \
  p="python3 -q" \
  q="exit" \
  r="radian" \
  rm="rm -vI" \
  rsync_progress="rsync --progress --human-readable --stats" \
  scan_http="sudo nmap -sS -p 80,447 192.168.1.0/24" \
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
