#!/bin/bash

rm -rf .cache/wal
if ping -q -c 1 -W 1 google.com >/dev/null; then
    wget -O /tmp/wallpaper.jpg http://source.unsplash.com/3840x2160/?wallpaper --no-check-certificate
    feh --bg-fill /tmp/wallpaper.jpg
    wal -i "/tmp/wallpaper.jpg" -n
else
    feh --bg-fill ~/Pictures/Wallpapers/img_wallpapers_basic\ wallpaper_library.png
    wal -i "~/Pictures/Wallpapers/img_wallpapers_basic wallpaper_library.png" -n
fi
