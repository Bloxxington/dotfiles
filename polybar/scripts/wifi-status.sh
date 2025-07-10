#!/usr/bin/env bash

export DISPLAY=:0
export XAUTHORITY="$HOME/.Xauthority"

print_icon() {
    wifi_state=$(nmcli radio wifi)
    ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)

    if [[ "$wifi_state" == "enabled" ]]; then
        if [[ -n "$ssid" ]]; then
            echo "%{F#ffffff}%{F-}"  # connected = white
        else
            echo "%{F#888888}%{F-}"  # enabled but not connected = gray
        fi
    else
        echo "%{F#444444}%{F-}"      # disabled = dark gray
    fi
}

# Initial output
print_icon

# Monitor for network changes
nmcli device monitor | while read -r; do
    print_icon
done