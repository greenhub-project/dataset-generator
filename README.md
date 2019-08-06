# Dataset generator

> Helper scripts to export GreenHub's dataset to .csv files

## Features

- [x] Generate whole dataset to 7z format
- [x] Single mode execution to export just one table
- [x] Separate 7z files for main dataset tables (devices, samples)
- [x] .env file to store credentials
- [x] Script logs
- [x] Automatically creates a cronjob to execute
- [x] Exports database schema
- [x] Database configuration tuner
- [x] Containerized setup

## Instructions

```shell
# First build the custom docker image
$ bash scripts/run_build.sh
# Export all tables
$ bash scripts/run_generate.sh
# If you want to run only for a single table, change the script as following:
$ docker run --rm -it -v "$PWD/data":/app/data dataset-generator sh -c "./src/generate.sh samples"
# Export database schema
$ bash scripts/run_schema.sh
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
