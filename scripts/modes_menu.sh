#!/bin/bash

# opens mode dmenu selector with vicinae
# all modes are scripts stored in the ./modes directory relative to this script

modes_dir=$(dirname "$0")/modes
menu_items=$(ls "$modes_dir" | sed 's/\.sh$//')

selected=$(echo -e "$menu_items" | vicinae dmenu --placeholder "toggle mode")

if [ -n "$selected" ]; then
    bash "$modes_dir/$selected.sh"
fi
