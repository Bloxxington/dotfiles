print_battery() {
  UPOWER_OUTPUT=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)

  PERCENT=$(echo "$UPOWER_OUTPUT" | awk '/percentage:/ {gsub("%", ""); print $2}')
  STATE=$(echo "$UPOWER_OUTPUT" | awk '/state:/ {print $2}')

  REAL_PERCENT=$PERCENT

  if [[ "$STATE" == "charging" ]]; then
      ICON="󰂄"
  else
      case $REAL_PERCENT in
          [0-9]) ICON="󰁺" ;;
          1[0-9]) ICON="󰁻" ;;
          2[0-9]) ICON="󰁼" ;;
          3[0-9]) ICON="󰁽" ;;
          4[0-9]) ICON="󰁾" ;;
          5[0-9]) ICON="󰁿" ;;
          6[0-9]) ICON="󰂀" ;;
          7[0-9]) ICON="󰂁" ;;
          8[0-9]) ICON="󰂂" ;;
          9[0-9]|100) ICON="󰁹" ;;
          *) ICON="?" ;;
      esac
  fi

  echo "$ICON ${REAL_PERCENT}%"
}