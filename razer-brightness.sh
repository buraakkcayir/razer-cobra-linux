#!/usr/bin/env bash

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/razer_brightness"
CLI_PATH=$(command -v polychromatic-cli || true)
QDBUS_PATH=$(command -v qdbus6 || true)

if [ -z "$CLI_PATH" ]; then
    echo "Error: polychromatic-cli not found. Please install polychromatic." >&2
    exit 1
fi
if [ -z "$QDBUS_PATH" ]; then
    echo "Error: qdbus6 not found. Install KDE Plasma's Qt D-Bus tools." >&2
    exit 1
fi

get_cur_brightness() {
    if [ -f "$STATE_FILE" ]; then
        local val
        val=$(cat "$STATE_FILE")
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
    "$QDBUS_PATH" org.kde.plasmashell /org/kde/osdService org.kde.osdService.showText "razer-cobra" "$text"
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
        NEW=100
        for i in {1..3}; do
            sleep 10
            if ! "$CLI_PATH" -o brightness -p "$NEW"; then
                echo "Error: failed to set brightness during restore attempt $i." >&2
                exit 1
            fi
        done
        mkdir -p "$(dirname "$STATE_FILE")" || {
            echo "Error: cannot create state directory: $(dirname "$STATE_FILE")" >&2
            exit 1
        }
        echo "$NEW" > "$STATE_FILE"
        exit 0
        ;;
    *)
        echo "Usage: $0 {up|down|restore}"
        exit 1
        ;;
esac

if ! "$CLI_PATH" -o brightness -p "$NEW"; then
    echo "Error: failed to set brightness to $NEW%." >&2
    exit 1
fi
mkdir -p "$(dirname "$STATE_FILE")" || {
    echo "Error: cannot create state directory: $(dirname "$STATE_FILE")" >&2
    exit 1
}
if ! echo "$NEW" > "$STATE_FILE"; then
    echo "Error: cannot write brightness state to $STATE_FILE." >&2
    exit 1
fi
show_osd "$NEW"
