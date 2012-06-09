#!/bin/bash

if [ ! -d /centerparcs ]; then
	git clone ssh://git@project-logs.info:4837/centerparcs.git /centerparcs
fi

cd /centerparcs
git pull
php bin/vendors install

cp web/htaccess.dist-dev web/.htaccess
#cp web/htaccess.dist-prod web/.htaccess

cp app/config/parameters.ini.dist-location app/config/parameters.ini
#cp app/config/parameters.ini.dist-central app/config/parameters.ini

if [ `uname` == "Darwin" ];then
chmod -R +a "_www allow list,add_file,search,add_subdirectory,delete_child,readattr,\
writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" \
logs app/logs app/cache web/media web/uploads
fi


php app/console assets:install web

