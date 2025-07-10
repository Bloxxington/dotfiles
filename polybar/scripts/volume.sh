#!/bin/bash

get_volume() {
    vol=$(pamixer --get-volume)
    mute=$(pamixer --get-mute)

    if [[ "$mute" == true || "$vol" -eq 0 ]]; then
        echo "  Muted"
    else
        echo "  ${vol}%"
    fi
}

get_volume

pactl subscribe | grep --line-buffered "sink" | while read -r _; do
    get_volume
done