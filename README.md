# Dataset generator

> Helper scripts to export GreenHub's dataset to .csv files

## Features

- [x] Generate whole dataset to zip format
- [x] Single mode execution to export just one table
- [x] Separate zip files for main dataset tables (devices, samples)
- [x] Time elapsed counter
- [ ] Script logs

## Instructions

```shell
# First, set your env credentials
$ bash src/init.sh
# Passing no args, will query all tables
$ bash generate.sh
# Passing a name arg, will only query the given table
$ bash generate.sh "app_processes"
```

## Script Configuration

```bash
# First, set the table name
TABLE_NAME="devices"

# Calling run_query without args, will only append results to dataset.zip
run_query

# Adding 'zipped' arg will also create a separate TABLE_NAME.zip file
# and append results to dataset.zip
run_query "zipped"
```
