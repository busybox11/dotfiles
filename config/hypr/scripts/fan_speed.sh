#!/usr/bin/env bash

shopt -s nullglob

skip_smm=0
for d in /sys/class/hwmon/hwmon*; do
  name=$(cat "$d/name" 2>/dev/null) || continue
  [ "$name" = dell_ddv ] && skip_smm=1
done

for d in /sys/class/hwmon/hwmon*; do
  name=$(cat "$d/name" 2>/dev/null) || continue
  if [ "$name" = k10temp ] || [ "$name" = coretemp ]; then
    [ -r "$d/temp1_input" ] && printf 'temp %s\n' "$d/temp1_input"
  fi
  [ "$skip_smm" = 1 ] && [ "$name" = dell_smm ] && continue
  for f in "$d"/fan*_input; do
    [ -r "$f" ] && printf 'fan %s\n' "$f"
  done
done
