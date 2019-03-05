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

if grep -Fxq "$1" "tables.conf"
then
  echo -e "\n>> Executing in SINGLE MODE"
  log_message "running in SINGLE MODE"

  SINGLE_MODE=true
  TABLE_NAME="$1"
  run_query "zip"
else
  TABLE_NAME="devices"
  run_query "zip"

  get_last_id

  TABLE_NAME="samples"
  run_query "zip"

  TABLE_NAME="network_details"
  run_query

  TABLE_NAME="battery_details"
  run_query

  TABLE_NAME="storage_details"
  run_query

  TABLE_NAME="cpu_statuses"
  run_query

  TABLE_NAME="settings"
  run_query

  TABLE_NAME="location_providers"
  run_query

  TABLE_NAME="features"
  run_query

  # For now skip app_processes because is too big to handle
  # TABLE_NAME="app_processes"
  # run_query

  echo "Moving zip file to destination"
  log_message "moving dataset.zip to public path"
  mv dataset.zip $PUBLIC_PATH
fi

echo "Unsetting .env file"
log_message "unsetting .env file variables"
unset_vars

echo "Done!"
log_message "job done!"
