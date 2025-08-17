#!/bin/bash

# Get current keyboard layout
# This script detects the current keyboard layout for EWW

# Method 1: Try to get from hyprctl (for Hyprland)
if command -v hyprctl >/dev/null 2>&1; then
    # Prefer JSON for reliability (if jq is available)
    if command -v jq >/dev/null 2>&1; then
        json_layout=$(hyprctl -j devices 2>/dev/null | jq -r 'try (.keyboards[] | select(.main == true) | (.active_keymap // .activeKeymap // .active_layout_name // .activeLayoutName // .layout // .keymap)) catch empty' 2>/dev/null | head -n1)
    else
        json_layout=""
    fi
    if [ -n "$json_layout" ]; then
        lc=$(echo "$json_layout" | tr '[:upper:]' '[:lower:]')
        case "$lc" in
            *ru*) echo "🇷🇺";;
            *us*|*en*) echo "🇺🇸";;
            *) echo "$json_layout";;
        esac
        exit 0
    fi
    # Fallback to plain text parsing
    main_keyboard_section=$(hyprctl devices | grep -B 15 -A 5 "main: yes" | grep "active keymap:" | tail -1)
    if [ -n "$main_keyboard_section" ]; then
        value=$(echo "$main_keyboard_section" | cut -d':' -f2 | sed 's/^ *//')
        lc=$(echo "$value" | tr '[:upper:]' '[:lower:]')
        case "$lc" in
            *ru*) echo "🇷🇺";;
            *us*|*eng*) echo "🇺🇸";;
            *) echo "$value";;
        esac
        exit 0
    fi
fi

# Method 2: Try to get from setxkbmap (for X11)
if command -v setxkbmap >/dev/null 2>&1; then
    current_layout=$(setxkbmap -query | grep layout | awk '{print $2}' | cut -d',' -f1)
    if [ -n "$current_layout" ]; then
        case $current_layout in
            "us") echo "🇺🇸";;
            "ru") echo "🇷🇺";;
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
            "us") echo "🇺🇸";;
            "ru") echo "🇷🇺";;
            *) echo "$current_layout";;
        esac
        exit 0
    fi
fi

# Method 4: Try to get from environment variables
if [ -n "$XKB_DEFAULT_LAYOUT" ]; then
    case $XKB_DEFAULT_LAYOUT in
        "us") echo "🇺🇸";;
        "ru") echo "🇷🇺";;
        *) echo "$XKB_DEFAULT_LAYOUT";;
    esac
    exit 0
fi

# Fallback: default to US
echo "🇺🇸" 