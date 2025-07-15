#!/bin/bash

status=$(cat /sys/class/power_supply/BAT0/status)
capacity=$(cat /sys/class/power_supply/BAT0/capacity)

if [[ "$status" == "Charging" ]]; then
  echo "󰂄 ${capacity}%"
  exit
fi

case $capacity in
  [0-9]|10) icon="󰁺" ;;
  1[1-9]|20) icon="󰁻" ;;
  2[1-9]|30) icon="󰁼" ;;
  3[1-9]|40) icon="󰁽" ;;
  4[1-9]|50) icon="󰁽" ;;
  5[1-9]|60) icon="󰁾" ;;
  6[1-9]|70) icon="󰁿" ;;
  7[1-9]|80) icon="󰂀" ;;
  8[1-9]|90) icon="󰂁" ;;
  *) icon="󰁹" ;;
esac

echo "$icon ${capacity}%"