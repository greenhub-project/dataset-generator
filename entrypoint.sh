#!/usr/bin/env sh

source /home/user/.env

echo "Executing -> \"/home/user/src/$SCRIPT.sh\" \"$TABLE\""

sh "/home/user/src/$SCRIPT.sh" "$TABLE"
