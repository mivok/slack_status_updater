#!/bin/bash
CONFIG_FILE="$HOME/.slack_status.conf"
[[ -f "$CONFIG_FILE" ]] || exit 1

# shellcheck disable=SC1090
. "$CONFIG_FILE"

# Split the query into a preset and additional text
read -r QUERY_PRESET QUERY_TEXT <<<"$*"

PRESETS=("${!PRESET_EMOJI_@}")

cat <<EOF
{
  "variables": {
    "TOKEN": "$TOKEN"
  },
  "items": [
EOF

for EMOJI_VARNAME in "${PRESETS[@]}"; do
    PRESET=${EMOJI_VARNAME/PRESET_EMOJI_/}
    TEXT_VARNAME="PRESET_TEXT_$PRESET"
    if [[ ${PRESET:0:${#QUERY_PRESET}} != "$QUERY_PRESET" ]]; then
        continue
    fi
    if [[ -n "$QUERY_TEXT" ]]; then
        QUERY_TEXT=" $QUERY_TEXT"
    fi
    cat <<EOF
    {
        "title": "Slack status preset: $PRESET",
        "subtitle": "Set slack status to: ${!EMOJI_VARNAME} ${!TEXT_VARNAME}${QUERY_TEXT}",
        "arg": "${!EMOJI_VARNAME} ${!TEXT_VARNAME}${QUERY_TEXT}"
    },
EOF
done

cat <<EOF
    {
        "title": "Slack status preset: none",
        "subtitle": "Clear any existing status",
        "arg": ""
    }
EOF
echo "]}"
