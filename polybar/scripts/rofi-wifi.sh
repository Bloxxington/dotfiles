#!/usr/bin/env bash

export DISPLAY=:0
export XAUTHORITY="$HOME/.Xauthority"

FONT="JetBrainsMono Nerd Font Mono 11"
POSITION=0
YOFF=0
XOFF=0

nmcli dev wifi rescan >/dev/null 2>&1 &

LIST=$(nmcli -t -f SSID,SECURITY device wifi list | grep -v '^--' | while IFS=':' read -r ssid security; do
    [[ -z "$ssid" ]] && ssid="<Hidden>"

    if [[ -z "$security" || "$security" == "--" ]]; then
        sec_display="| Open"
    else
        sec_display=$(echo "$security" \
    | sed -E 's/WPA1/WPA_1/g; s/WPA2/WPA_2/g; s/WPA3/WPA_3/g; s/WEP/WEP/g' \
    | tr ' ' '\n' \
    | sed 's/_/ /g' \
    | awk '{ printf "| %s ", $0 }' \
    | sed 's/ $//')
    fi

    # Pad SSID column to 30 chars, align pipe
    printf "%-30s%s\n" "$ssid" "$sec_display"
done)

# Compose full menu
CHOICE=$(echo -e "Toggle Wi-Fi\nSwitch to Ethernet\nManual Connect\nForget Network\n$LIST" | \
    rofi -dmenu -p "" -font "$FONT" -lines 12 \
    -location "$POSITION" -yoffset "$YOFF" -xoffset "$XOFF")

[[ -z "$CHOICE" ]] && exit 0

# Handle known network list
KNOWN=$(nmcli connection show | awk 'NR>1 {print $1}')

case "$CHOICE" in
    "Toggle Wi-Fi")
        if nmcli radio wifi | grep -q enabled; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
        fi
        ;;

    "Switch to Ethernet")
        ETH_DEV=$(nmcli device | awk '$2=="ethernet" && $3=="disconnected" {print $1; exit}')
        [[ -z "$ETH_DEV" ]] && notify-send "Ethernet not available" && exit 1
        nmcli device connect "$ETH_DEV"
        ;;

    "Forget Network")
        SSID_TO_FORGET=$(echo "$KNOWN" | rofi -dmenu -p "Forget:" -font "$FONT")
        [[ -n "$SSID_TO_FORGET" ]] && nmcli connection delete id "$SSID_TO_FORGET"
        ;;

    "Manual Connect")
        ENTRY=$(rofi -dmenu -p "Manual (SSID,password):" -font "$FONT")
        SSID=$(echo "$ENTRY" | cut -d',' -f1)
        PASS=$(echo "$ENTRY" | cut -d',' -f2)
        [[ -z "$SSID" ]] && exit
        if [[ -z "$PASS" ]]; then
            nmcli device wifi connect "$SSID"
        else
            nmcli device wifi connect "$SSID" password "$PASS"
        fi
        ;;

    *)
        SSID=$(echo "$CHOICE" | awk -F ' *\\| *' '{print $1}' | sed 's/ *$//')
        SECURITY=$(echo "$CHOICE" | awk -F ' *\\| *' '{for (i=2;i<=NF;++i) printf $i " "; print ""}' | xargs)

        # If security is not Open, ask password
        if [[ "$SECURITY" != "Open" ]]; then
            PASS=$(rofi -dmenu -p "Password for $SSID:" -password -font "$FONT")
            [[ -z "$PASS" ]] && exit
            nmcli device wifi connect "$SSID" password "$PASS"
        else
            nmcli device wifi connect "$SSID"
        fi
        ;;
esac