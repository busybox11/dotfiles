#!/bin/bash

song_info=$(playerctl metadata --format '{{title}} · {{artist}}')

[[ -z "$song_info" ]] && { exit 1; }

status=$(playerctl status)
if [[ "$status" == "Playing" ]]; then
  state=""
elif [[ "$status" == "Paused" ]]; then
  state="󰏤  "
fi

echo "  $state$song_info"
