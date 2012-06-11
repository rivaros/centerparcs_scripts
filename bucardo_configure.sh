#!/bin/bash

echo "################################################"
echo "#   MAKEMYPHOTO BUCARDO CONFIGURATOR           #"
echo "################################################"

echo "1. Source:127.0.0.1:5432 Dest:127.0.0.1:6432 "
echo "2. Source:[your_ip] Dest:127.0.0.1:5432      "
echo "3. Delete sync"
read -p "Enter your choice[1]:" choice

if [[ $choice == '' ]]; then
	choice=1
fi

if [[ $choice != 1 && $choice != 2 && $choice != 3 ]];then
	echo "Wrong choice"
	exit
fi

if [[ $choice == 2 ]];then
	read -p "Enter IP of remote machine:" remoteip
	read -p "Enter sync name:" syncname
fi

if [[ $choice == 3 ]];then
	read -p "Enter sync name:" syncname
fi

######################################################################################################
#              
#        add local and central dbs
#
#####################################################################################################

if [[ $choice == 1 ]];then
	if [ -z "`bucardo list db local | grep local`" ]; then
   		bucardo add db local db=mmp
	fi
	if [ -z "`bucardo list db central | grep central`" ]; then
    		bucardo add db central db=mmp dbhost=127.0.0.1 dbport=6432 dbuser=postgres dbpass=pybvrb$%
	fi
elif [[ $choice == 2 ]];then
        if [ -z "`bucardo list db local$syncname | grep local$syncname`" ]; then
                bucardo add db local$syncname db=mmp dbhost=$remoteip dbport=5432 dbuser=postgres dbpass=pybvrb$%
        fi
        if [ -z "`bucardo list db central$syncname | grep central$syncname`" ]; then
                bucardo add db central$syncname db=mmp 
        fi
fi

######################################################################################################
#
#	add local tables
#
#####################################################################################################
if [[ $choice == 1 ]];then
	if [ -z "`bucardo list table LocationFacilities | grep \"LocationFacilities  DB: local\"`" ]; then
    		bucardo add table public.LocationFacilities db=local herd=localherd standard_conflict=target
	fi
	if [ -z "`bucardo list table Events | grep \"Events  DB: local\"`" ]; then
    		bucardo add table public.Events db=local herd=localherd
	fi
	if [ -z "`bucardo list table Reservations | grep \"Reservations  DB: local\"`" ]; then
    		bucardo add table public.Reservations db=local herd=localherd
	fi
	if [ -z "`bucardo list table Photoes | grep \"Photoes  DB: local\"`" ]; then
    		bucardo add table public.Photoes db=local herd=localherd
	fi
elif [[ $choice == 2 ]];then
        if [ -z "`bucardo list table LocationFacilities | grep \"LocationFacilities  DB: local$syncname\"`" ]; then
                bucardo add table public.LocationFacilities db=local$syncname herd=localherd$syncname standard_conflict=target
        fi
        if [ -z "`bucardo list table Events | grep \"Events  DB: local$syncname\"`" ]; then
                bucardo add table public.Events db=local$syncname herd=localherd$syncname
        fi
        if [ -z "`bucardo list table Reservations | grep \"Reservations  DB: local$syncname\"`" ]; then
                bucardo add table public.Reservations db=local$syncname herd=localherd$syncname
        fi
        if [ -z "`bucardo list table Photoes | grep \"Photoes  DB: local$syncname\"`" ]; then
                bucardo add table public.Photoes db=local$syncname herd=localherd$syncname
        fi
	
fi

#####################################################################################################
#
#	Adding cutom columns
#
#####################################################################################################

bucardo add customcols public.Events "SELECT \"EventGUID\", \"EventName\", \"Date\", \"PrivacyProtected\",\
\"Edited\", \"Editor\", \"EditedDate\", \"SymLinkOriginal\", \"SymLinkBig\",\
\"LocationFacility\", \"LocationMark\""

bucardo add customcols public.LocationFacilities "SELECT \"FacilityGUID\", \"Location\", \"FacilityName\", \"LocationMark\""

bucardo add customcols public.Photoes "SELECT \"PhotoGUID\", \"OriginalName\", \"Event\", \"Photographer\",\
\"DateUploaded\", \"Preselected\", \"SharedStore\", \"Extension\", \"Status\",\
\"SymlinkOriginal\", \"SymlinkBig\", \"LocationMark\""

bucardo add customcols public.Reservations "SELECT \"ReservationGUID\", \"ClientGUID\", \"PhotographerGUID\", \"ReservationTime\",
\"EVerificationCode\", \"PVerificationCode\", \"Confirmed\", \"LocationMark\""

#######################################################################################################
#
#	Add dbgroups & syncs
#
######################################################################################################

if [[ $choice == 1 ]];then
	if [ -z "`bucardo list dbgroup standard | grep standard`" ]; then
    		bucardo add dbgroup standard local:source central
	fi
elif [[ $choice == 2 ]];then
        if [ -z "`bucardo list dbgroup standard$syncname | grep standard$syncname`" ]; then
                bucardo add dbgroup standard$syncname local$syncname:source central$syncname
        fi
fi

if [[ $choice == 1 ]];then
	if [ -z "`bucardo list sync standard | grep standard`" ]; then
    		bucardo add sync standard herd=localherd dbs=standard
	fi
elif [[ $choice == 2 ]];then
        if [ -z "`bucardo list sync standard$syncname | grep standard$syncname`" ]; then
                bucardo add sync standard$syncname herd=localherd$syncname dbs=standard$syncname
        fi
fi

##############################################################################################################
#
#  Choice 3: Removing sync
#
#############################################################################################################

if [[ $choice == 3 ]];then
	bucardo remove sync standard$syncname
	bucardo remove herd localherd$syncname
	bucardo remove dbgroup standard$syncname
	bucardo remove db local$syncname
	bucardo remove db central$syncname
fi

if [ `uname` == "Darwin" ]; then
        LOGROOT='/opt/local/var/log'
        BINROOT='/opt/local/bin'
elif [ `uname` == "Linux" ];then
        LOGROOT='/var/log'
        BINROOT='/usr/local/bin'
fi


if [ `uname` == "Darwin" ];then
#On MacOS X bucardo will run under _www user
        sudo -u _www $BINROOT/bucardo stop
	echo "waiting 10 seconds..."
	sleep 10
        sudo -u _www $BINROOT/bucardo start --debugdir=$LOGROOT
fi

if [ `uname` == "Linux" ];then
        read -p "Enter username, under which bucardo will run (should be webserver user):" bucardouser
        if [ -z "`grep "^${bucardouser}:" /etc/passwd`" ];then
                echo "Such user not found in the system"
                exit
        fi
		if [ ! -d /var/run/bucardo ]; then
			mkdir -p /var/run/bucardo
		fi
		chown -R $bucardouser /var/run/bucardo >/dev/null 2>&1
		echo "Bucardo initial start" >> $LOGROOT/bucardo.restart.log
        sudo -u $bucardouser $BINROOT/bucardo stop
		echo "waiting 10 seconds..."
		sleep 10
        sudo -u $bucardouser $BINROOT/bucardo start --debugdir=$LOGROOT
fi

	













