#!/bin/bash

# File to store the last picked color
COLOR_FILE="$HOME/.config/waybar/modules/waypick/last_color"
# File to store color history (last 10 colors)
HISTORY_FILE="$HOME/.config/waybar/modules/waypick/color_history"

# Create the color file if it doesn't exist
if [ ! -f "$COLOR_FILE" ]; then
    echo "#FFFFFF" > "$COLOR_FILE"
fi

# Create the history file if it doesn't exist
if [ ! -f "$HISTORY_FILE" ]; then
    touch "$HISTORY_FILE"
fi

# Function to get the last color
get_last_color() {
    cat "$COLOR_FILE"
}

# Function to add color to history
add_to_history() {
    local color="$1"
    # Check if color already exists in history
    if ! grep -q "^$color$" "$HISTORY_FILE"; then
        # Add to beginning of file
        echo "$color" | cat - "$HISTORY_FILE" > /tmp/temphistory && mv /tmp/temphistory "$HISTORY_FILE"
        # Keep only the last 10 colors
        head -n 10 "$HISTORY_FILE" > /tmp/temphistory && mv /tmp/temphistory "$HISTORY_FILE"
    fi
}

# Function to pick a new color
pick_color() {
    # Run hyprpicker and store the output
    color=$(hyprpicker -a)
    
    # If a color was picked (not cancelled), save it
    if [ -n "$color" ]; then
        # Remove any trailing newlines or whitespace
        color=$(echo "$color" | tr -d '[:space:]')
        echo "$color" > "$COLOR_FILE"
        add_to_history "$color"
    fi
    
    # Don't output anything here - let the signal handler refresh the module
}

# Function to copy the color to clipboard
copy_to_clipboard() {
    color=$(get_last_color)
    echo -n "$color" | wl-copy
    notify-send "Color Copied" "Color $color copied to clipboard" -i color-select
}

# Function to output JSON for waybar
output_json() {
    color=$(get_last_color)
    
    # Create a simple text output with the color
    # Use printf to properly handle escaping
    printf '{"text": "<span foreground=\\"%s\\">■</span> %s", "tooltip": "Click to pick a color\\nRight-click to copy to clipboard", "class": "waypick", "alt": "%s"}' "$color" "$color" "$color"
}

# Handle command line arguments
case "$1" in
    pick)
        pick_color
        ;;
    copy)
        copy_to_clipboard
        ;;
    *)
        output_json
        ;;
esac 