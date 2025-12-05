#!/bin/bash

baseCmd="hyprshot --output-folder /home/$USER/Pictures/hyprshots"
hyprshotparams="$1"

# command to run if first one succeed
export successText="$2"

send_success() {
  if [[ -n $successText ]]; then
    bash $HOME/.config/eww/scripts/send-notice.sh "$successText"
  fi
}
export -f send_success

# run success command if first one succees and if successText is not empty
$baseCmd $hyprshotparams -- send_success

# hyprshot always returns exit code 1 lmao
# https://github.com/Gustash/Hyprshot/issues/129
