#!/usr/bin/env sh

mkdir -p data
docker run --rm --name farmer-generator -dt -v "$PWD":/app dataset-generator sh -c "./src/generate.sh"
