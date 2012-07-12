#!/bin/bash

if [ `uname` == "Darwin" ]; then
        LOGROOT='/opt/local/var/log'
        BINROOT='/opt/local/bin'
else
        LOGROOT='/var/log'
        BINROOT='/usr/local/bin'
fi

check_project() {
    
    if [ ! -d /centerparcs ]; then
        if [ $1 ];then echo "No project folder found";fi
        return 0
    fi
    
    return 1

}


install_project() {

    #GIT Keys distribution
    if [ `uname` == "Darwin" ];then
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
    elif [ `uname` == "Linux" ];then
        mkdir -p ~/.ssh
        mkdir -p /root/.ssh
        cp -f keys/id_dsa ~/.ssh/id_dsa
        cp -f keys/id_rsa ~/.ssh/id_rsa
        if [ $SUDO_USER ];then
            chown $SUDO_USER ~/.ssh/id_dsa ~/.ssh/id_rsa
        fi
        chmod 600 ~/.ssh/id_dsa ~/.ssh/id_rsa
        cp -f keys/id_rsa /root/.ssh/id_rsa
        cp -f keys/id_dsa /root/.ssh/id_dsa
        chown root /root/.ssh/id_rsa /root/.ssh/id_dsa
        chmod 600 /root/.ssh/id_rsa /root/.ssh/id_dsa
    elif [[ `uname` == *CYGWIN* ]];then
    	mkdir -p ~/.ssh
        cp -f keys/id_dsa ~/.ssh/id_dsa
        cp -f keys/id_rsa ~/.ssh/id_rsa
    fi


    if [ ! -d /centerparcs ]; then
        git clone ssh://git@project-logs.info:4837/centerparcs.git /centerparcs
    fi

	currentdir=`pwd`
    cd /centerparcs
    
    read -p "Update website to latest version?[yes]" choice
    if [[ $choice == "yes" || $choice == "" ]];then
    	git reset --hard
    	git checkout master
    	git pull
	fi
    
    read -p "Install vendors?[yes]" choice
    if [[ $choice == "yes" || $choice == "" ]];then
    	php bin/vendors install
	fi
    
    echo "What kind of installation would you like?"
    echo "Choises:"
    echo "1. Production location server"
    echo "2. Development location server"
    echo "3. Production central server"
    echo "4. Development central server"
    echo "5. Skip this step"
    
    read -p "Your choice:[1]" installtype
    if [[ $installtype != 1 && $installtype != 2 && $installtype != 3 && $installtype != 4 && $installtype != 5 && $installtype != '' ]];then
        echo "Wrong choice"
        exit
    fi

    if [[ $installtype == 1 || $installtype == '' ]];then
    	#production location
        cp -f app/config/parameters.ini.dist-location.production app/config/parameters.ini
        cp -f web/htaccess.dist-prod web/.htaccess
    elif [[ $installtype == 2 ]];then
    	#development location
        cp -f app/config/parameters.ini.dist-location app/config/parameters.ini
        cp -f web/htaccess.dist-dev web/.htaccess
    elif [[ $installtype == 3 ]];then
    	#production central server
    	cp -f app/config/parameters.ini.dist-central app/config/parameters.ini
    	cp -f web/htaccess.dist-prod web/.htaccess
    elif [[ $installtype == 4 ]];then
    	#development central server
    	cp -f app/config/parameters.ini.dist-central app/config/parameters.ini
    	cp -f web/htaccess.dist-dev web/.htaccess
    fi
    
    if [[ $installtype != 5 ]];then
    	echo "ATTENTION: The configuration files were changed according to your choice. But you also need to make sure that database is corresponding. If you are not sure, check point 6. Postgres"
	fi

    if [ `uname` == "Darwin" ];then
        chmod -R +a "_www allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" \
    	logs app/logs app/cache web/media web/uploads app/config/parameters.ini
    fi
    if [ `uname` == "Linux" ];then
            read -p "Enter username, under which webserver is running:" webserveruser
            if [ -z "`grep "^${webserveruser}:" /etc/passwd`" ];then
                    echo "Such user not found in the system"
                    exit
            fi
            setfacl -R -m u:$webserveruser:rwx logs app/logs app/cache web/media web/uploads app/config/parameters.ini
            setfacl -dR -m u:$webserveruser:rwx logs app/logs app/cache web/media web/uploads app/config/parameters.ini    
    fi    


    php app/console assets:install web
    
    
    #aliases creation
    grep -l "alias backup-mmp=" ~/.bashrc >/dev/null \
    || echo "alias backup-mmp=\"/bin/bash /centerparcs/bin/scripts_linux/backup-mmp.sh\"" \
    | tee -a ~/.bashrc > /dev/null
    grep -l "alias restore-mmp=" ~/.bashrc >/dev/null \
    || echo "alias restore-mmp=\"/bin/bash /centerparcs/bin/scripts_linux/restore-mmp.sh\"" \
    | tee -a ~/.bashrc > /dev/null
    
    
    cd $currentdir
    cp -f transfer_checker.sh $BINROOT/transfer_checker.sh
    chmod 755 $BINROOT/transfer_checker.sh
        
    if [ `uname` == "Darwin" ];then
        #On MacOS X bucardo will run under _www user
            grep -l "setenv PATH" /etc/launchd.conf >/dev/null 2>&1 || echo "setenv PATH $PATH" | tee -a /etc/launchd.conf >/dev/null
            launchctl setenv PATH $PATH
            cp -R LaunchDaemons/mmp.transfer.check /opt/local/etc/LaunchDaemons
            ln -fs /opt/local/etc/LaunchDaemons/mmp.transfer.check/mmp.transfer.check.plist /Library/LaunchDaemons/mmp.transfer.check.plist
            launchctl unload /Library/LaunchDaemons/mmp.transfer.check.plist
            launchctl load /Library/LaunchDaemons/mmp.transfer.check.plist
    fi
        
    [ -n "`grep events:transfercontroller /etc/crontab`" ] \
    || echo "*/5 * * * * SYSTEM $BINROOT/transfer_checker.sh" >>/etc/crontab
    
    if [[ `uname` == *CYGWIN* ]];then
    		net stop cron
    		net start cron	
	fi
	
	if [[ `uname` == "Linux" ]];then
			service cron restart	
	fi


}




if [ ! -z "$1" ]; then
    while getopts "icd" opt; do
        case $opt in
            c)
                check_project
                if [[ $? == 1 ]];then
                    echo "OK"
                else
                    echo "PROBLEMS"
                fi
            ;;
            i)
                install_project
            ;;
            d)
                check_project diag
            ;;
            
        esac
    done
else
    echo "Running without parameters" >&2
fi
