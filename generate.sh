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
echo -e "Working directory:\n$(pwd)\n"

# Devices
TABLE_NAME="devices"
run_query

echo "Compressing to zip file..."
zip -r dataset.zip *.csv

echo "Moving zip file to destination..."
mv dataset.zip $PUBLIC_PATH

echo "Cleaning all temporary files..."
rm *.csv

echo "Unsetting .env file..."
unset_vars

echo "Done!"
cd -
