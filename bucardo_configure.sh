#!/bin/bash

if [ `uname` == "Darwin" ]; then
        LOGROOT='/opt/local/var/log'
        BINROOT='/opt/local/bin'
elif [ `uname` == "Linux" ];then
        LOGROOT='/var/log'
        BINROOT='/usr/local/bin'
fi



function diagnose() {
	if [[ `uname` == *CYGWIN* ]];then
        if [ $1 ];then echo "You are on Cygwin. This option does not apply";fi
        return 1		
	fi    

    if [[ `uname` == "Darwin" ]];then
        if [ -z "`echo $PATH | grep \"/opt/local/lib/postgresql91/bin\"`" ];then
            export PATH=/opt/local/lib/postgresql91/bin:$PATH
        fi
    fi
    export PGUSER=postgres
    export PGDATABASE=mmp
    bucardo_installed=0
    psql -d postgres -qAt -c "SELECT 1 FROM pg_database where datname='bucardo'" | grep -q 1  && bucardo_installed=1
    
    if [[ $bucardo_installed == 0 ]];then 
        echo "Bucardo not installed. Nothing to diagnose"
        exit
    fi
    
    
    read -p "Enter syncname (blank is ok for profuction):[]" syncname

    echo "Listing databases"
    bucardo list db local$syncname
    bucardo list db central$syncname
    echo "Listing tables"
    bucardo list table LocationFacilities
    bucardo list table Events
    bucardo list table Reservations
    bucardo list table Photoes
    echo "Listing herds"
    bucardo list herd$syncname
    echo "Listing customcols"
    bucardo list customcols
    echo "listing db groups"
    bucardo list dbgroup standard$syncname
    bucardo list sync standard$syncname
    
    
    if [ `uname` == "Darwin" ];then
        
        if [ -z "`grep -l \"setenv PATH /opt/local/lib/postgresql91/bin:/opt/local/bin:/opt/local/sbin\" /etc/launchd.conf`" ];then
            echo "ERROR: PATH incorrectly set in /etc/launchd.conf"
        fi

    
    fi
    
    /bin/bash /centerparcs/bin/scripts_linux/bucardo_check.sh   
}


function check() {
	
	if [[ `uname` == *CYGWIN* ]];then
        if [ $1 ];then echo "You are on Cygwin. This option does not apply";fi
        return 1		
	fi    

    if [ `uname` == "Darwin" ];then
        if [ ! -d /opt/local/var/db/postgresql91/defaultdb ];then
            return 0;
        fi
    fi

    if [[ `uname` == "Darwin" ]];then
        if [ -z "`echo $PATH | grep \"/opt/local/lib/postgresql91/bin\"`" ];then
            export PATH=/opt/local/lib/postgresql91/bin:$PATH
        fi
    fi
    export PGUSER=postgres
    bucardo_installed=0
    psql -d postgres -qAt -c "SELECT 1 FROM pg_database where datname='bucardo'" | grep -q 1  && bucardo_installed=1

    if [[ $bucardo_installed == 0 ]];then return 0;fi
    
    #Add local and central databases
    if [ -z "`bucardo list db local | grep local`" ]; then return 0;fi
    if [ -z "`bucardo list db central | grep central`" ]; then return 0; fi
    if [ -z "`bucardo list table LocationFacilities | grep \"LocationFacilities  DB: local\"`" ]; then return 0;fi
    if [ -z "`bucardo list table Events | grep \"Events  DB: local\"`" ]; then return 0; fi
    if [ -z "`bucardo list table Reservations | grep \"Reservations  DB: local\"`" ]; then return 0; fi
    if [ -z "`bucardo list table Photoes | grep \"Photoes  DB: local\"`" ]; then return 0; fi
    if [ -z "`bucardo list dbgroup standard | grep standard`" ]; then return 0; fi
    if [ -z "`bucardo list sync standard | grep standard`" ]; then return 0; fi


    if [ `uname` == "Darwin" ];then
       
        if [ -z "`grep -l \"setenv PATH /opt/local/lib/postgresql91/bin:/opt/local/bin:/opt/local/sbin\" /etc/launchd.conf`" ];then return 0;fi
   
    fi
    
    return 1;

}

function install() {

    if [[ `uname` == "Darwin" ]];then
        if [ -z "`echo $PATH | grep \"/opt/local/lib/postgresql91/bin\"`" ];then
            export PATH=/opt/local/lib/postgresql91/bin:$PATH
        fi
    fi
    export PGUSER=postgres
    export PGDATABASE=mmp


    echo "This will configure bucardo."
    echo "1. Source:127.0.0.1:5432 Dest:127.0.0.1:7432 (This is standard production setting)"
    echo "2. Source:[your_ip] Dest:127.0.0.1:5432      (This is used only by developers)"
    echo "3. Delete sync"
    echo "4. Source:127.0.0.1:5432 Dest:127.0.0.1:6432 (This is used only by developers)"


    read -p "Enter your choice[1]:" choice

    if [[ $choice == '' ]]; then
        choice=1
    fi

    if [[ $choice != 1 && $choice != 2 && $choice != 3 && $choice != 4 ]];then
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
    
    #Add local and central databases
    if [[ $choice == 1 ]];then
        if [ -z "`bucardo list db local | grep local`" ]; then
            bucardo add db local db=mmp
        fi
        if [ -z "`bucardo list db central | grep central`" ]; then
                bucardo add db central db=mmp dbhost=127.0.0.1 dbport=7432 dbuser=postgres dbpass=pybvrb$%
        fi
    elif [[ $choice == 2 ]];then
            if [ -z "`bucardo list db local$syncname | grep local$syncname`" ]; then
                    bucardo add db local$syncname db=mmp dbhost=$remoteip dbport=5432 dbuser=postgres dbpass=pybvrb$%
            fi
            if [ -z "`bucardo list db central$syncname | grep central$syncname`" ]; then
                    bucardo add db central$syncname db=mmp 
            fi
    elif [[ $choice == 4 ]]; then
            if [ -z "`bucardo list db local | grep local`" ]; then
                    bucardo add db local db=mmp
            fi
            if [ -z "`bucardo list db central | grep central`" ]; then
                    bucardo add db central db=mmp dbhost=127.0.0.1 dbport=6432 dbuser=postgres dbpass=pybvrb$%
            fi
    fi
    
    #add local tables
    if [[ $choice == 1 || $choice == 4 ]];then
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

    read -p "Update bucardo customcols?[yes]" choice
    if [[ $choice == "yes" || $choice == "" ]];then

	psql -d bucardo -qAt -c "DELETE FROM bucardo.customcols" 

        #Adding custom columns
        bucardo add customcols public.Events "SELECT \"EventGUID\", \"EventName\", \"Date\", \"PrivacyProtected\",\
        \"Edited\", \"Editor\", \"EditedDate\", \"SymlinkEdited\", \"SymlinkOriginal\",\
        \"LocationFacility\", \"LocationMark\""

        bucardo add customcols public.LocationFacilities "SELECT \"FacilityGUID\", \"Location\", \"FacilityName\", \"LocationMark\""

        bucardo add customcols public.Photoes "SELECT \"PhotoGUID\", \"OriginalName\", \"Event\", \"Photographer\",\
        \"DateUploaded\", \"Preselected\", \"SharedStore\", \"Extension\", \"Status\",\
        \"SymlinkOriginal\", \"SymlinkBig\", \"LocationMark\""

        bucardo add customcols public.Reservations "SELECT \"ReservationGUID\", \"ClientGUID\", \"PhotographerGUID\", \"ReservationTime\",
        \"EVerificationCode\", \"PVerificationCode\", \"Confirmed\", \"LocationMark\""
   fi

        #Add dbgroups and syncs
        if [[ $choice == 1 || $choice == 4 ]];then
            if [ -z "`bucardo list dbgroup standard | grep standard`" ]; then
                    bucardo add dbgroup standard local:source central
            fi
        elif [[ $choice == 2 ]];then
                if [ -z "`bucardo list dbgroup standard$syncname | grep standard$syncname`" ]; then
                        bucardo add dbgroup standard$syncname local$syncname:source central$syncname
                fi
        fi

        if [[ $choice == 1 || $choice == 4 ]];then
            if [ -z "`bucardo list sync standard | grep standard`" ]; then
                    bucardo add sync standard herd=localherd dbs=standard
            fi
        elif [[ $choice == 2 ]];then
                if [ -z "`bucardo list sync standard$syncname | grep standard$syncname`" ]; then
                        bucardo add sync standard$syncname herd=localherd$syncname dbs=standard$syncname
                fi
        fi

        #removing syncs
        if [[ $choice == 3 ]];then
            bucardo remove sync standard$syncname
            bucardo remove herd localherd$syncname
            bucardo remove dbgroup standard$syncname
            bucardo remove db local$syncname
            bucardo remove db central$syncname
        fi

        if [ ! -d /var/run/bucardo ]; then
            mkdir /var/run/bucardo
        fi
    
        if [ `uname` == "Darwin" ];then
            #On MacOS X bucardo will run under _www user
            echo "Stopping Bucardo..."
            chown -R _www /var/run/bucardo
            chmod -R +a "_www allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" $LOGROOT
            sudo -u _www $BINROOT/bucardo stop
            echo "waiting 10 seconds..."
            sleep 10
            echo "Starting Bucardo..."
            sudo -u _www $BINROOT/bucardo start --debugdir=$LOGROOT
        fi

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
                echo "Stopping Bucardo..."
                chown -R $apacheuser /var/run/bucardo >/dev/null 2>&1
                setfacl -R -m u:$apacheuser:rwx $LOGROOT
                setfacl -dR -m u:$apacheuser:rwx $LOGROOT            
                sudo -u $apacheuser $BINROOT/bucardo stop
                echo "waiting 10 seconds..."
                sleep 10
                echo "Starting Bucardo..."
                sudo -u $apacheuser $BINROOT/bucardo start --debugdir=$LOGROOT
        fi
    

}


#Cross-platform Bucardo reanimate script v3.0
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
                diagnose
            ;;
            
        esac
    done
else
    echo "Running without parameters" >&2
fi









