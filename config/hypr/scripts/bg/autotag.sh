#!/usr/bin/env bash

tags=(urgent bell)

parse() {
  case $1 in
  activewindowv2*)
    window_addr=$(echo $line | sed 's/activewindowv2>>/0x/')

    batch_cmds=""
    for tag in "${tags[@]}"; do
      batch_cmds+="dispatch tagwindow -${tag} address:${window_addr};"
    done
    batch_cmds=${batch_cmds%;} # remove trailing semicolon

    hyprctl -q --batch "$batch_cmds"
    ;;
  urgent* | bell*)
    # split the line by '>>'
    type="${line%%>>*}"
    string="0x${line#*>>}"

    hyprctl -q dispatch tagwindow +${type} address:${string}
    ;;
  esac
}

socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do parse "$line"; done
