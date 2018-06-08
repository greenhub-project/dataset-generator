#!/usr/bin/env bash

# Export all variables from a .env file
function export_vars {
  export $(egrep -v '^#' .env | xargs)
}

# Unset all variables from a .env file
function unset_vars {
  unset $(grep -v '^#' .env | sed -E 's/(.*)=.*/\1/' | xargs)
}

# Routine to query a table into a csv file
function run_query {
  # Set csv file path
  CSV_FILE="$TMP_DIR/$TABLE_NAME.csv"
  
  # Check if old temp file exists, then remove it
  if [ -f $CSV_FILE ]; then
    echo $USER_PASS | sudo -S rm $CSV_FILE
  fi

  # Query table column names
  QUERY="SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='$DB_NAME' AND TABLE_NAME='$TABLE_NAME';"
  mysql -B --disable-column-names -u$DB_USER -p$DB_PASS $DB_NAME -e $QUERY > "$WORK_DIR/$TABLE_NAME.info"

  # Transform newline to comma separated values
  echo -e $(sed -n '1h;2,$H;${g;s/\n/,/g;p}' "$WORK_DIR/$TABLE_NAME.info") > "$WORK_DIR/$TABLE_NAME.info"

  # Query table into csv file
  QUERY="SELECT * FROM $TABLE_NAME INTO OUTFILE '$CSV_FILE' FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n';"
  mysql -u$DB_USER -p$DB_PASS $DB_NAME -e $QUERY

  # Change ownership of csv file
  echo $USER_PASS | sudo -S chown $USER:$USER $CSV_FILE

  # Move csv file to working directory
  mv $CSV_FILE $WORK_DIR

  # Remove header file
  rm "$WORK_DIR/$TABLE_NAME.info"
}