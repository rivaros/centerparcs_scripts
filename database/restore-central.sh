#!/bin/bash
# we assume that we have a full db backup of central database

if [ ! -z "$1" ]; then
        while getopts ":c" opt; do
          case $opt in
            c)
              echo "-c The structure would be cleaned!" >&2
              pg_restore -d mmp -c ~/central.dump && echo "Restore done"
              ;;
          esac
        done
else
      echo "Restoring without cleaning structure" >&2
      pg_restore -d mmp ~/central.dump && echo "Restore done"
fi

# ensure we remove all rights for 'location' user and restore default rights
psql -qAt -c "select 'revoke all on '||schemaname||'.\"'||tablename||'\" from location;' from pg_tables where schemaname in ('public') order by schemaname,tablename; " | psql 

psql -qAt -c "select 'revoke all on function '||n.nspname||'.\"'||p.proname||'\"('||oidvectortypes(p.proargtypes)||') from location;' from pg_proc p, pg_namespace n where n.oid = p.pronamespace and n.nspname in ('public') order by n.nspname, p.proname;" | psql 

psql -qAt -c "select 'revoke all on '||n.nspname||'.\"'||c.relname||'\" from location;' from pg_class c, pg_namespace n where n.oid = c.relnamespace and c.relkind IN ('S') and n.nspname in ('public');" | psql 

psql -qAt -c "select 'revoke all on '||n.nspname||'.\"'||c.relname||'\" from location;' from pg_class c, pg_namespace n where n.oid = c.relnamespace and c.relkind IN ('v') and n.nspname in ('public');" | psql 

psql -qAt -c "grant select on \"Locations\" to location;"
psql -qAt -c "grant select on \"Photographers\" to location;"
psql -qAt -c "grant select,insert on \"Clients\" to location;"

read -p "Press [Enter] key to continue..." 

#ensure we set all rights for 'central' user

psql -qAt -c "select 'grant all on '||schemaname||'.\"'||tablename||'\" to central;' from pg_tables where schemaname in ('public') order by schemaname,tablename; " | psql
psql -qAt -c "select 'grant all on '||n.nspname||'.\"'||c.relname||'\" to central;' from pg_class c, pg_namespace n where n.oid = c.relnamespace and c.relkind IN ('v') and n.nspname in ('public');" | psql
psql -qAt -c "select 'grant all on '||n.nspname||'.\"'||c.relname||'\" to central;' from pg_class c, pg_namespace n where n.oid = c.relnamespace and c.relkind IN ('S') and n.nspname in ('public');" | psql
psql -qAt -c "select 'grant all on function '||n.nspname||'.\"'||p.proname||'\"('||oidvectortypes(p.proargtypes)||') to central;' from pg_proc p, pg_namespace n where n.oid = p.pronamespace and n.nspname in ('public') order by n.nspname, p.proname;" | psql

read -p "Press [Enter] key to continue..." 
