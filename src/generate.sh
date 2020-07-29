#!/usr/bin/env sh

. ./src/utils.sh

log_message "starting job"

echo "Bag size set to = $BAG"
log_message "bag size set to = $BAG"

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

  get_last_id "samples"

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

  TABLE_NAME="app_processes"
  run_query
fi

echo "Done!"
log_message "job done!"
