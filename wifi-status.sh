#!/usr/bin/env bash

# Ensure it runs from Polybar environment
export DISPLAY=:0
export XAUTHORITY="$HOME/.Xauthority"

# Get status
wifi_state=$(nmcli radio wifi)
ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)

# Output formatted icon
if [[ "$wifi_state" == "enabled" ]]; then
    if [[ -n "$ssid" ]]; then
        echo "%{F#ffffff}%{F-}"  # white icon
    else
        echo "%{F#888888}%{F-}"  # gray icon
    fi
else
    echo "%{F#444444}%{F-}"      # dark gray icon
fi
