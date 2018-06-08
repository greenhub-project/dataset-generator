# Dataset generator

> Helper scripts to export GreenHub's dataset to .csv files

## Instructions

```shell
$ bash src/init.sh
# Before, set your env credentials
$ bash generate.sh
```

## Options

```bash
# First set the table name
TABLE_NAME="devices"

# Calling run_query without args, will only append results to dataset.zip
run_query

# Adding 'zipped' arg will also create a separate TABLE_NAME.zip file
# and append results to dataset.zip
run_query "zipped"
```
