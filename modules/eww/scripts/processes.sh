 #!/bin/bash

# Get total number of processes
total_processes=$(ps aux | wc -l)
total_processes=$((total_processes - 1))  # Subtract header line

# Get number of running processes
running_processes=$(ps aux | grep -c " R ")

# Get number of sleeping processes
sleeping_processes=$(ps aux | grep -c " S ")

echo "{\"total\":$total_processes,\"running\":$running_processes,\"sleeping\":$sleeping_processes}"