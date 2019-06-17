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
    echo "Set your slack status to away/back"
    echo
    echo "No configuration file found at $CONFIG_FILE"
    exit 1
fi

STATE="$1"

if [[ $STATE != "away" && $STATE != "back" ]]; then
    echo "Usage: $0 [away|back]"
    echo
    echo "Set your slack status to away or back"
    exit 1
fi

if [[ $STATE == "back" ]]; then
    STATE=auto
fi

curl -s --data token="$TOKEN" \
    --data presence="$STATE" \
    https://slack.com/api/users.setPresence | \
    grep -Eq '"ok": ?true' && \
        echo "${green}Away status updated ok${reset}" || \
        echo "${red}There was a problem updating the away status${reset}"
