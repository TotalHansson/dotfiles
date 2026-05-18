#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# for changing Hyprland Layouts (Master or Dwindle) on the fly

notif="$HOME/.config/swaync/images/ja.png"

LAYOUT=$(hyprctl -j activeworkspace | jq -r .tiledLayout)

# Reverse layout value to reuse toggle logic. So layouts don't get swapped initially.
if [ "$1" = "init" ]; then
  if [ "$LAYOUT" = "master" ]; then
    LAYOUT="dwindle"
  else
    LAYOUT="master"
  fi
fi

case $LAYOUT in
"master")
  hyprctl keyword workspace $(hyprctl activeworkspace -j | jq -r .id),layout:dwindle
  notify-send -e -u low -i "$notif" " Dwindle Layout"
  ;;
"dwindle")
  hyprctl keyword workspace $(hyprctl activeworkspace -j | jq -r .id),layout:master
  hyprctl dispatch layoutmsg swapwithmaster ignoremaster
  notify-send -e -u low -i "$notif" " Master Layout"
  ;;
*) ;;

esac
