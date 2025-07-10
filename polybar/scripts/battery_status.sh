#!/bin/bash

print_battery() {
  UPOWER_OUTPUT=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)

  PERCENT=$(echo "$UPOWER_OUTPUT" | awk '/percentage:/ {gsub("%", ""); print $2}')
  STATE=$(echo "$UPOWER_OUTPUT" | awk '/state:/ {print $2}')
  ENERGY_NOW=$(echo "$UPOWER_OUTPUT" | awk '/energy:/ && !/energy-full/ {print $2}')
  ENERGY_DESIGN=$(echo "$UPOWER_OUTPUT" | awk '/energy-full-design:/ {print $2}')

  REAL_PERCENT=$(awk "BEGIN { printf(\"%.0f\", 100 * $ENERGY_NOW / $ENERGY_DESIGN) }")

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

# Initial output
print_battery

# Listen for battery events
udevadm monitor --subsystem-match=power_supply --udev | \
while read -r _; do
  print_battery
done