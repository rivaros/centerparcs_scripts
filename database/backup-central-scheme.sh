#!/bin/bash
pg_dump -h 127.0.0.1 -p 6432 -n public -s -Fc > ~/location.dump && echo "Backup of central scheme done"
