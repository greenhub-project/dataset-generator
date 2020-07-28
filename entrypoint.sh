#!/usr/bin/env sh

source /home/user/.env

if [ "$SCRIPT" = "generate" ]; then
  echo "Executing -> \"/home/user/src/$SCRIPT.sh\" \"$TABLE\""
  sh "/home/user/src/$SCRIPT.sh" "$TABLE"
else
  echo "Executing -> \"/home/user/src/$SCRIPT.sh\""
  sh "/home/user/src/$SCRIPT.sh"
fi
