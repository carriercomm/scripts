#!/bin/bash

USER="backup"
PW="backup"

FILE="/root/bkp_db/`date +%Y$m%d_%H%M`.sql"
mysqldump --add-drop-database --add-locks --create-options --extended-insert --lock-tables --quick --quote-names --triggers --routines --host=localhost --user=$USER --password=$PW maxlan > $FILE
gzip $FILE
