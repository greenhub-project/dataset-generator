#!/usr/bin/env sh

docker-compose down
docker rmi dataset-generator:latest
docker-compose up
