#!/bin/bash

if ping -q -c 1 -W 1 google.com >/dev/null; then
	wget -O /tmp/wallpaper.jpg https://source.unsplash.com/3840x2160/?wallpaper
	feh --bg-fill /tmp/wallpaper.jpg
	wal -i /tmp/wallpaper.jpg -q
else
	feh --bg-fill YOUR_FALLBACK_WALLPAPER_PATH
    wal -i YOUR_FALLBACK_WALLPAPER_PATH -q
fi


