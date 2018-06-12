#!/usr/bin/env bash

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
  LAST_ID=$(mysql -B -N -u$DB_USER -p$DB_PASS $DB_NAME -e "$QUERY" 2>/dev/null | grep -v "mysql: [Warning] Using a password on the command line interface can be insecure.")
}

# Routine to query a table into a csv file
function run_query {
  # Set files path
  local TXT_FILE="$TMP_DIR/$TABLE_NAME.txt"
  local CSV_FILE="$TABLE_NAME.csv"
  local WHERE_CLAUSE=""
  
  echo -e "\n* Starting routine for [$TABLE_NAME]\n"
  log_message "starting routine for $TABLE_NAME"

  # Check if old temp file exists, then remove it
  if [ -f $TXT_FILE ]; then
    echo $USER_PASS | sudo -S rm $TXT_FILE
    log_message "removing preexisting temp file - $TXT_FILE"
  fi

  # Query table column names
  echo "Running query for column names"
  log_message "running query for column names"
  local QUERY="SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='$DB_NAME' AND TABLE_NAME='$TABLE_NAME';"
  mysql -B -N -u$DB_USER -p$DB_PASS $DB_NAME -e "$QUERY" > "$CSV_FILE" 2>/dev/null | grep -v "mysql: [Warning] Using a password on the command line interface can be insecure."

  # Transform newline to comma separated values
  echo -e $(sed -n '1h;2,$H;${g;s/\n/,/g;p}' $CSV_FILE) > "$CSV_FILE"
  log_message "converting newline to comma separated values"

  if [ -n "$LAST_ID" ]; then
    log_message "setting where clause, last sample is: $LAST_ID"
    WHERE_CLAUSE="WHERE sample_id <= $LAST_ID"
  fi

  # Query table into txt file
  echo "Running query for records"
  log_message "running query for records"
  QUERY="SELECT * FROM $TABLE_NAME $WHERE_CLAUSE INTO OUTFILE '$TXT_FILE' FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n';"
  mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "$QUERY" 2>/dev/null | grep -v "mysql: [Warning] Using a password on the command line interface can be insecure."

  # Change ownership of txt file
  echo $USER_PASS | sudo -S chown $USER:$USER $TXT_FILE
  log_message "changing ownership of $TXT_FILE"

  # Move txt file to working directory
  mv $TXT_FILE $WORK_DIR
  TXT_FILE="$TABLE_NAME.txt"
  log_message "moving $TXT_FILE to working directory"

  # Append contents to csv file
  echo "Appending contents to csv file"
  log_message "appending contents to $CSV_FILE"
  cat $TXT_FILE >> $CSV_FILE 2>&1

  # Create a separate zip file if argument is passed
  if [ "$1" = "zip" ]; then
    echo "Compressing to separate $TABLE_NAME.zip file"
    log_message "compressing to separate $TABLE_NAME.zip file"
    zip -r "$TABLE_NAME.zip" $CSV_FILE
    log_message "moving $TABLE_NAME.zip to public path"
    mv "$TABLE_NAME.zip" $PUBLIC_PATH
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
  zip -ur dataset.zip $CSV_FILE

  # Remove working files
  echo "Cleaning temporary files"
  log_message "cleaning temporary files"
  rm $TXT_FILE $CSV_FILE
}

# Convert seconds to human readable time
function display_time {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%d days ' $D
  (( $H > 0 )) && printf '%d hours ' $H
  (( $M > 0 )) && printf '%d minutes ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
  printf '%d seconds\n' $S
}

# Logs a message to a file
function log_message {
  local LOG_FILE="dataset-generator.log"
  echo "[$(date +"%x %X")] INFO: $1" >> $LOG_FILE
}
