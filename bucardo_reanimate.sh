#!/bin/bash

#Cross-platform Bucardo reanimate script v3.0
if [ ! -z "$1" ]; then
      USER=$1
else
      echo "Usage: bucardo_reanimate <user>"
      exit
fi

if [ `uname` == "Darwin" ]; then
	LOGROOT='/opt/local/var/log'
    BINROOT='/opt/local/bin'
elif [ `uname` == "Linux" ];then
	LOGROOT='/var/log'
	BINROOT='/usr/local/bin'
fi

error=0
if [ ! -f /var/run/bucardo/bucardo.mcp.pid ]; then 
    error=1; 
    echo "BUCARDO RESTART: no bucardo.mcp.pid found" >> $LOGROOT/bucardo.restart.log 
fi

if ls /var/run/bucardo/*.pid >/dev/null 2>&1; then
  for f in /var/run/bucardo/*.pid;
    do
      if !( [ `head -1 $f` ] && kill -s 0 `head -1 $f` >/dev/null ); then
        error=1
        echo "BUCARDO RESTART: process for $f was not running" >> $LOGROOT/bucardo.restart.log 
      fi
    done
fi

if [ $error -eq 1 ]; then

  if ls /var/run/bucardo/*.pid >/dev/null 2>&1; then 
    for f in /var/run/bucardo/*.pid;
    do
      echo "Killing $f"
      kill -s 15 `head -1 $f` >/dev/null
      rm $f
    done
  fi
  sudo -u $USER $BINROOT/bucardo stop
  echo "Waiting 10 seconds"
  sleep 10
  sudo -u $USER $BINROOT/bucardo start --debugdir=$LOGROOT

else

  echo "All Processes running. No problems found"

fi


