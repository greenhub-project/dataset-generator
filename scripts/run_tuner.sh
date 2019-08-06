#!/usr/bin/env sh

export $(egrep -v '^#' .env | xargs)

docker run --rm -it owski/mysqltuner --host $DB_HOST \
--user $DB_USERNAME \
--pass $DB_PASSWORD \
--forcemem 31411

unset $(grep -v '^#' .env | sed -E 's/(.*)=.*/\1/' | xargs)

echo "Done!"
