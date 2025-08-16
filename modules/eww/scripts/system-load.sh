 #!/bin/bash

# Get system load averages
load1=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
load5=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $2}' | sed 's/,//')
load15=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $3}')

# Get uptime (NixOS compatible)
uptime_seconds=$(uptime | sed 's/.*up //' | sed 's/,.*//' | sed 's/ days/d/' | sed 's/ day/d/' | sed 's/ hours/h/' | sed 's/ hour/h/' | sed 's/ minutes/m/' | sed 's/ minute/m/')

echo "{\"load1\":\"$load1\",\"load5\":\"$load5\",\"load15\":\"$load15\",\"uptime\":\"$uptime_seconds\"}"