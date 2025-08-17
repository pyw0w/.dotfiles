#!/usr/bin/env bash
# Outputs overall CPU usage percentage (0-100) using /proc/stat deltas
read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
prev_idle=$((idle + iowait))
prev_non_idle=$((user + nice + system + irq + softirq + steal))
prev_total=$((prev_idle + prev_non_idle))

sleep 0.5

read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
idle2=$((idle + iowait))
non_idle2=$((user + nice + system + irq + softirq + steal))
total2=$((idle2 + non_idle2))

totald=$((total2 - prev_total))
idled=$((idle2 - prev_idle))

if [ "$totald" -le 0 ]; then
  echo 0
  exit 0
fi

# usage = (totald - idled) / totald * 100
usage=$(awk -v t="$totald" -v i="$idled" 'BEGIN { printf "%.1f", (t - i) / t * 100 }')
echo "$usage" 