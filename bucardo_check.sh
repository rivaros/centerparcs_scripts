#!/bin/bash
error=0
errorstext=""
if [ ! -f /var/run/bucardo/bucardo.ctl.sync.standard.pid ]; then
        error=1;
        errortext="$errortext\nERROR: no bucardo.ctl.sync.standard.pid found\n"
fi
if [ ! -f /var/run/bucardo/bucardo.kid.sync.standard.pid ]; then
        error=1;
        errortext="$errortext\nERROR: no bucardo.kid.sync.standard.pid found\n"
fi
if [ ! -f /var/run/bucardo/bucardo.mcp.pid ]; then
        error=1;
        errortext="$errortext\nERROR: no bucardo.mcp.pid found\n"
fi
if ls /var/run/bucardo/*.pid >/dev/null 2>&1; then
  for f in /var/run/bucardo/*.pid;
    do
      if !( [ `head -1 $f` ] && kill -s 0 `head -1 $f` >/dev/null ); then
                error=1
                errortext="$errortext\nERROR: process for $f was not running\n"
      fi
    done
fi
if [ $error -eq 1 ]; then
  echo -e $errortext
else
  echo "All Processes running. No problems found"
fi



