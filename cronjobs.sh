#!/bin/bash

#INITIAL THINGS
#Common Paths
if [ `uname` == "Darwin" ]; then
        LOGROOT='/opt/local/var/log'
        BINROOT='/opt/local/bin'
else
        LOGROOT='/var/log'
        BINROOT='/usr/local/bin'
fi

#Apache user
if [ `uname` == "Linux" ];then
       apacheuser=`ps -eo user,stat,args | grep httpd | grep -v grep | grep -v Ss | head -1 | awk '{print $1}'`
       if [[ $apacheuser == '' ]];then
       	apacheuser=`ps -eo user,stat,args | grep apache2 | grep -v grep | grep -v Ss | head -1 | awk '{print $1}'`
   	fi
       
       if [[ $apacheuser == "root" ]];then
           echo "ERROR: cannot grep apache user - grepped root"
           exit
       elif [[ $apacheuser == '' ]];then
           echo "ERROR: cannot grep apache user - grepped null"
           exit
       fi    

       if [ -z "`grep \"^${apacheuser}:\" /etc/passwd`" ];then
             echo "Error: User $apacheuser not found in the system"
             exit
       fi    
fi



function check() {
	
	if [ `uname` == "Darwin" ];then
		
			#Additional PATH checks on MacOS X
			echo $PATH | grep "/opt/local/lib/postgresql91/bin:/opt/local/bin:/opt/local/sbin" > /dev/null 2>&1
			if (( $? ));then
				if [[ $1 ]];then echo "ERROR: PATH problems in Darwin environment";else return 0;fi
	        fi
	        
			launchctl getenv PATH | grep "/opt/local/lib/postgresql91/bin:/opt/local/bin:/opt/local/sbin"
			if (( ! $? ));then echo "ERROR: Launchctl PATH problems in Darwin environment";else return 0;fi   
	fi
	

	#First we install Bucardo (except for Cygwin = Bucardo cannot run on Windows)
	if [[ `uname` != *CYGWIN* ]];then
		
		
		#check for bucardo script
		if [[ ! -f $BINROOT/bucardo_reanimate.sh ]];then
		 	if [[ $1 ]];then echo "ERROR: bucardo_reanimate.sh script not found";else return 0;fi
		fi


		if [ `uname` == "Darwin" ];then
			if [[ ! -f /opt/local/etc/LaunchDaemons/mmp.bucardo.check/mmp.bucardo.check.plist ]];then
		 		if [[ $1 ]];then echo "ERROR: mmp.bucardo.check.plist not found";else return 0;fi
			fi	
			
			if [[ ! -f /Library/LaunchDaemons/mmp.bucardo.check.plist ]];then
		 		if [[ $1 ]];then echo "ERROR: Symlink mmp.bucardo.check.plist not found";else return 0;fi
			fi	
	    fi

        if [ `uname` == "Linux" ];then
        	grep bucardo_reanimate.sh /etc/crontab
        	if (( ! $? ));then echo "ERROR: bucardo_reanimate.sh script not found in crontab";else return 0;fi    
        fi
    
	fi
	
	
	if [[ ! -f $BINROOT/transfer_checker.sh ]];then
		 	if [[ $1 ]];then echo "ERROR: transfer_checker.sh script not found";else return 0;fi
	fi


	if [ `uname` == "Darwin" ];then
			if [[ ! -f /opt/local/etc/LaunchDaemons/mmp.transfer.check/mmp.transfer.check.plist ]];then
		 		if [[ $1 ]];then echo "ERROR: mmp.transfer.check.plist not found";else return 0;fi
			fi	
			if [[ ! -f /Library/LaunchDaemons/mmp.transfer.check.plist ]];then
		 		if [[ $1 ]];then echo "ERROR: symlink mmp.transfer.check.plist not found";else return 0;fi
			fi	
	elif [ `uname` == "Linux" ];then
			grep transfer_checker.sh /etc/crontab > /dev/null 2>&1
			if (( $? ));then 
				if [[ $1 ]];then echo "ERROR: transfer_checker.sh script not found in crontab";else return 0;fi
			fi
	elif [[ `uname` == *CYGWIN* ]];then
			grep transfer_checker.sh /etc/crontab > /dev/null 2>&1
			if (( $? ));then 
				if [[ $1 ]];then echo "ERROR: transfer_checker.sh script not found in crontab";else return 0;fi
			fi
	fi	
	
	return 1;

}


function install() {
	
	if [ `uname` == "Darwin" ];then
		
			#Additional PATH checks on MacOS X
			if [ -z "`echo $PATH | grep \"/opt/local/lib/postgresql91/bin:/opt/local/bin:/opt/local/sbin\"`" ];then
	            echo "Path not found. Setting..."
	            export PATH=/opt/local/lib/postgresql91/bin:/opt/local/bin:/opt/local/sbin:$PATH
	        fi
	        
	    	grep -l "setenv PATH" /etc/launchd.conf >/dev/null 2>&1 || echo "setenv PATH $PATH" | tee -a /etc/launchd.conf >/dev/null
	        launchctl setenv PATH $PATH
	fi
	
	
	
	#First we install Bucardo (except for Cygwin = Bucardo cannot run on Windows)
	if [[ `uname` != *CYGWIN* ]];then
		
		#Bucardo reanimator
        cp -f bucardo_reanimate.sh $BINROOT/bucardo_reanimate.sh
        chmod 755 $BINROOT/bucardo_reanimate.sh

		if [ `uname` == "Darwin" ];then
	            cp -R LaunchDaemons/mmp.bucardo.check /opt/local/etc/LaunchDaemons
	            ln -fs /opt/local/etc/LaunchDaemons/mmp.bucardo.check/mmp.bucardo.check.plist /Library/LaunchDaemons/mmp.bucardo.check.plist
	            launchctl unload /Library/LaunchDaemons/mmp.bucardo.check.plist
	            launchctl load /Library/LaunchDaemons/mmp.bucardo.check.plist
	    fi

        if [ `uname` == "Linux" ];then
                [ -n "`grep bucardo_reanimate.sh /etc/crontab`" ] \
                || echo "*/5  *  *  *  *  root  $BINROOT/bucardo_reanimate.sh $apacheuser" >>/etc/crontab
                service cron restart
        fi
    
	fi
	
	
	#Now we install the transfer controller
    cp -f transfer_checker.sh $BINROOT/transfer_checker.sh
    chmod 755 $BINROOT/transfer_checker.sh


	if [ `uname` == "Darwin" ];then
			#Transfer checker will be running under Apache user
        	chown _www $BINROOT/transfer_check.sh
		
	            cp -R LaunchDaemons/mmp.transfer.check /opt/local/etc/LaunchDaemons
	            ln -fs /opt/local/etc/LaunchDaemons/mmp.transfer.check/mmp.transfer.check.plist /Library/LaunchDaemons/mmp.transfer.check.plist
	            launchctl unload /Library/LaunchDaemons/mmp.transfer.check.plist
	            launchctl load /Library/LaunchDaemons/mmp.transfer.check.plist
	elif [ `uname` == "Linux" ];then
			#Transfer checker will be running under Apache user
        	chown $apacheuser $BINROOT/transfer_checker.sh
		
		     [ -n "`grep transfer_checker.sh /etc/crontab`" ] \
                || echo "*/5  *  *  *  *  apacheuser  $BINROOT/transfer_checker.sh" >>/etc/crontab
                service cron restart
    elif [[ `uname` == *CYGWIN* ]];then
			#Under CYGWIN we are running as system user
		     [ -n "`grep transfer_checker.sh /etc/crontab`" ] \
                || echo "*/5  *  *  *  *  SYSTEM  $BINROOT/transfer_checker.sh" >>/etc/crontab
                net stop cron
                net start cron	
	fi
	


}

#Cross-platform cronjobs script
if [ ! -z "$1" ]; then
    while getopts "icd" opt; do
        case $opt in
            c)
                check
                if [[ $? == 1 ]];then
                    echo "OK"
                else
                    echo "PROBLEMS"
                fi
            ;;
            i)
                install
            ;;
            d)
                check diag
            ;;
            
        esac
    done
else
    echo "Running without parameters" >&2
fi

