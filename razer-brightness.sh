#!/usr/bin/env bash

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/razer_brightness"
CLI_PATH=$(which polychromatic-cli 2>/dev/null)

if [ -z "$CLI_PATH" ]; then
    echo "Error: polychromatic-cli not found. Please install polychromatic." >&2
    exit 1
fi

get_cur_brightness() {
    if [ -f "$STATE_FILE" ]; then
        local val=$(cat "$STATE_FILE")
        if [[ "$val" =~ ^[0-9]+$ ]]; then echo "$val"; else echo 100; fi
    else
        echo 100
    fi
}

show_osd() {
    local val="$1"
    local text
    case "$val" in
        100) text="Razer Cobra: Max (100%)" ;;
        66)  text="Razer Cobra: High (66%)" ;;
        33)  text="Razer Cobra: Medium (33%)" ;;
        1)   text="Razer Cobra: Dim (1%)" ;;
        *)   text="Razer Cobra: Off" ;;
    esac
    qdbus6 org.kde.plasmashell /org/kde/osdService org.kde.osdService.showText "input-mouse" "$text" 2>/dev/null
}

ACTION="$1"
CUR=$(get_cur_brightness)

case "$ACTION" in
    down|dec)
        if (( CUR >= 100 )); then NEW=66
        elif (( CUR >= 66 )); then NEW=33
        elif (( CUR >= 33 )); then NEW=1
        else NEW=0
        fi
        ;;
    up|inc)
        if (( CUR <= 0 )); then NEW=1
        elif (( CUR <= 1 )); then NEW=33
        elif (( CUR <= 33 )); then NEW=66
        else NEW=100
        fi
        ;;
    restore)
        echo "Startup routine (enforcing 100% brightness) started: $(date)" > /tmp/razer_debug.log
        NEW=100
        for i in {1..3}; do
            sleep 10
            $CLI_PATH -o brightness -p "$NEW" >/dev/null 2>&1
            echo "Attempt $i completed (Target: $NEW)" >> /tmp/razer_debug.log
        done
        echo "$NEW" > "$STATE_FILE"
        exit 0
        ;;
    *)
        echo "Usage: $0 {up|down|restore}"
        exit 1
        ;;
esac

$CLI_PATH -o brightness -p "$NEW" >/dev/null 2>&1
echo "$NEW" > "$STATE_FILE"
show_osd "$NEW"
