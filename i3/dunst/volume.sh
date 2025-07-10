#!/bin/bash

action="$1"

case "$action" in
  up)
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    ;;
  down)
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    ;;
  mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    ;;
esac

volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)
vol_num=${volume%\%}
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

if [[ "$muted" == "yes" || "$vol_num" == "0" ]]; then
    icon=" "
    message="$icon Muted"
else
    icon=" "
    message="$icon $vol_num%"
fi

notify-send -h int:value:"$vol_num" \
            -h string:x-dunst-stack-tag:volume \
            "$message"
