#!/bin/bash

# opens mode dmenu selector with vicinae
# all modes are scripts stored in the ./modes directory relative to this script
# only shows scripts in the root of the modes directory, ignores subdirectories (hooks, utils...)

modes_dir="$(dirname "$0")/modes"
menu_items=$(find "$modes_dir" -maxdepth 1 -type f -name "*.sh")

selected=$(echo -e "$menu_items" | vicinae dmenu --placeholder "toggle mode")

if [ -n "$selected" ]; then
  bash "$selected"
fi
