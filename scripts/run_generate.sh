#!/usr/bin/env sh

docker run --rm --name farmer-generator -dt -v "$PWD":/app dataset-generator sh -c "./src/generate.sh"
