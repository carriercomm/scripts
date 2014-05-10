#!/bin/bash
SERVER="maxlan.de"
USER="maxlan"
DIR="~/httpdocs/"

if [ "$1" == "" ]; then
  echo "Usage: $0 <ziel>"
  echo " <ziel>"
  echo "  lan   - WEB -> LAN"
  echo "  web   - LAN -> WEB"
  exit 0
fi

LOG="/root/logs/files_$1_`date +%Y$m%d_%H%M`.log"

if [ "$1" == "lan" ]; then
  echo "#!/bin/bash" > /tmp/sync_files.sh
  echo "rsync -a --progress --stats --exclude-from=/root/maxlan.rsync.exclude --log-file=$LOG -e ssh $USER@$SERVER:$DIR* /var/www/ 2> $LOG.err" >> /tmp/sync_files.sh
  echo "gzip $LOG" >> /tmp/sync_files.sh
  echo "echo \"\"" >> /tmp/sync_files.sh
  echo "echo \"#############################\"" >> /tmp/sync_files.sh
  echo "echo \"Sync fertig - weiter mit der Any-Taste\"" >> /tmp/sync_files.sh
  echo "read" >> /tmp/sync_files.sh
  chmod u+x /tmp/sync_files.sh
  screen -S files_to_$1 /tmp/sync_files.sh
elif [ "$1" == "web" ]; then
  echo "#!/bin/bash" > /tmp/sync_files.sh
  echo "rsync -a --progress --stats --exclude-from=/root/maxlan.rsync.exclude --log-file=$LOG -e ssh /var/www/* $USER@$SERVER:$DIR 2> $LOG.err" >> /tmp/sync_files.sh
  echo "gzip $LOG" >> /tmp/sync_files.sh
  echo "echo \"\"" >> /tmp/sync_files.sh
  echo "echo \"#############################\"" >> /tmp/sync_files.sh
  echo "echo \"Lade Logdateien hoch nach sync_logs/\"" >> /tmp/sync_files.sh
  echo "scp $LOG* $USER@$SERVER:$DIR/sync_logs/" >> /tmp/sync_files.sh
  echo "echo \"#############################\"" >> /tmp/sync_files.sh
  echo "echo \"Sync fertig - weiter mit der Any-Taste\"" >> /tmp/sync_files.sh
  echo "read" >> /tmp/sync_files.sh
  chmod u+x /tmp/sync_files.sh
  screen -S files_to_$1 /tmp/sync_files.sh
fi
