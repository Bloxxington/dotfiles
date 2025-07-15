#!/bin/bash

temp=$(sensors | awk '/Package id 0:/ {gsub(/\+/, "", $4); print $4}' | head -n 1)
[ -z "$temp" ] && temp="N/A"
echo " $temp"