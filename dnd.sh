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
    echo "Set and unset your slack Do Not Disturb mode"
    echo
    echo "No configuration file found at $CONFIG_FILE"
    exit 1
fi

function print_usage() {
    echo "Usage: $0 [off|DURATION]"
    echo
    echo "Set or unset your slack Do Not Disturb mode"
    echo
    echo "DURATION should be one or more positive numbers, each followed by a unit."
    echo "Supported units are m/minute/minutes and h/hour/hours."
    echo
    echo "Some examples:"
    echo
    echo "  $0 1 hour"
    echo "  $0 2h 10m"
    echo "  $0 10 m"
    echo "  $0 off"
}

if [[ "$#" -eq 0 ]]; then
    print_usage
    exit 1
fi

DURATION=0
if [[ "$@" != off ]]; then
    while [[ $# -gt 0 ]]; do
        timespec="$1"
        shift
        quantity=$(expr "$timespec" : '\([0-9]\+\)')
        if [[ $? -ne 0 ]]; then
            # expr is bonkers and exits with non-zero exit code if the match equals 0.
            # Normally this would be annoying but we can use that behaviour to not allow 0 quantities :-)
            echo "Invalid duration: $timespec"
            echo
            print_usage
            exit 1
        fi
        unit=${timespec#$quantity}
        if [[ -z "$unit" ]]; then
            # Allow unit as separate word from quantity.
            unit="$1"
            shift
        fi
        case "$unit" in
            m|minute|minutes)
            let DURATION+=quantity
            ;;
            h|hour|hours)
            let DURATION+=quantity*60
            ;;
            *)
            echo "Invalid duration: $timespec"
            echo
            print_usage
            exit 1
            ;;
        esac
    done
fi

function call_slack() {
    if [[ $DURATION -eq 0 ]]; then
        curl -s --data token="$TOKEN" \
            https://slack.com/api/dnd.endDnd # or endSnooze?
    else
        curl -s --data token="$TOKEN" \
            --data num_minutes=$DURATION \
            https://slack.com/api/dnd.setSnooze
    fi
}

call_slack | \
    grep -Eq '"ok": ?true' && \
        echo "${green}Do Not Disturb mode updated ok${reset}" || \
        echo "${red}There was a problem updating the Do Not Disturb mode${reset}"
