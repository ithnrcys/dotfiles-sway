#!/usr/bin/env bash
# Pending zypper updates.
#   (no args)   print the count for the bar
#   --show      run inside a terminal (bar click): list the updates, then offer to install them

if [[ "$1" == "--show" ]]; then
    echo "Pending updates"
    echo "──────────────────────────────"
    zypper --no-refresh lu
    echo
    read -r -p "Install now with 'sudo zypper dup'? [y/N] " answer
    if [[ "$answer" == [yY]* ]]; then
        sudo zypper dup
        pkill -RTMIN+8 waybar   # refresh the count on the bar
    fi
    echo
    read -r -n 1 -s -p "Press any key to close"
    exit 0
fi

n=$(zypper --no-refresh -q lu 2>/dev/null | grep -c '^v ')
echo "$n"
