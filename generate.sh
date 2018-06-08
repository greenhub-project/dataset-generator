#!/usr/bin/env bash

if [ ! -f ".env" ]; then
  echo ".env file not found!"
  bash ./src/init.sh
  exit 0
fi

. ./src/utils.sh

START_TIME=$(date +%s)

echo "Loading .env file..."
export_vars

cd $WORK_DIR
echo -e "\nWorking directory:\n$(pwd)"

if grep -Fxq "$1" "tables.conf"
then
  echo -e "\n>> Executing in SINGLE MODE\n"
  SINGLE_MODE=true
  TABLE_NAME="$1"
  run_query "zipped"
else
  TABLE_NAME="devices"
  run_query "zipped"

  TABLE_NAME="samples"
  run_query "zipped"

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

  echo "Moving zip file to destination..."
  mv dataset.zip $PUBLIC_PATH
fi

echo "Unsetting .env file..."
unset_vars

echo "Done!"

END_TIME=$(date +%s)

echo -e "\nTime elapsed: $((END_TIME-START_TIME))\n"

cd -
