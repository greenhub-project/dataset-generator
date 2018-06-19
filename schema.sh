#!/usr/bin/env bash

. ./src/utils.sh

if [ ! -f ".env" ]; then
  echo ".env file not found!"
  log_message ".env file not found!"
  copy_env_file
  add_cronjob "0 0 * * 0"
  exit 0
fi

log_message "starting job"

START_TIME=$(date +%s)

echo "Loading .env file"
log_message "loading .env file"
export_vars

cd $WORK_DIR
echo -e "\nWorking directory:\n$(pwd)"
log_message "changing to working directory"

export_schema

echo "Unsetting .env file"
log_message "unsetting .env file variables"
unset_vars

echo "Done!"

END_TIME=$(date +%s)
DIFF_TIME=$((END_TIME-START_TIME))

echo -e "\nTime elapsed: $(display_time $DIFF_TIME)"
log_message "time elapsed: $(display_time $DIFF_TIME)"
log_message "job done!"

cd -
