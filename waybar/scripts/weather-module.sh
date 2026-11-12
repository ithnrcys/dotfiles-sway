#!/usr/bin/env bash
# Weather for the top bar: condition icon + temperature from wttr.in, polled every 15 min.

# get_icon <condition text> <day|night>
# Order matters: wttr.in conditions combine words ("Moderate or heavy rain with thunder",
# "Patchy light snow with thunder"), so the most severe match has to come first.
get_icon() {
    local condition=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    local time="$2"
    case "$condition" in
        *thunder*|*storm*)                          echo "󰖓" ;;
        *snow*|*sleet*|*blizzard*|*ice*|*hail*)     echo "󰖘" ;;
        *rain*|*drizzle*|*shower*)                  echo "󰖖" ;;
        *fog*|*mist*|*haze*|*smoke*|*dust*|*sand*)  echo "󰖑" ;;
        *partly*)   [ "$time" = "day" ] && echo "󰖕" || echo "󰼱" ;;
        *cloud*|*overcast*)                         echo "󰖐" ;;
        *sunny*|*clear*) [ "$time" = "day" ] && echo "󰖙" || echo "󰖔" ;;
        *)                                          echo "󰖐" ;;
    esac
}

# --max-time keeps the bar from hanging when the network is down
weather=$(curl -sf --max-time 5 'wttr.in/?format=%C|%t' 2>/dev/null)

# wttr.in answers with an error page or "Unknown location" text now and then; only accept "cond|temp"
if [[ "$weather" != *"|"*"°"* ]]; then
    echo "󰖐 --°C"
    exit 0
fi

condition=${weather%%|*}
temp=${weather##*|}
temp=${temp#+}

hour=$(date +%-H)
if [ "$hour" -ge 6 ] && [ "$hour" -lt 20 ]; then time="day"; else time="night"; fi

echo "$(get_icon "$condition" "$time") $temp"
