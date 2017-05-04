#!/bin/bash
read -r EMOJI TEXT <<<"$*"

if [[ -z $EMOJI ]]; then
    STATUS_TEXT="Status has been cleared"
else
    STATUS_TEXT="Status updated to\n$EMOJI $TEXT"
fi


PROFILE="{\"status_emoji\":\"$EMOJI\",\"status_text\":\"$TEXT\"}"
# Note: TOKEN should be set outside this script
curl -s --data token="$TOKEN" \
    --data-urlencode profile="$PROFILE" \
    https://slack.com/api/users.profile.set | \
    grep -q '^{"ok":true,' && \
        echo -e "$STATUS_TEXT" || \
        echo "There was a problem updating the status"
