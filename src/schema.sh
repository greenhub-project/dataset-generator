#!/usr/bin/env sh

. ./src/utils.sh

if [ ! -f ".env" ]; then
  echo ".env file not found!"
  log_message ".env file not found!"
  copy_env_file
  exit 0
fi

log_message "starting job"

echo "Loading .env file"
log_message "loading .env file"
export_vars

export_schema

echo "Unsetting .env file"
log_message "unsetting .env file variables"
unset_vars

echo "Done!"

log_message "job done!"
