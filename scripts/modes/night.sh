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

# if hook exists, run it
hook_file="$script_dir/hooks/night.sh"
if [ -f "$hook_file" ]; then
  (
    bash $hook_file
  ) &
fi

# wait for all background processes to complete
wait
