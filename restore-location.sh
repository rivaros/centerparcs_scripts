#!/bin/bash

# You have to use option -c
export PGDATABASE=mmp
export PGUSER=postgres

grep -l "export PGDATABASE=" /etc/profile >/dev/null || echo "export PGDATABASE=mmp" | tee -a /etc/profile >/dev/null
grep -l "export PGUSER=" /etc/profile >/dev/null || echo "export PGUSER=postgres" | tee -a /etc/profile >/dev/null

read -p "Now we will create some roles and try to restore"

#create role
psql -qAt -c "CREATE ROLE central LOGIN PASSWORD 'pybvrb$%'"
psql -qAt -c "CREATE ROLE location LOGIN PASSWORD 'pfndjh$%'"
psql -qAt -c "ALTER USER postgres WITH PASSWORD 'pybvrb$%'"

if [ ! -z "$1" ]; then
	while getopts ":c" opt; do
		case $opt in
			c)
				echo "-c The structure would be cleaned!" >&2
				psql -qAt -c "DROP EXTENSION dblink"
				pg_restore -d mmp -c < ~/location.dump && echo "Restore done"
				psql -qAt -c "CREATE EXTENSION dblink"	
				;;
		esac
	done
else
      echo "Restoring without cleaning structure" >&2
    pg_restore -d mmp < ~/location.dump && echo "Restore done"
fi

read -p "Now we will set all access rights to location user"


echo "Setting full permissions for tables to location user"
psql -qAt -c "select 'grant all on '||schemaname||'.\"'||tablename||'\" to location;' from pg_tables where schemaname in ('public') order by schemaname,tablename; " | psql

echo "Setting full permissions for views to location user"
psql -qAt -c "select 'grant all on '||n.nspname||'.\"'||c.relname||'\" to location;' from pg_class c, pg_namespace n where n.oid = c.relnamespace and c.relkind IN ('v') and n.nspname in ('public');" | psql

echo "Setting full permissions for sequences to location user"
psql -qAt -c "select 'grant all on '||n.nspname||'.\"'||c.relname||'\" to location;' from pg_class c, pg_namespace n where n.oid = c.relnamespace and c.relkind IN ('S') and n.nspname in ('public');" | psql

echo "Setting full permissions for functions to location user"
psql -qAt -c "select 'grant all on function '||n.nspname||'.\"'||p.proname||'\"('||oidvectortypes(p.proargtypes)||') to location;' from pg_proc p, pg_namespace n where n.oid = p.pronamespace and n.nspname in ('public') order by n.nspname, p.proname;" | psql

read -p "Resetting all sequences"
psql -qAt -c "select 'alter sequence '||relname||' restart with 1 ;' from pg_class where relkind='S' ;" | psql
psql -qAt -c "alter table \"Clients\" alter column \"ClientID\" set default null"
psql -qAt -c "alter table \"Photographers\" alter column \"PhotographerID\" set default null"
psql -qAt -c "alter table \"PhotoStatus\" alter column \"StatusID\" set default null"
psql -qAt -c "alter table \"Countries\" alter column \"id\" set default null"



