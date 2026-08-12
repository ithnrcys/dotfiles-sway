#!/usr/bin/env bash
n=$(zypper --no-refresh -q lu 2>/dev/null | grep -c '^v ')
echo "$n"
