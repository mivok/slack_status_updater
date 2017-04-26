#!/bin/bash
CONFIG_FILE="$HOME/.slack_status.conf"

# Simple setup command
if [[ $1 == "setup" ]]; then
    echo "Slack status updater setup"
    echo "=========================="
    echo
    echo "You need to have your slack api token ready. If you don't have one,"
    echo "go to https://api.slack.com/custom-integrations/legacy-tokens and"
    echo "click 'Create token' for your team. This should give you a token"
    echo "you can copy and paste here."
    echo
    read -r -p "Enter your slack token: " TOKEN
    cat > $CONFIG_FILE <<EOF
# vim: ft=sh
# Configuration file for slack_status
TOKEN=$TOKEN

PRESET_EMOJI_test=":check:"
PRESET_TEXT_test="Testing status updater"

PRESET_EMOJI_zoom=":zoom:"
PRESET_TEXT_zoom="In a zoom meeting"
EOF
    echo
    echo "A default configuration has been created at $CONFIG_FILE."
    echo "you can edit that file to add additional presets. Otherwise you"
    echo "are good to go!"
    exit 0
fi

if [[ -f "$CONFIG_FILE" ]]; then
    . "$CONFIG_FILE"
else
    echo "Slack status updater"
    echo "===================="
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
    echo "Presets are defined in $CONFIG_FILE"
    echo
    echo "Run '$0 setup' to create a new configuration file"
    exit 1
fi

if [[ $PRESET == "none" ]]; then
    EMOJI=""
    TEXT=""
else
    eval "EMOJI=\$PRESET_EMOJI_$PRESET"
    eval "TEXT=\$PRESET_TEXT_$PRESET"

    if [[ -z $EMOJI || -z $TEXT ]]; then
        echo "No preset found: $PRESET"
        echo
        echo "If this wasn't a typo, then you will want to add the preset to"
        echo "the config file at $CONFIG_FILE and try again."
        exit 1
    fi

    if [[ -n "$ADDITIONAL_TEXT" ]]; then
        TEXT="$TEXT $ADDITIONAL_TEXT"
    fi
fi

PROFILE="{\"status_emoji\":\"$EMOJI\",\"status_text\":\"$TEXT\"}"
echo "Updating status to: $EMOJI $TEXT"
curl -s -o /dev/null --data token="$TOKEN" \
    --data-urlencode profile="$PROFILE" \
    https://slack.com/api/users.profile.set
