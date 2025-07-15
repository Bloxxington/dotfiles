#!/usr/bin/env bash

export DISPLAY=:0
export XAUTHORITY="$HOME/.Xauthority"

print_icon() {
    if nmcli device status | grep -qE '^enp.*connected'; then
        echo "%{F#00afff}%{F-}"  # Ethernet
        return
    fi

    wifi_state=$(nmcli radio wifi)
    ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)

    if [[ "$wifi_state" == "enabled" ]]; then
        if [[ -n "$ssid" ]]; then
            echo "%{F#ffffff}%{F-}"
        else
            echo "%{F#888888}%{F-}"
        fi
    else
        echo "%{F#444444}%{F-}"
    fi
}

print_icon