#!/bin/bash

change=$1
if [[ "$change" == "up" ]]; then
    brightnessctl set +10%
elif [[ "$change" == "down" ]]; then
    brightnessctl set 10%-
fi

current=$(brightnessctl get)
max=$(brightnessctl max)
percent=$(( 100 * current / max ))

notify-send -h int:value:$percent \
            -h string:x-dunst-stack-tag:brightness \
            " $percent%"
