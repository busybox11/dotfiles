#!/bin/bash

echo "󰕾 $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}')%"
