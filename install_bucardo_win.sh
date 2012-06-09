#!/bin/bash
if [ ! -z "$1" ]; then
        REMOTEWINHOST=$1
else
        echo "You have to specify IP of Windows system"
        exit
fi


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
    port install p5.12-dbi
else
    echo "OK"
fi

echo -n "Checking DBD::Pg..."
perl -MDBD::Pg -e 1 > /dev/null 2>&1
if (( $? ))
then
    echo "Absent"
    echo "Installing..."
    port install p5.12-dbd-pg
else
    echo "OK"
fi

echo -n "Checking Test::Simple..."
perl -MTest::Simple -e 1 > /dev/null 2>&1
if (( $? ))
then
    echo "Absent"
    echo "Installing..."
    port install p5.12-test-simple
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

if [ ! -d bucardo ]; then
    echo "Loading Bucardo...."
    git clone git://bucardo.org/bucardo.git
fi

if [ ! -d /var/run/bucardo ]; then
    mkdir /var/run/bucardo
fi

if [ -z "`bucardo show all | grep bucardo_current_version`" ]; then
	echo "Bucardo is not yet installed. We try."
	cd bucardo
	perl Makefile.PL
	make
	make install
	cd ..
	bucardo install 
	read -p "If previous operation failed press Ctr+C to exit script"
else
	echo "Bucardo seems to be installed already. If you want to reinstall, remove bucardo database."
fi

#add local and central dbs
if [ -z "`bucardo list db local | grep local`" ]; then
   bucardo add db local db=mmp dbhost=$REMOTEWINHOST dbport=5432 dbuser=postgres dbpass=pybvrb$%
fi

if [ -z "`bucardo list db central | grep central`" ]; then
    bucardo add db central db=mmp dbhost=127.0.0.1 dbport=5432 dbuser=postgres dbpass=pybvrb$%
fi

#add local tables
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

#Adding cutom columns
bucardo add customcols public.Events "SELECT \"EventGUID\", \"EventName\", \"Date\", \"PrivacyProtected\",\
\"Edited\", \"Editor\", \"EditedDate\", \"SymLinkOriginal\", \"SymLinkBig\",\
\"LocationFacility\", \"LocationMark\""

bucardo add customcols public.LocationFacilities "SELECT \"FacilityGUID\", \"Location\", \"FacilityName\", \"LocationMark\""

bucardo add customcols public.Photoes "SELECT \"PhotoGUID\", \"OriginalName\", \"Event\", \"Photographer\",\
\"DateUploaded\", \"Preselected\", \"SharedStore\", \"Extension\", \"Status\",\
\"SymlinkOriginal\", \"SymlinkBig\", \"LocationMark\""

bucardo add customcols public.Reservations "SELECT \"ReservationGUID\", \"ClientGUID\", \"PhotographerGUID\", \"ReservationTime\",
\"EVerificationCode\", \"PVerificationCode\", \"Confirmed\", \"LocationMark\""


#add dbgroups
if [ -z "`bucardo list dbgroup standard | grep standard`" ]; then
    bucardo add dbgroup standard local:source central
fi

#if [ -z "`bucardo list dbgroup reverse | grep reverse`" ]; then
#    bucardo add dbgroup reverse central:source local
#fi

#add syncs
#if [ -z "`bucardo list sync reverse | grep reverse`" ]; then
#    bucardo add sync reverse herd=localherd dbs=reverse
#fi
if [ -z "`bucardo list sync standard | grep standard`" ]; then
    bucardo add sync standard herd=localherd dbs=standard
fi

#Bucardo general settings
bucardo set piddir=/var/run/bucardo
bucardo set log_conflict_file=/var/log/bucardo_conflict.log
bucardo set reason_file=/var/log/bucardo.restart.reason.log
bucardo set warning_file=/var/log/bucardo.warning.log
#bucardo set log_level=terse
bucardo set default_email_from=bucardo@makemyphoto.nl
bucardo set default_email_to=r.ivantsiv@gmail.com

#Start Bucardo
bucardo start --debugdir=/var/log
alias bucardo-start="bucardo start --debugdir=/var/log"

grep -l "alias bucardo-start=\"bucardo start --debugdir=/var/log\"" ~/.bashrc >/dev/null \
|| echo "alias bucardo-start=\"bucardo start --debugdir=/var/log\"" \
| tee -a ~/.bashrc > /dev/null



#Bucardo checker
#cp -f bucardo_check.sh /opt/local/bin/bucardo_check.sh
#cp -R LaunchDaemons/mmp.bucardo.check /opt/local/etc/LaunchDaemons
#ln -fs /opt/local/etc/LaunchDaemons/mmp.bucardo.check/mmp.bucardo.check.plist /Library/LaunchDaemons/mmp.bucardo.check.plist
#launchctl unload /Library/LaunchDaemons/mmp.bucardo.check.plist
#launchctl load /Library/LaunchDaemons/mmp.bucardo.check.plist

	













