#!/usr/bin/env sh

. ./src/utils.sh

SQL=$(cat scripts/$SQL_SCRIPT)

get_last_id

TABLE_NAME="samples"
run_join_query "$SQL"

echo "Done!"
log_message "job done!"