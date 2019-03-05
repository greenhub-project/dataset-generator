#!/usr/bin/env sh

. ./src/utils.sh

echo "Loading .env file"
export_vars

mkdir -p data
docker run --rm -it -v "$PWD/data":/app/data dataset-generator sh -c "./schema.sh"

echo "Unsetting .env file"
unset_vars

echo "moving schema.sql to public path"

# mv "$WORK_DIR/schema.sql" $PUBLIC_PATH

echo "Done!"
