#!/usr/bin/env sh

PUBLIC_DIR=${1:-data/}

mkdir -p data
docker run --rm --name farmer-generator -dt -v "$PWD/data":/app/data dataset-generator sh -c "./src/generate.sh"
