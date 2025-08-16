 #!/bin/bash

# Get disk usage for root filesystem
df_output=$(df / | tail -1)
total=$(echo "$df_output" | awk '{print $2}')
used=$(echo "$df_output" | awk '{print $3}')
available=$(echo "$df_output" | awk '{print $4}')

# Convert to GB (using bash arithmetic)
total_gb=$(($total / 1024 / 1024))
used_gb=$(($used / 1024 / 1024))
available_gb=$(($available / 1024 / 1024))

# Calculate percentage
used_percent=$(($used * 100 / $total))

echo "{\"total\":\"${total_gb}G\",\"used\":\"${used_gb}G\",\"available\":\"${available_gb}G\",\"used_percent\":$used_percent}"