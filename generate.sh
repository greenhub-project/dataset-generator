#!/usr/bin/env bash

if [ ! -f ".env" ]; then
  echo ".env file not found!"
  bash ./src/init.sh
  exit 0
fi

. ./src/utils.sh

# Devices
TABLE_NAME="devices"
run_query

echo "Creating zip file..."

zip -r dataset.zip ~/dataset/*.csv

mv ~/dataset/dataset.zip $PUBLIC_PATH

echo "Cleaning temporary files..."
rm ~/dataset/*.csv


