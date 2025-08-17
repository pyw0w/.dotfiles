#!/usr/bin/env bash
set -euo pipefail

# Prefer lm-sensors if available
if command -v sensors >/dev/null 2>&1; then
	# Extract all temperature lines with units (°C or °F)
	# Example line: "Core 0:        +44.0°C  (high = +100.0°C, crit = +100.0°C)"
	sensors | awk '
		/^[A-Za-z0-9].*:$/ { next } # skip chip headers for compactness
		/:\s+[+\-]?[0-9.]+°[CF]/ {
			line = $0
			sub(/^\s+/, "", line)
			split(line, a, ":")
			label = a[1]
			match(line, /[+\-]?[0-9.]+°[CF]/, m)
			if (m[0] != "") {
				printf "%s: %s\n", label, m[0]
			}
		}' | sed 's/\s\{2,\}/ /g' | sed '/^$/d' | head -n 50
	exit 0
fi

# Fallback to /sys/class/thermal if lm-sensors is not available
out=""
for z in /sys/class/thermal/thermal_zone*; do
	[ -r "$z/temp" ] || continue
	t=$(cat "$z/temp" 2>/dev/null || echo "")
	[ -n "$t" ] || continue
	name=$(cat "$z/type" 2>/dev/null || basename "$z")
	temp_c=$(awk -v v="$t" 'BEGIN { if (v == "") { print "" } else { printf "%.1f°C", v/1000 } }')
	[ -n "$temp_c" ] || continue
	out+="$name: $temp_c\n"
done

if [ -n "$out" ]; then
	printf "%b" "$out" | sed '/^$/d'
else
	echo "No sensor temperatures"
fi 