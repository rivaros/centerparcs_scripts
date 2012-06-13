#!/bin/bash

function diagnose() {
    echo "Checking Perl environment for missing modules"
    
    echo -n "Checking boolean..."
    perl -Mboolean -e 1 > /dev/null 2>&1
    if (( $? ));then echo "Absent";else echo "OK";fi
    
    echo -n "Checking DBI..."
    perl -MDBI -e 1 > /dev/null 2>&1
    if (( $? ));then echo "Absent";else echo "OK";fi
    
    echo -n "Checking DBD::Pg..."
    perl -MDBD::Pg -e 1 > /dev/null 2>&1
    if (( $? ));then echo "Absent";else echo "OK";fi    
    
    echo -n "Checking Test::Simple..."
    perl -MTest::Simple -e 1 > /dev/null 2>&1    
    if (( $? ));then echo "Absent";else echo "OK";fi
    
    echo -n "Checking DBIx::Safe..."
    perl -MDBIx::Safe -e 1 > /dev/null 2>&1    
    if (( $? ));then echo "Absent";else echo "OK";fi
    
    if [[ -z "`bucardo show all 2>/dev/null | grep bucardo_current_version`" ]];then
            echo "ERROR: Bucardo not installed"
    fi

}


function check() {

    #simple postgres check
    if [ ! -d /opt/local/var/db/postgresql91/defaultdb ];then
        return 0;
    fi
    
    perl -Mboolean -e 1 > /dev/null 2>&1
    if (( $? ));then return 0;fi
    
    perl -MDBI -e 1 > /dev/null 2>&1
    if (( $? ));then return 0;fi                    
    
    perl -MDBD::Pg -e 1 > /dev/null 2>&1
    if (( $? ));then return 0;fi

    perl -MTest::Simple -e 1 > /dev/null 2>&1
    if (( $? ));then return 0;fi

    perl -MDBIx::Safe -e 1 > /dev/null 2>&1
    if (( $? ));then return 0;fi
    
    if [[ -z "`bucardo show all 2>/dev/null | grep bucardo_current_version`" ]];then
        return 0;
    fi
    
    return 1;


}

function install() {

    echo "Checking Perl environment for missing modules"

    echo -n "Checking boolean..."
    perl -Mboolean -e 1 > /dev/null 2>&1
    if (( $? ))
    then
        echo "Absent"
        echo "Installing..."
        PERL_MM_USE_DEFAULT=1 perl -MCPAN -e "install boolean"
    else
        echo "OK"
    fi

    echo -n "Checking DBI..."
    perl -MDBI -e 1 > /dev/null 2>&1
    if (( $? ))
    then
        echo "Absent"
        echo "Installing..."
        if [ `uname` == "Darwin" ];then
        port install p5.12-dbi
        else
        apt-get install libdbi-perl
        fi
    else
        echo "OK"
    fi

    echo -n "Checking DBD::Pg..."
    perl -MDBD::Pg -e 1 > /dev/null 2>&1
    if (( $? ))
    then
        echo "Absent"
        echo "Installing..."
        if [ `uname` == "Darwin" ];then
        port install p5.12-dbd-pg
        else
            apt-get install libdbd-pg-perl
        fi
    else
        echo "OK"
    fi

    echo -n "Checking Test::Simple..."
    perl -MTest::Simple -e 1 > /dev/null 2>&1
    if (( $? ))
    then
        echo "Absent"
        echo "Installing..."
        if [ `uname` == "Darwin" ];then
        port install p5.12-test-simple
        else
        apt-get install perl-modules
        fi
    else
        echo "OK"
    fi

    echo -n "Checking DBIx::Safe..."
    perl -MDBIx::Safe -e 1 > /dev/null 2>&1
    if (( $? ))
    then
        echo "Absent"
        echo "Installing..."
        if [ ! -d DBIx-Safe-1.2.5 ]; then
            tar xvfz dbix_safe.tar.gz
        fi
        cd DBIx-Safe-1.2.5
        perl Makefile.PL
        make
        make install
        cd ..
    else
        echo "OK"
    fi

    if [ `uname` == "Darwin" ]; then
            LOGROOT='/opt/local/var/log'
            BINROOT='/opt/local/bin'
    elif [ `uname` == "Linux" ];then
            LOGROOT='/var/log'
            BINROOT='/usr/local/bin'
    fi


    if [ ! -d bucardo ]; then
        git clone git://github.com/rivaros/bucardo.git
    fi
    cd bucardo
    perl Makefile.PL
    make
    make install
    cp -f bucardo $BINROOT/bucardo
    cd ..
    
    if [ ! -d /var/run/bucardo ]; then
        mkdir /var/run/bucardo
    fi

    if [ `uname` == "Darwin" ];then
        apacheuser="_www"
    elif [ `uname` == "Linux" ];then
            #try to determine Apache user
            apacheuser=`ps -eo user,stat,args | grep httpd | grep -v grep | grep -v Ss | head -1 | awk '{print $1}'`
            if [ $apacheuser == "root" ];then
                echo "ERROR: cannot grep apache user - grepped root"
                exit
            elif [ $apacheuser == '' ];then
                echo "ERROR: cannot grep apache user - grepped null"
                exit
            fi    

           if [ -z "`grep \"^${apacheuser}:\" /etc/passwd`" ];then
                  echo "Error: User $apacheuser not found in the system"
                  exit
           fi
    fi

    chown -R $apacheuser /var/run/bucardo >/dev/null 2>&1
    
    
    if [[ `uname` == "Darwin" ]];then
        if [ -z "`echo $PATH | grep \"/opt/local/lib/postgresql91/bin\"`" ];then
            echo "Path not found. Setting..."
            export PATH=/opt/local/lib/postgresql91/bin:$PATH
        fi
        export PGUSER=postgres
    fi
    

    bucardo_installed=0
    psql -d postgres -qAt -c "SELECT 1 FROM pg_roles WHERE rolname='bucardo'" | grep -q 1 && bucardo_installed=1
    bucardo show all 2>/dev/null | grep bucardo_current_version && bucardo_installed=1    
    
           
    if [[ $bucardo_installed == 0 ]]; then
        echo "Bucardo is not yet installed"
        bucardo install 
        #Bucardo general settings
        bucardo set piddir=/var/run/bucardo
        bucardo set log_conflict_file=$LOGROOT/bucardo_conflict.log
        bucardo set reason_file=$LOGROOT/bucardo.restart.reason.log
        bucardo set warning_file=$LOGROOT/bucardo.warning.log
        #bucardo set log_level=terse
        bucardo set default_email_from=bucardo@makemyphoto.nl
        bucardo set default_email_to=r.ivantsiv@gmail.com
        

    else
        echo "Bucardo seems to be installed already."
        read -p  "Do you want to remove bucardo?[no]" choice
        if [[ $choice == "yes" ]];then
            bucardo stop >/dev/null 2>&1
            echo "waiting 5 secs..."
            sleep 5
            rm -rf /var/run/bucardo
            psql -U postgres -qAt -c "DROP DATABASE IF EXISTS bucardo"  
            psql -U postgres -d mmp -qAt -c "DROP OWNED BY bucardo CASCADE" 
            psql -U postgres -qAt -c "DROP ROLE IF EXISTS bucardo"     
        fi
       
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
                    echo "ERRORS"
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









