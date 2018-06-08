#!/usr/bin/env bash

if [ ! -f ".env" ]; then
  echo ".env file not found!"
  bash ./src/init.sh
  exit 0
fi

. ./src/utils.sh

cd $WORK_DIR
echo "Working directory:\n$(pwd)"

# Devices
TABLE_NAME="devices"
run_query

echo "Compressing to zip file..."
zip -r dataset.zip *.csv

echo "Moving zip file to destination..."
mv dataset.zip $PUBLIC_PATH

echo "Cleaning all temporary files..."
rm *.csv

echo "Done!"
cd -
