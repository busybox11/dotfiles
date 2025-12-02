#!/bin/bash

text="$1"
now=$(date +%s)

eww update notice="{\"id\":$now,\"text\":\"$text\"}"
