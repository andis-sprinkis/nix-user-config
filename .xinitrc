#!/usr/bin/env sh

VBoxClient-all &
xset b off &
xset r rate 220 30 &
xrdb $HOME/.Xdefaults &
xkbcomp -I$HOME/.config/xkb ~/.config/xkb/keymap/kbd $DISPLAY &
xcompmgr &
hsetroot -solid "#1d2021" &
unclutter &

exec i3
