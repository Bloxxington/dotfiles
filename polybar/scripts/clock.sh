#!/bin/bash

# Show time instantly at launch
echo "󰥔 $(date '+%I:%M %p')"

# Wait for next full minute to sync
sleep $((60 - $(date +%s) % 60))

# Then print every minute, exactly on time
while true; do
    echo "󰥔 $(date '+%I:%M %p')"
    sleep 60
done