#!/bin/bash
read -r EMOJI TEXT <<<"$*"

if [[ -z $EMOJI ]]; then
    STATUS_TEXT="Status has been cleared"
else
    STATUS_TEXT="Status updated to\n$EMOJI $TEXT"
fi


PROFILE="{\"status_emoji\":\"$EMOJI\",\"status_text\":\"$TEXT\"}"
RESPONSE=$(curl -s --data token="$TOKEN" \
    --data-urlencode profile="$PROFILE" \
    https://slack.com/api/users.profile.set)
if echo "$RESPONSE" | grep -q '"ok":true,'; then
    echo "Status updated"
else
    echo "There was a problem updating the status"
    echo "Response: $RESPONSE"
fi
