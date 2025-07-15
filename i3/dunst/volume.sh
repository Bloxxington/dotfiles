#!/bin/bash

get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%'
}

is_mute() {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes
}

send_notification() {
    vol=$(get_volume)
    if is_mute || [[ $vol -eq 0 ]]; then
        icon="" 
        msg="$icon  Muted"
        vol=0
    elif (( vol <= 70 )); then
        icon=""
        msg="$icon  ${vol}%"
    else
        icon=""
        msg="$icon  ${vol}%"
    fi
    notify-send -u low -t 1000 -h int:value:"$vol" -h string:x-dunst-stack-tag:volume "$msg"
}

case "$1" in
  up)
    pactl set-sink-mute @DEFAULT_SINK@ false
    pactl set-sink-volume @DEFAULT_SINK@ +10%
    send_notification
    ;;
  down)
    pactl set-sink-mute @DEFAULT_SINK@ false
    pactl set-sink-volume @DEFAULT_SINK@ -10%
    send_notification
    ;;
  mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    send_notification
    ;;
esac