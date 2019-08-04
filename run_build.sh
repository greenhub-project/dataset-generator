#!/usr/bin/env sh

docker rmi dataset-generator && docker build -t dataset-generator .
