alias \
  aunpack="aunpack --subdir --explain" \
  bc="bc -ql" \
  c="clear" \
  calc="qalc -c" \
  cp="cp -rv" \
  date_iso8601="date -u +\"%Y-%m-%dT%H:%M:%SZ\"" \
  dirsize="du -sch" \
  diskspace="df -h --output=\"target,pcent,size,used,avail,fstype,source\"" \
  dg="dotgit" \
  dgc="dotgit commit" \
  dgcm="dotgit commit --amend" \
  dgcmn="dotgit commit --amend --no-edit" \
  dgd="dotgit diff" \
  dgl="dotgit log" \
  dgpl="dotgit pull" \
  dgps="dotgit push" \
  dgs="dotgit status" \
  dgt="dotgit checkout" \
  dg_submodule_init="dotgit submodule update --init --recursive" \
  dg_submodule_upgrade_latest_remote="dotgit submodule update --recursive --remote" \
  e="$EDITOR" \
  g="git" \
  gc="git commit" \
  gcm="git commit --amend" \
  gcmn="git commit --amend --no-edit" \
  gd="git diff" \
  gl="git log" \
  gpl="git pull" \
  gps="git push" \
  gs="git status" \
  gt="git checkout" \
  g_submodule_init="git submodule update --init --recursive" \
  g_submodule_upgrade_latest_remote="git submodule update --recursive --remote" \
  h="tldr" \
  ip="ip --color=auto" \
  less="$PAGER" \
  mkdir="mkdir -pv" \
  mv="mv -v" \
  myip="curl https://ipinfo.io/" \
  ncdu="ncdu -x" \
  p="python3 -q" \
  q="exit" \
  qalc="qalc -c" \
  pacman="yay --color=auto" \
  r="radian" \
  rm="rm -vI" \
  rsync_progress="rsync --progress --human-readable --stats" \
  scan_http="sudo nmap -sS --open -p 80,447 192.168.1.0/24" \
  scan_smb="sudo nmap -sS --open -p 445 192.168.1.0/24" \
  scan_ssh="sudo nmap -sS --open -p 22 192.168.1.0/24" \
  tree="tree -CF" \
  viff="nvim -d" \
  wget="wget --hsts-file=\"${XDG_DATA_HOME:-$HOME/.local/share}/wget-hsts\"" \
  yay="yay --color=auto"

[[ ! "$OSTYPE" == "darwin"* ]] || [ "$HAS_BREW_GNUBIN" ] && {
  alias \
    diff="diff --color=auto" \
    grep="grep --color=auto" \
    ls="ls -xhAFNX --color=auto --group-directories-first --time-style=long-iso"
}
