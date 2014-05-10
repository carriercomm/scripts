#!/bin/bash
#SSH
SERVER="maxlan.de"
USER="maxlan"
DIR="httpdocs/sync_logs"
#MySQL
MYSQL_USER="maxlan"
MYSQL_DB="maxlan"

if [ "$1" == "" ]; then
  echo "Usage: $0 <ziel>"
  echo " <ziel>"
  echo "  lan   - WEB -> LAN"
  echo "  web   - LAN -> WEB"
  exit 0
fi

LOG="/root/sync_log/db_$1_`date +%Y$m%d_%H%M`.log"
DB="/root/sync_db/$MYSQL_DB.$1.`date +%Y$m%d_%H%M`.sql"

if [ "$1" == "lan" ]; then
  echo "#!/bin/bash" > /tmp/sync_db.sh
  echo "ssh $USER@$SERVER \"mysqldump --add-drop-database --add-locks --create-options --extended-insert --lock-tables --quick --quote-names --triggers --routines --host=localhost --user=$MYSQL_USER -p $MYSQL_DB\" > $DB" >> /tmp/sync_db.sh
  echo "echo \"\"" >> /tmp/sync_db.sh
  echo "echo \"#############################\"" >> /tmp/sync_db.sh
  echo "echo \"DB gezogen - Einspielen mit der Any-Taste\"" >> /tmp/sync_db.sh
  echo "read" >> /tmp/sync_db.sh
  echo "mysql -u $MYSQL_USER -p $MYSQL_DB < $DB" >> /tmp/sync_db.sh
  echo "gzip $DB" >> /tmp/sync_db.sh
  echo "echo \"\"" >> /tmp/sync_db.sh
  echo "echo \"#############################\"" >> /tmp/sync_db.sh
  echo "echo \"Sync fertig - weiter mit der Any-Taste\"" >> /tmp/sync_db.sh
  echo "read" >> /tmp/sync_db.sh
  chmod u+x /tmp/sync_db.sh
  screen -S db_to_$1 /tmp/sync_db.sh
elif [ "$1" == "web" ]; then
  echo "#!/bin/bash" > /tmp/sync_db.sh
  echo "mysqldump --add-drop-database --add-locks --create-options --extended-insert --lock-tables --quick --quote-names --triggers --routines --host=localhost --user=$MYSQL_USER -p $MYSQL_DB > $DB" >> /tmp/sync_db.sh
  echo "gzip $DB" >> /tmp/sync_db.sh
  echo "echo \"\"" >> /tmp/sync_db.sh
  echo "echo \"#############################\"" >> /tmp/sync_db.sh
  echo "echo \"Lade Datei hoch nach $DIR/\"" >> /tmp/sync_db.sh
  echo "scp $DB* $USER@$SERVER:$DIR/" >> /tmp/sync_db.sh
  echo "echo \"\"" >> /tmp/sync_db.sh
  echo "echo \"#############################\"" >> /tmp/sync_db.sh
  echo "echo \"Uebertragung fertig - Einspielen mit der Any-Taste\"" >> /tmp/sync_db.sh
  echo "ssh $USER@$SERVER \"gzip -d $DIR/`basename $DB`.gz; mysql -u $MYSQL_USER -p $MYSQL_DB < $DIR/`basename $DB`; gzip $DIR/`basename $DB`\"" >> /tmp/sync_db.sh
  echo "echo \"#############################\"" >> /tmp/sync_db.sh
  echo "echo \"Sync fertig - weiter mit der Any-Taste\"" >> /tmp/sync_db.sh
  echo "read" >> /tmp/sync_db.sh
  chmod u+x /tmp/sync_db.sh
  screen -S db_to_$1 /tmp/sync_db.sh
fi
