#!/usr/bin/env bash

hostname=$(cat /etc/hostname)

if [ "$hostname" = "chaeri" ]; then
  cpu_path="/sys/class/hwmon/hwmon1/fan1_input"
  gpu_path="/sys/class/hwmon/hwmon1/fan2_input"
  mid_path="/sys/class/hwmon/hwmon1/fan3_input"
elif [ "$hostname" = "workbox" ] || sensors | grep -q "dell_ddv-virtual-0"; then
  cpu_path="/sys/class/hwmon/hwmon1/fan1_input"
  gpu_path="/sys/class/hwmon/hwmon1/fan1_input"
elif [ "$hostname" = "realbox" ]; then
  cpu_path=$(echo /sys/devices/platform/it87.2624/hwmon/hwmon*/fan1_input)
  gpu_path="nvidia-smi"
elif [ "$hostname" = "powerbox" ]; then
  cpu_path="/sys/devices/platform/asus-nb-wmi/hwmon/hwmon4/fan1_input"
  gpu_path="/sys/devices/platform/asus-nb-wmi/hwmon/hwmon4/fan2_input"
fi

cpu_speed=$(cat "${cpu_path:-}" 2>/dev/null || echo 0)
if [ "$gpu_path" = "nvidia-smi" ]; then
  gpu_speed=$(nvidia-smi --query-gpu=fan.speed --format=csv,noheader 2>/dev/null | grep -oP '\d+' || echo 0)
else
  gpu_speed=$(cat "$gpu_path" 2>/dev/null || echo 0)
fi

mid_speed=$(cat "$mid_path" 2>/dev/null || echo 0)

if [ "$cpu_speed" -gt "$gpu_speed" ] && [ "$cpu_speed" -gt "$mid_speed" ]; then
  max_speed=$cpu_speed
elif [ "$gpu_speed" -gt "$cpu_speed" ] && [ "$gpu_speed" -gt "$mid_speed" ]; then
  max_speed=$gpu_speed
else
  max_speed=$mid_speed
fi

formatted="CPU : $cpu_speed | GPU : $gpu_speed | MID : $mid_speed"
printf '{"cpu":%s,"gpu":%s,"mid":%s,"max":%s,"formatted":"%s"}\n' "$cpu_speed" "$gpu_speed" "$mid_speed" "$max_speed" "$formatted"
