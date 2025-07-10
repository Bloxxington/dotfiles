#!/bin/bash

while true; do
    level=$(cat /sys/class/power_supply/BAT0/capacity)
    status=$(cat /sys/class/power_supply/BAT0/status)

    if [[ "$status" == "Discharging" ]]; then
        if (( level <= 5 )); then
            notify-send -u critical -h string:x-dunst-stack-tag:battery "󰂃 Critical Battery: $level%"
        elif (( level <= 10 )); then
            notify-send -u normal -h string:x-dunst-stack-tag:battery "󰁺 Low Battery: $level%"
        fi
    fi

    sleep 60
done
