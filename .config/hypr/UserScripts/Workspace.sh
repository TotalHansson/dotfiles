#!/usr/bin/env bash

TARGET_WS=$1

if hyprctl workspaces -j | jq -e ".[] | select(.id == $TARGET_WS and .windows > 0)" >/dev/null; then
  hyprctl --batch "dispatch workspace $TARGET_WS ; dispatch movecursortocorner 2"
else
  hyprctl dispatch workspace $TARGET_WS
fi
