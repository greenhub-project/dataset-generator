#!/usr/bin/env sh

function copy_env_file {
  cp .env.example .env
  echo ".env file copied!"
  echo "Please set the env credentials..."
  log_message ".env file copied"
}

function add_cronjob {
  (crontab -l && echo "$1 cd $WORK_DIR && bash ./generate.sh") | crontab -
  log_message "new cronjob created"
}

# Export all variables from a .env file
function export_vars {
  export $(egrep -v '^#' .env | xargs)
}

# Unset all variables from a .env file
function unset_vars {
  unset $(grep -v '^#' .env | sed -E 's/(.*)=.*/\1/' | xargs)
}

# Returns the last ID of samples table
function get_last_id {
  local QUERY="SELECT MAX(id) FROM samples"
  LAST_ID=$(mysql -B -N -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD -P$DB_PORT $DB_DATABASE -e "$QUERY")
  log_message "last ID set to = $LAST_ID"
}

# Exports database schema to a .sql file
function export_schema {
  local SCHEMA_FILE="$WORK_DIR/schema.sql"
  echo "Exporting database schema"
  log_message "exporting database schema"
  mysqldump -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD -P$DB_PORT --no-data $DB_DATABASE > "$SCHEMA_FILE"
}

# Routine to query a table into a csv file
function run_query {
  # Set files path
  local TXT_FILE="$WORK_DIR/$TABLE_NAME.txt"
  local CSV_FILE="$WORK_DIR/$TABLE_NAME.csv"
  local WHERE_CLAUSE=""
  
  echo -e "\n* Starting routine for [$TABLE_NAME]\n"
  log_message "starting routine for $TABLE_NAME"

  # Query table column names
  echo "Running query for column names"
  log_message "running query for column names"
  local QUERY="SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='$DB_NAME' AND TABLE_NAME='$TABLE_NAME';"
  mysql -B -N -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD -P$DB_PORT $DB_DATABASE -e "$QUERY" > "$CSV_FILE"

  # Transform newline to comma separated values
  log_message "converting newline to comma separated values"
  echo -e $(sed -n '1h;2,$H;${g;s/\n/,/g;p}' $CSV_FILE) > "$CSV_FILE"

  if [ -n "$LAST_ID" ]; then
    log_message "setting where clause"
    if [ "$TABLE_NAME" = "samples" ]; then
      WHERE_CLAUSE="WHERE id <= $LAST_ID"
    else
      WHERE_CLAUSE="WHERE sample_id <= $LAST_ID"
    fi
  fi

  # Query table into txt file
  echo "Running query for records"
  log_message "running query for records"
  QUERY="SELECT * FROM $TABLE_NAME $WHERE_CLAUSE INTO OUTFILE '$TXT_FILE' FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n';"
  mysql -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD -P$DB_PORT $DB_DATABASE -e "$QUERY" 2>/dev/null

  # Append contents to csv file
  echo "Appending contents to csv file"
  log_message "appending contents to $CSV_FILE"
  cat $TXT_FILE >> $CSV_FILE 2>&1

  # Create a separate zip file if argument is passed
  if [ "$1" = "zip" ]; then
    echo "Compressing to separate $TABLE_NAME.zip file"
    log_message "compressing to separate $TABLE_NAME.zip file"
    zip -r "$WORK_DIR/$TABLE_NAME.zip" $CSV_FILE
  fi

  if [ "$SINGLE_MODE" = true ]; then
    # Remove working files
    echo "Cleaning temporary files"
    log_message "cleaning temporary files"
    rm $TXT_FILE $CSV_FILE
    return 0
  fi

  echo "Compressing and appending to dataset.zip file"
  log_message "appending $CSV_FILE to dataset.zip file"
  zip -ur "$WORK_DIR/dataset.zip" $CSV_FILE

  # Remove working files
  echo "Cleaning temporary files"
  log_message "cleaning temporary files"
  rm $TXT_FILE $CSV_FILE
}

# Logs a message to a file
function log_message {
  local LOG_FILE="$WORK_DIR/dataset-generator.log"
  echo "[$(date +"%x %X")]$DOCKER_CTX INFO: $1" >> $LOG_FILE
}
