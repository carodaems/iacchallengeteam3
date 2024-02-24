#!/bin/sh

MESSAGE="$1"
EMBED_JSON="$(cat <<EOF
{
 "embeds": [
   {
     "title": "GitLab CI/CD Notification",
     "description": "$MESSAGE",
     "color": 7506394
   }
 ]
}
EOF
)"

curl -X POST -H 'Content-Type: application/json' \
 -d "$EMBED_JSON" \
 $DISCORD_WEBHOOK_URL