#!/bin/bash

type -p -a port >/dev/null || exit "MacPorts not installed"

port install perl5.12 +shared
port install p5.12-dbi
port install p5.12-dbd-pg
port install apache2
port install git-core
port install php5 @5.3.12 +apache2
port install php5-imagick
port install postgresql91 +perl
port install postgresql91-server
port install php5-apc php5-curl php5-exif php5-iconv php5-intl php5-mbstring php5-posix php5-sqlite php5-postgresql
port install rsync screen mc
port install stunnel

#ENVIRONMENT variables set
export EDITOR=nano
export PGDATABASE=mmp
export PGUSER=postgres
export PATH=/opt/local/lib/postgresql91/bin:/opt/local/bin:/opt/local/sbin:$PATH
alias mc=". /opt/local/libexec/mc/mc-wrapper.sh"

#ENVIRONMENT Configuration /etc/profile
grep -l "export EDITOR=" /etc/profile >/dev/null || echo "export EDITOR=nano" | tee -a /etc/profile >/dev/null
grep -l "export PGDATABASE=" /etc/profile >/dev/null || echo "export PGDATABASE=mmp" | tee -a /etc/profile >/dev/null
grep -l "export PGUSER=" /etc/profile >/dev/null || echo "export PGUSER=postgres" | tee -a /etc/profile >/dev/null
grep -l "#MacPortsPath" /etc/profile >/dev/null \
|| echo "export PATH=/opt/local/lib/postgresql91/bin:/opt/local/bin:/opt/local/sbin:\$PATH  #MacPortsPath" \
| tee -a /etc/profile >/dev/null
grep -l "type -p -a mc" /etc/profile >/dev/null || echo "type -p -a mc >/dev/null && alias mc=\". /opt/local/libexec/mc/mc-wrapper.sh\"" | tee -a /etc/profile >/dev/null

#ENVIRONMENT Configuration ~/.bashrc
grep -l "export EDITOR=" ~/.bashrc >/dev/null || echo "export EDITOR=nano" | tee -a ~/.bashrc >/dev/null
grep -l "export PGDATABASE=" ~/.bashrc >/dev/null || echo "export PGDATABASE=mmp" | tee -a ~/.bashrc >/dev/null
grep -l "export PGUSER=" ~/.bashrc >/dev/null || echo "export PGUSER=postgres" | tee -a ~/.bashrc >/dev/null
grep -l "type -p -a mc" ~/.bashrc >/dev/null || echo "type -p -a mc >/dev/null && alias mc=\". /opt/local/libexec/mc/mc-wrapper.sh\"" | tee -a ~/.bashrc >/dev/null
grep -l "alias backup-central=\"~/bin/backup-central.sh\"" ~/.bashrc >/dev/null \
|| echo "alias backup-central=\"~/bin/backup-central.sh\"" \
| tee -a ~/.bashrc > /dev/null
grep -l "alias backup-central-scheme=\"~/bin/backup-central-scheme.sh\"" ~/.bashrc >/dev/null \
|| echo "alias backup-central-scheme=\"~/bin/backup-central-scheme.sh\"" \
| tee -a ~/.bashrc > /dev/null
grep -l "alias restore-central=\"~/bin/restore-central.sh\"" ~/.bashrc >/dev/null \
|| echo "alias restore-central=\"~/bin/restore-central.sh\"" \
| tee -a ~/.bashrc > /dev/null
grep -l "alias restore-location=\"~/bin/restore-location.sh\"" ~/.bashrc >/dev/null \
|| echo "alias restore-location=\"~/bin/restore-location.sh\"" \
| tee -a ~/.bashrc > /dev/null

#ENVIRONMENT Configuration ~/.profile
sed -e 's/^export PATH=\/opt\/local\/bin/#export PATH=\/opt\/local\/bin/' ~/.profile > ~/.profiletmp
mv ~/.profiletmp ~/.profile

#ENVITONMRNT Configuration /etc/hosts
grep -l "mmp" /etc/hosts >/dev/null || echo "127.0.0.1   mmp" | tee -a /etc/hosts >/dev/null

#Clear out pgpass
> ~/.pgpass

#Apache
if [ -f /opt/local/apache2/conf/httpd.conf -a ! -f /opt/local/apache2/conf/httpd.conf.macports ]; then
    cp -f /opt/local/apache2/conf/httpd.conf /opt/local/apache2/conf/httpd.conf.macports
fi
if [ -f /opt/local/apache2/conf/extra/httpd-vhosts.conf -a ! -f /opt/local/apache2/conf/extra/httpd-vhosts.conf.macports ]; then
    cp -f /opt/local/apache2/conf/extra/httpd-vhosts.conf /opt/local/apache2/conf/extra/httpd-vhosts.conf.macports
fi
mkdir -p /opt/local/apache2/conf/extra
cp -f confs/apache/httpd.conf /opt/local/apache2/conf/httpd.conf
cp -f confs/apache/httpd-vhosts.conf /opt/local/apache2/conf/extra/httpd-vhosts.conf
if [ -f /opt/local/etc/php5/php.ini -a ! -f /opt/local/etc/php5/php.ini.macports ]; then
    cp -f /opt/local/etc/php5/php.ini /opt/local/etc/php5/php.ini.macports
fi
cp -f confs/php/php.ini /opt/local/etc/php5/php.ini
killall httpd
#/opt/local/apache2/bin/apachectl -k restart
port load apache2

#Stunnel
if [ -f /opt/local/etc/stunnel/stunnel.conf -a ! -f /opt/local/etc/stunnel/stunnel.conf.macports ]; then
    cp -f /opt/local/etc/stunnel/stunnel.conf /opt/local/etc/stunnel/stunnel.conf.macports
fi
mkdir -p /opt/local/etc/stunnel
mkdir -p /opt/local/var/lib/stunnel/certificates
mkdir -p /opt/local/etc/LaunchDaemons/org.macports.stunnel
cp -f confs/stunnel/mmplocation.pem /opt/local/etc/stunnel/mmplocation.pem
chown root:admin /opt/local/etc/stunnel/mmplocation.pem
chmod 600 /opt/local/etc/stunnel/mmplocation.pem
cp -f confs/stunnel/stunnel.conf /opt/local/etc/stunnel/stunnel.conf
cp -R confs/stunnel/certificates /opt/local/var/lib/stunnel
chown -R nobody:admin /opt/local/var/lib/stunnel
cp -R LaunchDaemons/org.macports.stunnel /opt/local/etc/LaunchDaemons
ln -fs /opt/local/etc/LaunchDaemons/org.macports.stunnel/org.macports.stunnel.plist /Library/LaunchDaemons/org.macports.stunnel.plist
port unload stunnel
killall stunnel
port load stunnel

#Postgres
if [ ! -d /opt/local/var/db/postgresql91/defaultdb ]; then
	#create new database cluster
	mkdir -p /opt/local/var/db/postgresql91/defaultdb
	chown postgres:postgres /opt/local/var/db/postgresql91/defaultdb
	su postgres -c '/opt/local/lib/postgresql91/bin/initdb -D /opt/local/var/db/postgresql91/defaultdb'
fi
if [ -f /opt/local/var/db/postgresql91/defaultdb/pg_hba.conf -a ! -f /opt/local/var/db/postgresql91/defaultdb/pg_hba.conf.macports ]; then
    cp -f /opt/local/var/db/postgresql91/defaultdb/pg_hba.conf /opt/local/var/db/postgresql91/defaultdb/pg_hba.conf.macports
fi
if [ -f /opt/local/var/db/postgresql91/defaultdb/postgresql.conf -a ! -f /opt/local/var/db/postgresql91/defaultdb/postgresql.conf.macports ]; then
    cp -f /opt/local/var/db/postgresql91/defaultdb/postgresql.conf /opt/local/var/db/postgresql91/defaultdb/postgresql.conf.macports
fi
cp -f confs/postgres/pg_hba.conf /opt/local/var/db/postgresql91/defaultdb/pg_hba.conf
cp -f confs/postgres/postgresql.conf /opt/local/var/db/postgresql91/defaultdb/postgresql.conf
port unload postgresql91-server
killall postgresql
port load postgresql91-server
echo "Waiting 10 secs until postgres is up..."
sleep 10
psql -d postgres -qAt -c "ALTER USER postgres WITH ENCRYPTED PASSWORD 'pybvrb$%'"
psql -d postgres -qAt -c "CREATE ROLE location WITH LOGIN ENCRYPTED PASSWORD 'pfndjh$%'";
psql -d postgres -qAt -c "CREATE ROLE central WITH LOGIN ENCRYPTED PASSWORD 'pfndjh$%'";
psql -d postgres -qAt -c "CREATE DATABASE mmp TEMPLATE=template0 ENCODING='UTF8';"
#psql -qAt -c "CREATE LANGUAGE plperl;"
psql -qAt -c "CREATE EXTENSION dblink;"
#su postgres -c 'pg_ctl -D /opt/local/var/db/postgresql91/defaultdb reload'
 
#GIT
mkdir -p ~/.ssh
mkdir -p /var/root/.ssh
cp -f keys/id_dsa ~/.ssh/id_dsa
cp -f keys/id_rsa ~/.ssh/id_rsa
chown $SUDO_USER ~/.ssh/id_dsa ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_dsa ~/.ssh/id_rsa
cp -f keys/id_rsa /var/root/.ssh/id_rsa
cp -f keys/id_dsa /var/root/.ssh/id_dsa
chown root:admin /var/root/.ssh/id_rsa /var/root/.ssh/id_dsa
chmod 600 /var/root/.ssh/id_rsa /var/root/.ssh/id_dsa

#Database scripts
mkdir -p ~/bin
cp -R database/*.* ~/bin
cp -f location.dump ~/location.dump
. ~/bin/restore-location.sh




