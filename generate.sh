#!/usr/bin/env bash

if [ ! -f ".env" ]; then
  echo ".env file not found!"
  bash ./src/init.sh
  exit 0
fi

. ./src/utils.sh

echo "Loading .env file..."
export_vars

cd $WORK_DIR
echo -e "\nWorking directory:\n$(pwd)"

TABLE_NAME="devices"
run_query

TABLE_NAME="samples"
run_query

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

TABLE_NAME="app_processes"
run_query

echo "Moving zip file to destination..."
mv dataset.zip $PUBLIC_PATH

echo "Unsetting .env file..."
unset_vars

echo "Done!"
cd -
