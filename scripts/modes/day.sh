#!/bin/bash

# set day mode
echo "Setting day mode"

# hyprsunset
echo "Resetting hyprsunset"
hyprctl hyprsunset identity

# turn monitor brightness all the way up
echo "Setting monitors brightness to 100"

script_dir=$(dirname "$0")
day_script="$script_dir/../ddc/control.sh"

bash $day_script set_brightness 1Q1Q7HA012666 100
bash $day_script set_brightness 3CQ6030YX6 100

# hyprpaper
day_wallpaper="~/Pictures/wallpapers/james_k_friend_darken.png"
hyprctl hyprpaper preload $day_wallpaper
hyprctl hyprpaper wallpaper ,$day_wallpaper

# get remaining loaded wallpapers, unload all but the day wallpaper
remaining_wallpapers=$(hyprctl hyprpaper listloaded | grep -v $day_wallpaper)
for wallpaper in $remaining_wallpapers; do
    hyprctl hyprpaper unload $wallpaper
done