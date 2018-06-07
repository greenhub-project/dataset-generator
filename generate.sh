#!/usr/bin/env bash

if [ ! -f .env ]; then
  echo ".env file not found!"
  bash ./src/init.sh
  exit 0
fi

. ./src/utils.sh


