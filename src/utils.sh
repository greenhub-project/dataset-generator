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
  LAST_ID=$(mysql -B -N --protocol=tcp -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD -P$DB_PORT $DB_DATABASE -e "$QUERY")
  log_message "last ID set to = $LAST_ID"
}

# Exports database schema to a .sql file
function export_schema {
  local SCHEMA_FILE="$WORK_DIR/schema.sql.gz"
  echo "Exporting database schema"
  log_message "exporting database schema"
  mysqldump --protocol=tcp --no-data -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD \
  -P$DB_PORT  $DB_DATABASE > "$SCHEMA_FILE"
}

# Routine to query a table into a csv file
function run_query {
  # Set files path
  local SEARCH_KEY="id"
  local WHERE_CLAUSE=""
  local CSV_FILE="$WORK_DIR/$TABLE_NAME.csv"
  local CSV_REGEX="$WORK_DIR/$TABLE_NAME.*.csv"
  local LOWER_BOUND=1
  local UPPER_BOUND=$BAG
  local x=1
  
  echo -e "\n* Starting routine for [$TABLE_NAME]\n"
  log_message "starting routine for $TABLE_NAME"

  if [ -n "$LAST_ID" ]; then
    log_message "setting where clause"
    if [ "$TABLE_NAME" != "samples" ]; then
      SEARCH_KEY="sample_id"
    fi
    WHERE_CLAUSE="WHERE $SEARCH_KEY <= $LAST_ID"
  fi

  TOTAL=$(mysql -B -N -q --protocol=tcp -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD -P$DB_PORT $DB_DATABASE -e "SELECT MAX(id) FROM $TABLE_NAME $WHERE_CLAUSE")
  REF_ID=$TOTAL
  UPPER_BOUND=$((UPPER_BOUND > REF_ID ? REF_ID : UPPER_BOUND))

  echo "Total of records: $TOTAL"
  log_message "total of records: $TOTAL"

  TOTAL=$((TOTAL/BAG+1))

  echo "Total of pages: $TOTAL"
  log_message "total number of pages: $TOTAL"

  # Query table into txt file
  echo "Running query for records"
  log_message "running query for records"

  while [ "$x" -le "$TOTAL" ]
    do
      echo "<$TABLE_NAME> processing page ($x/$TOTAL)"
      log_message "<$TABLE_NAME> processing page ($x/$TOTAL) => rows $LOWER_BOUND:$UPPER_BOUND"
      mysql -B -q --protocol=tcp -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD -P$DB_PORT $DB_DATABASE \
      -e "SELECT * FROM $TABLE_NAME WHERE id BETWEEN $LOWER_BOUND AND $UPPER_BOUND" \
      | tr '\t' ',' > "$WORK_DIR/$TABLE_NAME.$x.csv"
      LOWER_BOUND=$((UPPER_BOUND+1))
      UPPER_BOUND=$((UPPER_BOUND+BAG))
      UPPER_BOUND=$((UPPER_BOUND > REF_ID ? REF_ID : UPPER_BOUND))
      x=$((x+1))
    done

  # Merge text part files into single text file
  echo "Merging temporary files"
  log_message "merging temporary files"
  cat $(ls -1v $CSV_REGEX) > "$CSV_FILE" && rm $(ls $CSV_REGEX)

  # Create a separate zip file if argument is passed
  if [ "$1" = "zip" ]; then
    echo "Compressing to separate $TABLE_NAME.7z file"
    log_message "compressing to separate $TABLE_NAME.7z file"
    # zip -rj "$WORK_DIR/$TABLE_NAME.zip" "$CSV_FILE"
    7z a -t7z -m0=LZMA2:d64k:fb32 -ms=8m -mmt=30 -mx=1 -- "$WORK_DIR/$TABLE_NAME.7z" "$CSV_FILE"
  fi

  if [ "$SINGLE_MODE" = true ]; then
    # Remove working files
    echo "Removing temporary files"
    log_message "removing tempory files"
    rm $CSV_FILE
    return 0
  fi

  echo "Compressing and appending to dataset.7z file"
  log_message "appending $CSV_FILE to dataset.7z file"
  # zip -urj "$WORK_DIR/dataset.zip" "$CSV_FILE"
  7z a -t7z -sdel -m0=LZMA2:d64k:fb32 -ms=8m -mmt=30 -mx=1 -- "$WORK_DIR/dataset.7z" "$CSV_FILE"
}

# Logs a message to a file
function log_message {
  local LOG_FILE="$WORK_DIR/dataset-generator.log"
  echo "[$(date +"%x %X")]$DOCKER_CTX INFO: $1" >> $LOG_FILE
}
