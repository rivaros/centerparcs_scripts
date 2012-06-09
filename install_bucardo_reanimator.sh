#!/bin/bash

cp -f bucardo_reanimate.sh /usr/bin/bucardo_reanimate.sh

[ -n "`grep bucardo_reanimate.sh /etc/crontab`" ] \
|| echo "*/5  *  *  *  *  root  /usr/bin/bucardo_reanimate.sh www-data" >>/etc/crontab






