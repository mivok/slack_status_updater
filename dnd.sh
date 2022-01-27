#!/bin/bash
CONFIG_FILE="$HOME/.slack_status.conf"

# Colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

if [[ -f "$CONFIG_FILE" ]]; then
    . "$CONFIG_FILE"
else
    echo "${green}Slack status updater${reset}"
    echo "${green}====================${reset}"
    echo
    echo "Toggle your slack do not disturb on/off"
    echo
    echo "No configuration file found at $CONFIG_FILE"
    exit 1
fi

STATE="$1"

if [[ $STATE != "on" && $STATE != "off" ]]; then
    echo "Usage: $0 [on|off]"
    echo
    echo "Set your slack do not distrubn on or off"
    exit 1
fi

# The Slack API doesn't seem to let you set an indefinite DND, so you have to provide a time in minutes
# TODO: Allow users to configure this, but for now 60 minutes seems fine
if [[ $STATE == "on" ]]; then
    STATE="60"
else
    STATE="0"
fi

curl -s --data token="$TOKEN" \
    --data num_minutes="$STATE" \
    https://slack.com/api/dnd.setSnooze | \
    grep -Eq '"ok": ?true' && \
        echo "${green}Do not distrub updated ok${reset}" || \
        echo "${red}There was a problem toggling do not distrub${reset}"
