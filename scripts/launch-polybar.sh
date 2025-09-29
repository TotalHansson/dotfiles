#!/bin/sh
primary_monitor=$(polybar --list-monitors | grep primary | cut -d":" -f1)

for m in $(polybar --list-monitors | cut -d":" -f1); do
    if [ "$m" = "$primary_monitor" ]; then
        MONITOR=$m polybar --reload --quiet i3-main &> /dev/null &
    else
        MONITOR=$m polybar --reload --quiet i3-secondary &> /dev/null &
    fi
done
