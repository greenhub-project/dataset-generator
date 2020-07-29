#!/usr/bin/env sh

. ./src/utils.sh

SQL=$(cat scripts/$SQL_SCRIPT)

TABLE_NAME="$TABLE"
ORDER_CLAUSE="ORDER BY id"

get_last_id "$TABLE_NAME"

run_join_query "$SQL"

echo "Done!"
log_message "job done!"