#!/usr/bin/env bash

# Fetch current brightness from the external monitor via I2C
b_val=$(ddcutil getvcp 10 2>/dev/null | grep -oP 'current value =\s*\K[0-9]+')

# Fallback if ddcutil is busy or offline
if [ -z "$b_val" ]; then
    echo "󰃟 Offline"
    exit 0
fi

# ------------------------------------------
# THE BAR GENERATOR (Matches your volume bar)
# ------------------------------------------
total_width=15
# Calculate how many filled blocks we need based on percentage
filled_width=$(( (b_val * total_width) / 100 ))
empty_width=$(( total_width - filled_width - 1 ))

bar=""

# 1. Add the filled characters (━)
for (( i=0; i<$filled_width; i++ )); do bar="${bar}━"; done

# 2. Add the indicator (┫)
bar="${bar}┫"

# 3. Add the empty characters (╍)
if [ $empty_width -gt 0 ]; then
    for (( i=0; i<$empty_width; i++ )); do bar="${bar}╍"; done
fi

# Output the icon and the calculated bar
echo "󰃟  $bar"
