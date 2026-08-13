#!/usr/bin/env bash
print_ws() {
  IFS='|' read -r l c r < <(swaymsg -t get_workspaces | jq -r '
    (map(.focused) | index(true)) as $i | map(.name) |
    "\(.[:$i] | join("     "))|\(.[$i])|\(.[$i+1:] | join("     "))"')
  # pad the shorter side so [focused] sits at the visual centre
  while [ ${#l} -lt ${#r} ]; do l=" $l"; done
  while [ ${#r} -lt ${#l} ]; do r="$r "; done
  echo "$l   [$c]   $r"
}
print_ws
swaymsg -t subscribe -m '["workspace"]' | while read -r _; do print_ws; done
