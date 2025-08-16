 #!/bin/bash

# Try to get CPU temperature from different sources
temp=""
if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
    temp=$(cat /sys/class/thermal/thermal_zone0/temp)
    temp=$(($temp / 1000))
elif command -v sensors >/dev/null 2>&1; then
    temp=$(sensors | grep "Core 0:" | awk '{print $3}' | sed 's/+//' | sed 's/°C//')
elif [ -f "/proc/acpi/thermal_zone/THM0/temperature" ]; then
    temp=$(cat /proc/acpi/thermal_zone/THM0/temperature | awk '{print $2}')
fi

# If no temperature found, set to 0
if [ -z "$temp" ] || [ "$temp" = "" ]; then
    temp=0
fi

echo "{\"temperature\":$temp}"