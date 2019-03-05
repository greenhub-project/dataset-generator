#!/usr/bin/env sh

. ./src/utils.sh

echo "Loading .env file"
export_vars

mkdir -p data
docker run --rm -it -v "$PWD/data":/app/data dataset-generator sh -c "./generate.sh 'devices'"

echo "Unsetting .env file"
unset_vars

echo "Done!"
