#!/bin/bash

# Get the currently playing song
url=$(playerctl metadata --format '{{mpris:artUrl}}')

if [ -z "$url" ]; then
  echo ""
else
  if [[ "$url" == file://* ]]; then
    url=${url#file://}
  fi
  echo "$url"
fi
