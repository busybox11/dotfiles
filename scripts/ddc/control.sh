#!/bin/bash

# Usage:
# bash ddc/control.sh set_brightness <monitor_serial> <brightness_value>
# bash ddc/control.sh set_power <monitor_serial> <power_value>

command=$1
monitor_serial=$2
value=$3

get_monitor_flags() {
    # HP (-n 3CQ6030YX6) requires special flags
    if [ "$monitor_serial" == "3CQ6030YX6" ]; then
        echo "--skip-ddc-checks --sleep-multiplier 8 --maxtries 0,15,0"
    else
        echo "--skip-ddc-checks --sleep-multiplier 0.2"
    fi
}

run_ddc_command() {
    local vcp_code=$1
    local ddc_value=$2
    local flags
    flags=$(get_monitor_flags)

    # If it's the HP monitor, loop 5 times, else once
    local iterations=1
    if [ "$monitor_serial" == "3CQ6030YX6" ]; then
        iterations=5
    fi
    
    for ((i=1;i<=iterations;i++)); do
        ddcutil -n $monitor_serial $flags setvcp $vcp_code $ddc_value
    done
}

set_brightness() {
    run_ddc_command 10 "$value"
}

set_power() {
    run_ddc_command d6 "$value"
}

if [ "$command" == "set_brightness" ]; then
    set_brightness
elif [ "$command" == "set_power" ]; then
    set_power
fi
