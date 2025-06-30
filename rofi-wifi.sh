#!/usr/bin/env bash

# Starts a scan of available broadcasting SSIDs
# nmcli dev wifi rescan

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default config
FIELDS="SSID,SECURITY"
POSITION=0
YOFF=0
XOFF=0
FONT="JetBrains Mono 11"

# Load config if exists
if [ -r "$DIR/config" ]; then
    source "$DIR/config"
elif [ -r "$HOME/.config/rofi/wifi" ]; then
    source "$HOME/.config/rofi/wifi"
else
    echo "WARNING: config file not found! Using default values." >&2
fi

# Get list of Wi-Fi SSIDs and security (remove separator lines)
LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d')

# Approximate rofi width (rofi underestimates width by ~2 chars)
RWIDTH=$(( $(echo "$LIST" | head -n1 | awk '{ print length($0) }') + 2 ))

# Count number of SSIDs
LINENUM=$(echo "$LIST" | wc -l)

# Known connections for speeding up connection attempts
KNOWNCON=$(nmcli connection show)

# Check if Wi-Fi is enabled
CONSTATE=$(nmcli -fields WIFI g)

# Current connected SSID, if any
CURRSSID=$(LANGUAGE=C nmcli -t -f active,ssid dev wifi | awk -F: '$1 == "yes" { print $2 }')

HIGHLINE=""
if [[ -n "$CURRSSID" ]]; then
    # Find the line number of the connected SSID for rofi to highlight
    HIGHLINE=$(echo "$LIST" | awk -F"[ ]{2,}" '{print $1}' | grep -Fxn -m1 "$CURRSSID" | cut -d: -f1)
    ((HIGHLINE=HIGHLINE + 1))
fi

# Limit rofi height: max 8 lines if Wi-Fi enabled, 1 line if disabled
if [[ "$LINENUM" -gt 8 && "$CONSTATE" == "enabled" ]]; then
    LINENUM=8
elif [[ "$CONSTATE" == "disabled" ]]; then
    LINENUM=1
fi

# Wi-Fi toggle option label
if [[ "$CONSTATE" == "enabled" ]]; then
    TOGGLE="Toggle Off"
else
    TOGGLE="Toggle On"
fi

# Compose rofi menu options: toggle option + manual entry + Wi-Fi list
CHENTRY=$(echo -e "$TOGGLE\nManual Network Connection\n$LIST" | uniq -u | rofi \
    -dmenu -p "Wi-Fi SSID: " -lines "$LINENUM" -a "${HIGHLINE:-0}" \
    -location "$POSITION" -yoffset "$YOFF" -xoffset "$XOFF" -font "$FONT" -width -"$RWIDTH")

if [[ -z "$CHENTRY" ]]; then
    # User pressed ESC or entered nothing; exit
    exit 0
fi

# Extract SSID part (first column)
CHSSID=$(echo "$CHENTRY" | sed 's/\s\{2,\}/|/g' | awk -F"|" '{print $1}')

case "$CHENTRY" in
    "Manual Network Connection")
        # Prompt for manual SSID,password entry
        MSSID=$(echo "enter SSID,password (password optional)" | rofi -dmenu -p "Manual Entry:" -font "$FONT" -lines 1)
        [[ -z "$MSSID" ]] && exit 0
        MPASS=$(echo "$MSSID" | awk -F, '{print $2}')
        SSIDONLY=$(echo "$MSSID" | awk -F, '{print $1}')
        if [[ -z "$MPASS" ]]; then
            nmcli dev wifi con "$SSIDONLY"
        else
            nmcli dev wifi con "$SSIDONLY" password "$MPASS"
        fi
        ;;

    "Toggle On")
        nmcli radio wifi on
        ;;

    "Toggle Off")
        nmcli radio wifi off
        ;;

    *)
        # Fix for currently connected (marked with *) SSID parsing
        if [[ "$CHSSID" == "*" ]]; then
            CHSSID=$(echo "$CHENTRY" | sed 's/\s\{2,\}/|/g' | awk -F"|" '{print $3}')
        fi

        # Check if connection exists in known connections
        if echo "$KNOWNCON" | grep -q "^$CHSSID\$"; then
            nmcli con up "$CHSSID"
        else
            # Prompt password if network is secured
            if [[ "$CHENTRY" =~ "WPA2" || "$CHENTRY" =~ "WEP" ]]; then
                WIFIPASS=$(echo "If connection is stored, hit Enter" | rofi -dmenu -p "Password:" -lines 1 -font "$FONT")
            fi
            nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
        fi
        ;;
esac
