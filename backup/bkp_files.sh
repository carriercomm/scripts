#!/bin/bash

ssh 10.10.1.252 "dpkg --get-selections" > /root/bkp_webserver/paketliste.txt
rsync -a --delete -e ssh root@10.10.1.252:/root/ /root/bkp_webserver/root/
rsync -a --delete -e ssh root@10.10.1.252:/var/www/ /root/bkp_webserver/www/

ssh 10.10.1.254 "dpkg --get-selections" > /root/bkp_dienste/paketliste.txt
rsync -a --delete -e ssh root@10.10.1.254:/root/ /root/bkp_dienste/root/
rsync -a --delete -e ssh root@10.10.1.254:/home/ /root/bkp_dienste/home/
rsync -a --delete -e ssh root@10.10.1.254:/var/www/ /root/bkp_dienste/www/
rsync -a --delete -e ssh root@10.10.1.254:/etc/ /root/bkp_dienste/etc/
