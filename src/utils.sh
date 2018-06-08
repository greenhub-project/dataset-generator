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
  # Set files path
  TXT_FILE="$TMP_DIR/$TABLE_NAME.txt"
  CSV_FILE="$WORK_DIR/$TABLE_NAME.csv"
  
  echo "Starting procedure for $TABLE_NAME..."

  # Check if old temp file exists, then remove it
  if [ -f $TXT_FILE ]; then
    echo $USER_PASS | sudo -S rm $TXT_FILE
  fi

  # Query table column names
  echo "Running query for column names..."
  QUERY="SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='$DB_NAME' AND TABLE_NAME='$TABLE_NAME';"
  mysql -B --disable-column-names -u$DB_USER -p$DB_PASS $DB_NAME -e $QUERY > $CSV_FILE

  # Transform newline to comma separated values
  echo -e $(sed -n '1h;2,$H;${g;s/\n/,/g;p}' $CSV_FILE) > $CSV_FILE

  # Query table into txt file
  echo "Running query for records..."
  QUERY="SELECT * FROM $TABLE_NAME INTO OUTFILE '$TXT_FILE' FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n';"
  mysql -u$DB_USER -p$DB_PASS $DB_NAME -e $QUERY

  # Change ownership of txt file
  echo $USER_PASS | sudo -S chown $USER:$USER $TXT_FILE

  # Move txt file to working directory
  mv $TXT_FILE $WORK_DIR

  # Append contents to csv file
  echo "Appending contents to csv file..."
  cat $TXT_FILE >> $CSV_FILE 2>&1

  # Remove txt file
  echo "Cleaning temporary files..."
  rm $TXT_FILE
}