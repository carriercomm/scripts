#!/bin/bash

read -s -p "MySQL root PW: " PW
echo ""

rm /tmp/master_data.sql > /dev/null 2>&1

# Auf dem Master die Tabellen locken
echo "# Auf dem Master die Tabellen locken"
ssh 10.10.1.252 "echo 'FLUSH TABLES WITH READ LOCK;' | mysql -u root --password=$PW";

# Slave aufraumen
echo "# Slave aufraumen"
echo "DROP DATABASE maxlan;" | mysql -u root --password=$PW
echo "CREATE DATABASE maxlan;" | mysql -u root --password=$PW

# DB-Dump auf dem Master erstellen und hier hin kopieren
echo "# DB-Dump auf dem Master erstellen und hier hin kopieren"
ssh 10.10.1.252 "mysqldump --add-drop-database --add-locks --create-options --extended-insert --lock-tables --quick --quote-names --triggers --routines --host=localhost --user=root --password=$PW maxlan > /tmp/master_data.sql"
scp 10.10.1.252:/tmp/master_data.sql /tmp/master_data.sql
ssh 10.10.1.252 "rm /tmp/master_data.sql"

# Master-Infos holen
echo "# Master-Infos holen"
MASTER=`ssh 10.10.1.252 "echo 'show master status;' | mysql -u root --password=$PW | grep -v File" | tr "\t" " "`
BINLOG=`echo $MASTER | cut -d " " -f 1`
POS=`echo $MASTER | cut -d " " -f 2`

# DB-Dump einspielen
echo "# DB-Dump einspielen"
echo "stop slave;" | mysql -u root --password=$PW
mysql -u root --password=$PW maxlan < /tmp/master_data.sql

# Slave einstellen
echo "# Slave einstellen"
echo "CHANGE MASTER TO MASTER_LOG_FILE='$BINLOG';" | mysql -u root --password=$PW
echo "CHANGE MASTER TO MASTER_LOG_POS=$POS;" | mysql -u root --password=$PW

# Slave starten
echo "# Slave starten"
echo "start slave;" | mysql -u root --password=$PW

# Status anzeigen
echo "# Status anzeigen"
SLAVE=`echo "show slave status" | mysql -u root --password=$PW | grep -v Slave_IO_Running | tr "\t" ";"`
echo "Master-Log: $BINLOG"
echo "Master-Pos: $POS"
echo "Slave-Log: `echo $SLAVE | cut -d ';' -f 6`"
echo "Slave-Pos: `echo $SLAVE | cut -d ';' -f 7`"
echo "Slave_IO_State: `echo $SLAVE | cut -d ';' -f 1`"
echo "Slave_IO_Running: `echo $SLAVE | cut -d ';' -f 11`"
echo "Slave_SQL_Running: `echo $SLAVE | cut -d ';' -f 12`"

# Auf dem Master die Tabellen wieder freigeben
echo "# Auf dem Master die Tabellen wieder freigeben"
ssh 10.10.1.252 "echo 'UNLOCK TABLES;' | mysql -u root --password=$PW";

rm /tmp/master_data.sql
