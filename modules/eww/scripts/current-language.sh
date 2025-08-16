#!/bin/bash

# Get current keyboard layout
# This script detects the current keyboard layout for EWW

# Method 1: Try to get from hyprctl (for Hyprland)
if command -v hyprctl >/dev/null 2>&1; then
    # Find the main keyboard (main: yes) and get its active keymap
    main_keyboard_section=$(hyprctl devices | grep -B 15 -A 5 "main: yes" | grep "active keymap:" | tail -1)
    if [ -n "$main_keyboard_section" ]; then
        current_layout=$(echo "$main_keyboard_section" | awk '{print $3}')
        case $current_layout in
            "English") echo "US";;
            "Russian") echo "RU";;
            *) echo "$current_layout";;
        esac
        exit 0
    fi
fi

# Method 2: Try to get from setxkbmap (for X11)
if command -v setxkbmap >/dev/null 2>&1; then
    current_layout=$(setxkbmap -query | grep layout | awk '{print $2}' | cut -d',' -f1)
    if [ -n "$current_layout" ]; then
        case $current_layout in
            "us") echo "US";;
            "ru") echo "RU";;
            *) echo "$current_layout";;
        esac
        exit 0
    fi
fi

# Method 3: Try to get from localectl
if command -v localectl >/dev/null 2>&1; then
    current_layout=$(localectl status | grep "X11 Layout" | awk '{print $3}' | cut -d',' -f1)
    if [ -n "$current_layout" ]; then
        case $current_layout in
            "us") echo "US";;
            "ru") echo "RU";;
            *) echo "$current_layout";;
        esac
        exit 0
    fi
fi

# Method 4: Try to get from environment variables
if [ -n "$XKB_DEFAULT_LAYOUT" ]; then
    case $XKB_DEFAULT_LAYOUT in
        "us") echo "US";;
        "ru") echo "RU";;
        *) echo "$XKB_DEFAULT_LAYOUT";;
    esac
    exit 0
fi

# Fallback: default to US
echo "US" 