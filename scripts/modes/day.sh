#!/bin/bash

# set day mode
echo "Setting day mode"

script_dir=$(dirname "$0")
day_script="$script_dir/../ddc/control.sh"

# hyprsunset
(
  echo "Resetting hyprsunset"
  hyprctl hyprsunset identity
) &

# turn monitor brightness all the way up
echo "Setting monitors brightness to 100"
(
  bash $day_script set_brightness 1Q1Q7HA012666 100
) &
(
  bash $day_script set_brightness 3CQ6030YX6 100
) &

# wait for all background processes to complete
wait
