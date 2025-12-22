#!/bin/bash

# set night mode
echo "Setting night mode"

script_dir=$(dirname "$0")
night_script="$script_dir/../ddc/control.sh"

# hyprsunset
(
  hyprctl hyprsunset temperature 3500
) &

# turn monitor brightness all the way down
echo "Setting monitors brightness to 0"
(
  bash $night_script set_brightness 1Q1Q7HA012666 0
) &
(
  bash $night_script set_brightness 3CQ6030YX6 0
) &

# hyprpaper
(
  night_wallpaper="~/Pictures/wallpapers/ilmc_desktop_bg.png"
  hyprctl hyprpaper preload $night_wallpaper
  hyprctl hyprpaper wallpaper ,$night_wallpaper

  # get remaining loaded wallpapers, unload all but the night wallpaper
  remaining_wallpapers=$(hyprctl hyprpaper listloaded | grep -v $night_wallpaper)
  for wallpaper in $remaining_wallpapers; do
    hyprctl hyprpaper unload $wallpaper
  done
) &

# if hook exists, run it
hook_file="$script_dir/hooks/night.sh"
if [ -f "$hook_file" ]; then
  (
    bash $hook_file
  ) &
fi

# wait for all background processes to complete
wait
