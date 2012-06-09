#!/bin/bash

if [ ! -z "$1" ]; then
	while getopts ":c" opt; do
	  case $opt in
	    c)
	      echo "-c The structure would be cleaned!" >&2
	      pg_restore -d mmp -c ~/location.dump && echo "Restore done"	
	      ;;
	  esac
	done
else
      echo "Restoring without cleaning structure" >&2
      pg_restore -d mmp ~/location.dump && echo "Restore done"
fi

echo "Setting full permissions for tables to location user"
psql -qAt -c "select 'grant all on '||schemaname||'.\"'||tablename||'\" to location;' from pg_tables where schemaname in ('public') order by schemaname,tablename; " | psql

echo "Setting full permissions for views to location user"
psql -qAt -c "select 'grant all on '||n.nspname||'.\"'||c.relname||'\" to location;' from pg_class c, pg_namespace n where n.oid = c.relnamespace and c.relkind IN ('v') and n.nspname in ('public');" | psql

echo "Setting full permissions for sequences to location user"
psql -qAt -c "select 'grant all on '||n.nspname||'.\"'||c.relname||'\" to location;' from pg_class c, pg_namespace n where n.oid = c.relnamespace and c.relkind IN ('S') and n.nspname in ('public');" | psql

echo "Setting full permissions for functions to location user"
psql -qAt -c "select 'grant all on function '||n.nspname||'.\"'||p.proname||'\"('||oidvectortypes(p.proargtypes)||') to location;' from pg_proc p, pg_namespace n where n.oid = p.pronamespace and n.nspname in ('public') order by n.nspname, p.proname;" | psql

echo "Resetting all sequences"
psql -qAt -c "select 'alter sequence '||relname||' restart with 1 ;' from pg_class where relkind='S' ;" | psql

psql -qAt -c "alter table \"Clients\" alter column \"ClientID\" set default null"
psql -qAt -c "alter table \"Photographers\" alter column \"PhotographerID\" set default null"

