#!/bin/bash
CONFIG_FILE="$HOME/.slack_status.conf"

# Colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Simple setup command
if [[ $1 == "setup" ]]; then
    echo "${green}Slack status updater setup${reset}"
    echo "${green}==========================${reset}"
    echo
    echo "You need to have your slack api token ready. If you don't have one,"
    echo "go to https://github.com/mivok/slack_status_updater and follow the"
    echo "instructions there for creating a new slack app."
    echo
    read -r -p "${green}Enter your slack token: ${reset}" TOKEN
    cat > "$CONFIG_FILE" <<EOF
# vim: ft=sh
# Configuration file for slack_status
# Set EXPIRES to 0 for no expiration or to seconds as an integer value
TOKEN=$TOKEN

PRESET_EMOJI_test=":white_check_mark:"
PRESET_TEXT_test="Testing status updater"
PRESET_EXPIRES_test=0

PRESET_EMOJI_zoom=":ghost:"
PRESET_TEXT_zoom="In a zoom meeting"
PRESET_EXPIRES_zoom=3600
EOF
    echo
    echo "A default configuration has been created at ${green}$CONFIG_FILE.${reset}"
    echo "you can edit that file to add additional presets. Otherwise you"
    echo "are good to go!"
    exit 0
fi

if [[ -f "$CONFIG_FILE" ]]; then
    . "$CONFIG_FILE"
else
    echo "${green}Slack status updater${reset}"
    echo "${green}====================${reset}"
    echo
    echo "Set your slack status based on preconfigured presets"
    echo
    echo "No configuration file found at $CONFIG_FILE"
    echo "Run $0 setup to create one"
    exit 1
fi

PRESET="$1"
shift
ADDITIONAL_TEXT="$*"

if [[ -z $PRESET ]]; then
    echo "Usage: $0 PRESET [ADDITIONAL TEXT]"
    echo
    echo "Set your slack status based on preconfigured presets"
    echo ""
    echo "If you provide additional text, then it will be appended to the"
    echo "preset status."
    echo
    echo "Presets are defined in ${green}$CONFIG_FILE${reset}"
    echo
    echo "Run '${green}$0 setup${reset}' to create a new configuration file"
    exit 1
fi

if [[ $PRESET == "none" ]]; then
    EMOJI=""
    TEXT=""
    EXPIRES=""
    echo "Resetting slack status to blank"
else
    eval "EMOJI=\$PRESET_EMOJI_$PRESET"
    eval "TEXT=\$PRESET_TEXT_$PRESET"
    eval "EXPIRES=\$PRESET_EXPIRES_$PRESET"

    if [[ -z $EMOJI || -z $TEXT ]]; then
        echo "${yellow}No preset found:${reset} $PRESET"
        echo
        echo "If this wasn't a typo, then you will want to add the preset to"
        echo "the config file at ${green}$CONFIG_FILE${reset} and try again."
        exit 1
    fi

    if [[ -n "$ADDITIONAL_TEXT" ]]; then
        TEXT="$TEXT $ADDITIONAL_TEXT"
    fi

    echo "Updating status to: ${yellow}$EMOJI ${green}$TEXT${reset}"
fi

if [[ $EXPIRES == "0" ]]; then
    EXPIRATION=0
else
    EPOCH=$(date +"%s")
    EXPIRATION=$(expr $EPOCH + $EXPIRES)
fi

PROFILE="{\"status_emoji\":\"$EMOJI\",\"status_text\":\"$TEXT\",\"status_expiration\":$EXPIRATION}"
RESPONSE=$(curl -s --data token="$TOKEN" \
    --data-urlencode profile="$PROFILE" \
    https://slack.com/api/users.profile.set)
if echo "$RESPONSE" | grep -q '"ok":true,'; then
    echo "${green}Status updated ok${reset}"
else
    echo "${red}There was a problem updating the status${reset}"
    echo "Response: $RESPONSE"
fi
