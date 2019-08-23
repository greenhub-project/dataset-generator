# Dataset generator

> Helper scripts to export GreenHub's dataset to .csv files

## Features

- [x] Generate whole dataset to 7z format
- [x] Single mode execution to export just one table
- [x] Separate 7z files for main dataset tables (devices, samples)
- [x] .env file to store credentials
- [x] Script logs
- [x] Exports database schema
- [x] Containerized setup

## Requirements

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Instructions

```shell
# Run the application in the background
$ docker-compose up -d
# Display the logs
$ docker-compose logs
```

## Script Configuration

```bash
# First, set the table name
TABLE_NAME="devices"

# Calling run_query without args, will only append results to dataset.7z
run_query

# Adding 'zip' arg will also create a separate TABLE_NAME.7z file
# and append results to dataset.7z
run_query "zip"
```
