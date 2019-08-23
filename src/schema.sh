#!/usr/bin/env sh

. ./src/utils.sh

log_message "starting job"

export_schema

echo "Done!"

log_message "job done!"
